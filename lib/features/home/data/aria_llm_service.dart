import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_keys.dart';
import '../../../features/usage_tracking/data/daily_usage_store.dart';

/// Calls ARIA's Supabase Edge Function. Provider credentials and model
/// configuration never leave the server; only aggregate habit context and the
/// user's explicit chat messages are sent from this device.
class AriaLlmService {
  AriaLlmService(this._prefs);

  final SharedPreferences _prefs;
  static const _secureStore = MethodChannel('com.aria.aria/secure_store');
  static const _supabaseUrl = String.fromEnvironment('ARIA_SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment(
    'ARIA_SUPABASE_ANON_KEY',
  );

  bool get enabled => _prefs.getBool(PrefKeys.ariaAiEnabled) ?? false;
  bool get gatewayConfigured =>
      Uri.tryParse(_supabaseUrl)?.scheme == 'https' &&
      Uri.tryParse(_supabaseUrl)?.host.isNotEmpty == true &&
      _supabaseAnonKey.isNotEmpty;

  String get _projectUrl => _supabaseUrl.replaceFirst(RegExp(r'/+$'), '');

  Future<String> reply(
    String message, {
    bool includeUsage = true,
    List<Map<String, String>> conversation = const [],
  }) async {
    if (!gatewayConfigured) {
      throw StateError(
        'Gateway ARIA belum dikonfigurasi. Isi ARIA_SUPABASE_URL dan ARIA_SUPABASE_ANON_KEY saat build.',
      );
    }
    final accessToken = await _accessToken();
    final context = includeUsage
        ? await _recentContext()
        : 'Konteks penggunaan tidak dibagikan.';
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client
          .postUrl(Uri.parse('$_projectUrl/functions/v1/aria-chat'))
          .timeout(const Duration(seconds: 15));
      request.followRedirects = false;
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $accessToken')
        ..set('apikey', _supabaseAnonKey)
        ..contentType = ContentType.json;
      request.write(
        jsonEncode({
          'message': message,
          'usage_context': context,
          'tone': _toneGuidance(),
          'conversation': conversation.take(10).toList(),
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 45),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(_gatewayError(response.statusCode, body));
      }
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final answer = decoded['message'];
      if (answer is! String || answer.trim().isEmpty) {
        throw const FormatException('Balasan ARIA kosong.');
      }
      final result = answer.trim();
      if (message.startsWith('Buat satu pesan singkat') &&
          (_prefs.getBool(PrefKeys.ariaAiProactive) ?? false)) {
        await _scheduleProactive(result);
      }
      return result;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _accessToken() async {
    final raw = await _secureStore.invokeMethod<String>('readSession');
    if (raw != null) {
      try {
        final session = jsonDecode(raw) as Map<String, dynamic>;
        final expiry = session['expires_at'] as int? ?? 0;
        if (expiry > DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60) {
          return session['access_token'] as String;
        }
        final refreshToken = session['refresh_token'] as String?;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _authRequest(
            'token?grant_type=refresh_token',
            {'refresh_token': refreshToken},
          );
          await _saveSession(refreshed);
          return refreshed['access_token'] as String;
        }
      } on Object {
        await _secureStore.invokeMethod<void>('clearSession');
      }
    }
    final session = await _authRequest('signup', {'data': <String, Object?>{}});
    final token = session['access_token'];
    if (token is! String || token.isEmpty) {
      throw StateError(
        'Supabase Auth belum mengembalikan sesi. Aktifkan anonymous sign-ins di Supabase Auth.',
      );
    }
    await _saveSession(session);
    return token;
  }

  Future<Map<String, dynamic>> _authRequest(
    String path,
    Map<String, Object?> data,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client
          .postUrl(Uri.parse('$_projectUrl/auth/v1/$path'))
          .timeout(const Duration(seconds: 15));
      request.headers
        ..set('apikey', _supabaseAnonKey)
        ..contentType = ContentType.json;
      request.write(jsonEncode(data));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Autentikasi Supabase gagal (${response.statusCode}). Pastikan anonymous sign-ins aktif.',
        );
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _saveSession(Map<String, dynamic> session) async {
    final expiresIn = session['expires_in'] as int? ?? 3600;
    final value = <String, dynamic>{
      ...session,
      'expires_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 + expiresIn,
    };
    await _secureStore.invokeMethod<void>('saveSession', {
      'value': jsonEncode(value),
    });
  }

  String _gatewayError(int status, String body) {
    if (status == 401) return 'Sesi ARIA berakhir. Coba kirim ulang pesan.';
    if (status == 429) return 'ARIA perlu jeda sebentar. Coba lagi nanti.';
    if (status >= 500)
      return 'Gateway ARIA sedang tidak tersedia. Coba lagi nanti.';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = json['error'];
      if (message is String && message.isNotEmpty) return message;
    } on Object {}
    return 'Gateway ARIA menolak permintaan ($status).';
  }

  String _toneGuidance() => switch (_prefs.getString(PrefKeys.ariaTone)) {
    'firm' => 'tegas namun tetap hangat dan tidak menghakimi',
    'playful' => 'ringan dengan humor lembut, jangan meremehkan perasaan',
    'scriptural' => 'lembut; gunakan nilai spiritual secara natural tanpa mengasumsikan keyakinan tertentu',
    _ => 'lembut, menenangkan, dan penuh perhatian',
  };

  Future<void> _scheduleProactive(String message) async {
    final now = DateTime.now();
    var delivery = DateTime(now.year, now.month, now.day, 19);
    if (!delivery.isAfter(now.add(const Duration(minutes: 2)))) {
      delivery = delivery.add(const Duration(days: 1));
    }
    await const MethodChannel('com.aria.aria/proactive').invokeMethod<void>(
      'schedule',
      {'message': message, 'atMillis': delivery.millisecondsSinceEpoch},
    );
  }

  Future<String> _recentContext() async {
    final history = await DailyUsageStore(_prefs).readAll();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = history.where((e) => !e.day.isBefore(cutoff)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    if (recent.isEmpty) return 'Belum ada ringkasan penggunaan yang cukup.';
    final minutes = recent.fold<int>(0, (sum, e) => sum + e.socialMinutes);
    final average = (minutes / recent.length).round();
    final opens = recent.fold<int>(0, (sum, e) => sum + e.socialOpens);
    final scrolls = recent.fold<int>(0, (sum, e) => sum + e.videosAdvanced);
    final delta = recent.length > 1
        ? recent.last.socialMinutes - recent.first.socialMinutes
        : null;
    final direction = delta == null
        ? 'belum cukup data untuk arah perubahan'
        : delta < -5
        ? 'menurun dibanding catatan awal periode'
        : delta > 5
        ? 'meningkat dibanding catatan awal periode'
        : 'relatif stabil dibanding catatan awal periode';
    return 'Ringkasan ${recent.length} hari tercatat (tidak selalu 7 hari penuh): rata-rata sosial $average menit/hari; $opens kali membuka aplikasi; perkiraan $scrolls video digulir. Arah sederhana: $direction. Data rinci per aplikasi dan jawaban check-in tidak disertakan.';
  }
}
