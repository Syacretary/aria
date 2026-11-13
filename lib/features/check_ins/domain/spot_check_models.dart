import 'dart:math';

enum UsageTrend { decreasing, increasing, steady, unknown }

enum SpotPromptKind { reflection, focus, memory }

class SpotCheckPrompt {
  const SpotCheckPrompt({
    required this.id,
    required this.text,
    required this.options,
    this.kind = SpotPromptKind.reflection,
    this.challenge,
    this.correctAnswer = -1,
  });

  final String id;
  final String text;
  final List<String> options;
  final SpotPromptKind kind;
  final String? challenge;
  final int correctAnswer;
}

class SpotCheckAnswer {
  const SpotCheckAnswer({
    required this.promptId,
    required this.value,
    required this.isCorrect,
  });

  final String promptId;
  final String value;
  final bool? isCorrect;

  Map<String, Object?> toJson() => {
    'promptId': promptId,
    'value': value,
    'isCorrect': isCorrect,
  };

  factory SpotCheckAnswer.fromJson(Map<String, dynamic> json) =>
      SpotCheckAnswer(
        promptId: json['promptId'] as String? ?? '',
        value: json['value'] as String? ?? '',
        isCorrect: json['isCorrect'] as bool?,
      );
}

class SpotCheckSession {
  const SpotCheckSession({
    required this.completedAt,
    required this.trend,
    required this.answers,
  });

  final DateTime completedAt;
  final UsageTrend trend;
  final List<SpotCheckAnswer> answers;

  int get focusScore =>
      answers.where((answer) => answer.isCorrect == true).length;
  int get focusTaskCount =>
      answers.where((answer) => answer.isCorrect != null).length;

  int? get wellbeingLevel {
    final answer = answers
        .where((item) => item.promptId == 'wellbeing')
        .firstOrNull;
    if (answer == null) return null;
    final index = SpotCheckQuestionBank.wellbeing.options.indexOf(answer.value);
    return index < 0 ? null : index + 1;
  }

  Map<String, Object?> toJson() => {
    'completedAt': completedAt.toIso8601String(),
    'trend': trend.name,
    'answers': answers.map((answer) => answer.toJson()).toList(),
  };

  factory SpotCheckSession.fromJson(Map<String, dynamic> json) =>
      SpotCheckSession(
        completedAt:
            DateTime.tryParse(json['completedAt'] as String? ?? '') ??
            DateTime.now(),
        trend: UsageTrend.values.firstWhere(
          (value) => value.name == json['trend'],
          orElse: () => UsageTrend.unknown,
        ),
        answers: ((json['answers'] as List<dynamic>?) ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  SpotCheckAnswer.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false),
      );
}

/// A pool of short, non-clinical prompts. The trend selects a fitting pool;
/// focus and memory mini-tasks are included in every session.
abstract final class SpotCheckQuestionBank {
  static const wellbeing = SpotCheckPrompt(
    id: 'wellbeing',
    text: 'Dibanding beberapa hari lalu, bagaimana perasaanmu tentang penggunaan media sosialmu?',
    options: [
      'Jauh lebih berat',
      'Sedikit lebih berat',
      'Kurang lebih sama',
      'Sedikit lebih baik',
      'Jauh lebih baik',
    ],
  );

  static const improving = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'better_1',
      text: 'Bagian hari mana yang terasa lebih lapang?',
      options: ['Pagi', 'Siang', 'Sore atau malam', 'Belum terasa berbeda'],
    ),
    SpotCheckPrompt(
      id: 'better_2',
      text: 'Apa yang paling membantu mengurangi waktu scroll?',
      options: [
        'Batas waktu',
        'Punya kegiatan lain',
        'Lebih sadar saat membuka',
        'Belum tahu',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_3',
      text: 'Hal kecil apa yang sempat kamu lakukan saat tidak membuka feed?',
      options: [
        'Istirahat',
        'Menyelesaikan tugas',
        'Mengobrol langsung',
        'Belum ada yang teringat',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_4',
      text: 'Seberapa mudah kamu berhenti saat sudah cukup?',
      options: [
        'Lebih mudah',
        'Sedikit lebih mudah',
        'Masih sama',
        'Belum yakin',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_5',
      text: 'Apa yang ingin kamu pertahankan minggu ini?',
      options: [
        'Jam bebas layar',
        'Berhenti setelah tujuan tercapai',
        'Membuka lebih jarang',
        'Belum ingin menetapkan target',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_6',
      text:
          'Setelah memakai media sosial, bagaimana perasaanmu belakangan ini?',
      options: [
        'Lebih ringan',
        'Kurang lebih sama',
        'Kadang lelah',
        'Sulit menilai',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_7',
      text: 'Momen tanpa ponsel mana yang ingin kamu ulangi?',
      options: [
        'Saat makan',
        'Sebelum tidur',
        'Waktu bersama orang lain',
        'Belum ada',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_8',
      text:
          'Apakah pengurangan ini memberi ruang untuk hal yang penting bagimu?',
      options: [
        'Ya, terasa jelas',
        'Sedikit',
        'Belum terasa',
        'Aku belum tahu',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_9',
      text: 'Apa tanda kecil bahwa ritmemu mulai terasa lebih pas?',
      options: [
        'Lebih fokus',
        'Lebih tenang',
        'Lebih banyak waktu',
        'Belum ada tanda',
      ],
    ),
    SpotCheckPrompt(
      id: 'better_10',
      text: 'Kalau besok terasa sulit, dukungan kecil apa yang membantu?',
      options: [
        'Pengingat lembut',
        'Menjauhkan ponsel',
        'Rencana kegiatan',
        'Bersikap lebih sabar pada diri sendiri',
      ],
    ),
  ];

  static const increasing = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'hard_1',
      text: 'Kapan kamu paling sering membuka aplikasi tanpa rencana?',
      options: [
        'Saat bangun',
        'Saat jeda tugas',
        'Saat merasa bosan',
        'Menjelang tidur',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_2',
      text: 'Apa yang biasanya kamu cari ketika mulai scroll?',
      options: [
        'Hiburan',
        'Kabar teman',
        'Mengalihkan pikiran',
        'Aku tidak selalu tahu',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_3',
      text: 'Bagian mana yang terasa paling sulit?',
      options: [
        'Tidak membuka',
        'Berhenti setelah mulai',
        'Menolak notifikasi',
        'Menemukan kegiatan pengganti',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_4',
      text: 'Apa yang paling sering membuat sesi jadi lebih lama?',
      options: [
        'Video berikutnya',
        'Notifikasi',
        'Komentar atau pesan',
        'Kehilangan jejak waktu',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_5',
      text: 'Bagaimana perasaanmu setelah sesi yang lebih lama?',
      options: [
        'Baik-baik saja',
        'Sedikit lelah',
        'Menyesal atau terganggu',
        'Aku belum memperhatikan',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_6',
      text: 'Perubahan kecil apa yang terasa realistis untuk dicoba?',
      options: [
        'Jeda sebelum membuka',
        'Pasang pengingat',
        'Tentukan tujuan dulu',
        'Belum siap mengubah apa pun',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_7',
      text: 'Apa yang sedang kamu butuhkan saat ingin terus scroll?',
      options: ['Istirahat', 'Teman bicara', 'Hiburan', 'Belum tahu'],
    ),
    SpotCheckPrompt(
      id: 'hard_8',
      text: 'Siapa atau apa yang bisa mendukungmu tanpa menghakimi?',
      options: [
        'Teman dekat',
        'Kegiatan yang kusukai',
        'Pengingat dari ARIA',
        'Aku ingin mencari tahu',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_9',
      text: 'Adakah waktu tertentu yang ingin kamu jaga dari scroll?',
      options: [
        'Saat bangun',
        'Saat belajar atau bekerja',
        'Saat bersama orang lain',
        'Sebelum tidur',
      ],
    ),
    SpotCheckPrompt(
      id: 'hard_10',
      text: 'Untuk hari ini, langkah yang cukup baik bagimu adalah…',
      options: [
        'Mengurangi sedikit',
        'Berhenti sekali saat sadar',
        'Mencoba jeda singkat',
        'Beristirahat tanpa menyalahkan diri',
      ],
    ),
  ];

  static const steady = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'steady_1',
      text:
          'Apakah kamu merasa lebih baik dengan ritme media sosialmu sekarang?',
      options: ['Ya', 'Sedikit', 'Belum', 'Sulit menilai'],
    ),
    SpotCheckPrompt(
      id: 'steady_2',
      text: 'Saat membuka media sosial, biasanya kamu punya tujuan?',
      options: [
        'Hampir selalu',
        'Kadang-kadang',
        'Jarang',
        'Belum memperhatikan',
      ],
    ),
    SpotCheckPrompt(
      id: 'steady_3',
      text: 'Setelah sesi, seberapa puas kamu dengan waktu yang terpakai?',
      options: ['Puas', 'Cukup', 'Kurang', 'Belum tahu'],
    ),
    SpotCheckPrompt(
      id: 'steady_4',
      text: 'Kegiatan apa yang ingin mendapat sedikit lebih banyak ruang?',
      options: [
        'Istirahat',
        'Belajar atau bekerja',
        'Keluarga dan teman',
        'Hobi',
      ],
    ),
    SpotCheckPrompt(
      id: 'steady_5',
      text: 'Apa yang paling sering mengganggu fokusmu?',
      options: [
        'Notifikasi',
        'Kebiasaan membuka aplikasi',
        'Rasa lelah',
        'Belum tahu',
      ],
    ),
    SpotCheckPrompt(
      id: 'steady_6',
      text: 'Kapan menggunakan media sosial terasa paling bermanfaat?',
      options: [
        'Terhubung dengan teman',
        'Mencari informasi',
        'Hiburan terencana',
        'Belum ada waktu khusus',
      ],
    ),
    SpotCheckPrompt(
      id: 'steady_7',
      text: 'Bagaimana kualitas jedamu dari layar belakangan ini?',
      options: [
        'Cukup memulihkan',
        'Lumayan',
        'Kurang',
        'Aku belum memperhatikan',
      ],
    ),
    SpotCheckPrompt(
      id: 'steady_8',
      text:
          'Seberapa sadar kamu ketika satu video berganti ke video berikutnya?',
      options: ['Sadar', 'Kadang sadar', 'Sering terbawa', 'Tidak yakin'],
    ),
    SpotCheckPrompt(
      id: 'steady_9',
      text: 'Apa yang paling ingin kamu pahami tentang kebiasaanmu?',
      options: [
        'Waktu pemicu',
        'Perasaan sebelum membuka',
        'Apa yang membuat berhenti',
        'Belum ada',
      ],
    ),
    SpotCheckPrompt(
      id: 'steady_10',
      text: 'Seberapa cocok batas yang kamu pilih dengan kebutuhanmu?',
      options: [
        'Cocok',
        'Agak cocok',
        'Perlu disesuaikan',
        'Belum memakai batas',
      ],
    ),
  ];

  static const focus = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'focus_a',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus: berapa kali simbol ● muncul?',
      challenge: '○  ●  △  ●  □  ○  ●  △',
      options: ['2 kali', '3 kali', '4 kali'],
      correctAnswer: 1,
    ),
    SpotCheckPrompt(
      id: 'focus_b',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus: pilih huruf yang muncul tepat dua kali.',
      challenge: 'A   B   C   A   D   E   F',
      options: ['A', 'B', 'C'],
      correctAnswer: 0,
    ),
    SpotCheckPrompt(
      id: 'focus_c',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus: berapa angka genap yang terlihat?',
      challenge: '3   8   1   4   7   2',
      options: ['2 angka', '3 angka', '4 angka'],
      correctAnswer: 1,
    ),
    SpotCheckPrompt(
      id: 'focus_d',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus: simbol mana yang tidak cocok dengan lainnya?',
      challenge: '▲   ▲   ▲   △   ▲',
      options: ['Simbol ke-2', 'Simbol ke-4', 'Simbol ke-5'],
      correctAnswer: 1,
    ),
  ];

  static const memory = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'memory_a',
      kind: SpotPromptKind.memory,
      text: 'Latihan ingatan: ingat tiga kata ini, lalu pilih salah satunya.',
      challenge: 'KUNCI  ·  ANGGUR  ·  AWAN',
      options: ['Buku', 'Anggur', 'Daun'],
      correctAnswer: 1,
    ),
    SpotCheckPrompt(
      id: 'memory_b',
      kind: SpotPromptKind.memory,
      text: 'Latihan ingatan: ingat tiga benda ini.',
      challenge: 'LILIN  ·  KERETA  ·  KOPI',
      options: ['Kopi', 'Piring', 'Pohon'],
      correctAnswer: 0,
    ),
    SpotCheckPrompt(
      id: 'memory_c',
      kind: SpotPromptKind.memory,
      text: 'Latihan ingatan: ingat tiga kata ini.',
      challenge: 'PANTAI  ·  KACA  ·  MANGGA',
      options: ['Kaca', 'Laut', 'Sepatu'],
      correctAnswer: 0,
    ),
    SpotCheckPrompt(
      id: 'memory_d',
      kind: SpotPromptKind.memory,
      text: 'Latihan ingatan: ingat tiga benda ini.',
      challenge: 'PAYUNG  ·  ROTI  ·  BINTANG',
      options: ['Awan', 'Roti', 'Kunci'],
      correctAnswer: 1,
    ),
  ];

  static List<SpotCheckPrompt> select(
    UsageTrend trend,
    Set<String> recentIds, {
    int? seed,
  }) {
    final random = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
    final reflectionPool = switch (trend) {
      UsageTrend.decreasing => improving,
      UsageTrend.increasing => increasing,
      UsageTrend.steady || UsageTrend.unknown => steady,
    };
    List<SpotCheckPrompt> takeFresh(List<SpotCheckPrompt> pool) {
      final fresh = pool.where((item) => !recentIds.contains(item.id)).toList();
      final candidates = fresh.isEmpty ? List<SpotCheckPrompt>.of(pool) : fresh;
      candidates.shuffle(random);
      return candidates;
    }

    final reflections = takeFresh(reflectionPool).take(2).toList();
    final focusQuestion = takeFresh(focus).first;
    final memoryQuestion = takeFresh(memory).first;
    final selected = [wellbeing, ...reflections, focusQuestion, memoryQuestion]
      ..shuffle(random);
    return selected;
  }
}
