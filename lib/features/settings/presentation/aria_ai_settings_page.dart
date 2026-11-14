import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/pref_keys.dart';
import '../../../core/di/providers.dart';
import '../../../core/presentation/aria_card.dart';
import '../../../core/presentation/aria_scaffold.dart';
import '../../../core/theme/app_spacing.dart';
import '../../check_ins/data/spot_check_notifications.dart';
import '../../home/data/aria_llm_service.dart';

class AriaAiSettingsPage extends ConsumerStatefulWidget {
  const AriaAiSettingsPage({super.key});

  @override
  ConsumerState<AriaAiSettingsPage> createState() => _AriaAiSettingsPageState();
}

class _AriaAiSettingsPageState extends ConsumerState<AriaAiSettingsPage> {
  static const _proactiveChannel = MethodChannel('com.aria.aria/proactive');
  late final AriaLlmService _service;
  bool _enabled = true;
  bool _proactive = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _service = AriaLlmService(prefs);
    _enabled = prefs.getBool(PrefKeys.ariaAiEnabled) ?? true;
    _proactive = prefs.getBool(PrefKeys.ariaAiProactive) ?? true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_enabled && !_service.gatewayConfigured) {
        throw StateError(
          'Gateway belum dikonfigurasi. Isi ARIA_SUPABASE_URL dan ARIA_SUPABASE_ANON_KEY, lalu build ulang aplikasi.',
        );
      }
      final prefs = ref.read(sharedPreferencesProvider);
      if (_proactive &&
          _enabled &&
          !await SpotCheckNotifications.notificationsGranted()) {
        throw StateError(
          'Aktifkan izin notifikasi ARIA di Pengaturan Android terlebih dahulu.',
        );
      }
      await prefs.setBool(PrefKeys.ariaAiEnabled, _enabled);
      await prefs.setBool(PrefKeys.ariaAiProactive, _proactive);
      if (!_proactive || !_enabled) {
        await _proactiveChannel.invokeMethod<void>('cancel');
      } else {
        await _service.reply(
          'Buat satu pesan singkat untuk beranda berdasarkan konteks pengguna. Pilih saran praktis, apresiasi, atau refleksi yang paling sesuai. Jangan mengulang pesan generik.',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan ARIA tersimpan.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Belum tersimpan: $error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AriaScaffold(
      title: 'AI Penasihat ARIA',
      subtitle: 'Atur cara ARIA mendampingimu',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          0,
          AppSpacing.pageGutter,
          AppSpacing.huge,
        ),
        children: [
          const _PrivacyCard(),
          const SizedBox(height: AppSpacing.lg),
          AriaCard(
            eyebrow: 'Status & Mode',
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aktifkan AI ARIA'),
                  subtitle: const Text(
                    'Gunakan model pilihanmu untuk chat dan pesan di beranda.',
                  ),
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pesan proaktif harian'),
                  subtitle: const Text(
                    'Satu pengingat personal sekitar pukul 19.00, dijadwalkan di perangkat.',
                  ),
                  value: _proactive,
                  onChanged: _enabled
                      ? (value) => setState(() => _proactive = value)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AriaCard(
            eyebrow: 'Infrastruktur',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _service.gatewayConfigured
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service.gatewayConfigured
                            ? 'Gateway ARIA siap'
                            : 'Gateway belum dikonfigurasi',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _service.gatewayConfigured
                            ? 'Provider, model, dan kunci dikelola aman dari server.'
                            : 'Tambahkan ARIA_SUPABASE_URL dan ARIA_SUPABASE_ANON_KEY di .env lalu build ulang.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_busy ? 'Menyimpan…' : 'Simpan pengaturan'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Saat AI aktif, chat yang kamu kirim dan ringkasan kebiasaan 7 hari terakhir dikirim ke gateway ARIA lalu diteruskan ke provider AI yang aktif. Kunci provider tidak dikirim ke perangkat. Data check-in lengkap tidak dikirim.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) => AriaCard(
        eyebrow: 'Privasi & Keamanan',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Kamu mengendalikan koneksi AI. ARIA mengirim agregat penggunaan, bukan daftar aplikasi atau jawaban check-in. Provider dan model dapat diganti dari konfigurasi server tanpa update aplikasi.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
}
