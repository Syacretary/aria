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

/// Bank pertanyaan reflektif mendalam berbasis psikologi perilaku dan adiksi digital.
///
/// Dirancang berdasarkan riset seputar:
/// - Dissociative Scrolling & Time Agnosia (kehilangan kesadaran waktu)
/// - Experiential Avoidance & Escapism (lari dari keheningan/kecemasan)
/// - Revenge Bedtime Procrastination (pencurian waktu tidur)
/// - Cognitive Drain & Brain Fog (kelelahan dopamin mikro)
/// - Comparison Trap & Inadequacy (perbandingan sosial bawah sadar)
/// - Phantom Reflex (kegelisahan saat tangan kosong tanpa HP)
abstract final class SpotCheckQuestionBank {
  /// Pertanyaan pembuka yang menakar beban batin pengguna secara jujur dan empatik.
  static const wellbeing = SpotCheckPrompt(
    id: 'wellbeing',
    text:
        'Saat meletakkan ponsel hari ini, bagaimana sebenarnya perasaan di dadamu tentang waktumu di media sosial?',
    options: [
      'Sangat hampa dan lelah (terjebak scroll)',
      'Kurang nyaman dan sedikit menyesal',
      'Biasa saja, seperti hari-hari sebelumnya',
      'Mulai tenang dan terkendali',
      'Sangat lapang, fokusku terjaga penuh',
    ],
  );

  /// Pertanyaan saat penggunaan meningkat / pengguna sedang dalam fase berat (Doomscrolling & Escapism).
  /// Bertujuan menyentuh luka batin secara empatik tanpa menghakimi, menyadarkan bahwa mereka butuh bantuan ARIA.
  static const increasing = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'inc_amnesia',
      text:
          'Dari puluhan bahkan ratusan video singkat yang kamu tonton hari ini, bisakah kamu mengingat 3 saja yang benar-benar bermakna?',
      options: [
        'Jujur, hampir semuanya hilang tanpa bekas',
        'Cuma ingat lelucon/tren sekilas tanpa arti',
        'Ada sedikit info, tapi selebihnya hampa',
        'Otakku justru terasa panas dan berkabut',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_escapism',
      text:
          'Saat jarimu terus menggulir layar padahal tubuhmu sudah lelah, sebenarnya apa yang sedang coba kamu hindari?',
      options: [
        'Tugas atau tanggung jawab yang bikin cemas',
        'Rasa sepi atau kesunyian saat ruangan hening',
        'Perasaan sedih dan lelah yang enggan kuhadapi',
        'Hanya refleks autopilot yang sulit kuhentikan',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_bedtime',
      text:
          'Pernahkah kamu berniat "cuma 5 menit sebelum tidur", tapi berakhir menatap layar dalam gelap hingga matamu perih?',
      options: [
        'Hampir setiap malam, bangun pagi terasa hancur',
        'Sering, karena merasa siang hari bukan milikku',
        'Kadang-kadang, dan selalu berujung penyesalan',
        'Jarang, tapi sekalinya terjadi sangat menguras energi',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_brain_fog',
      text:
          'Setelah berlama-lama scrolling media sosial, bagaimana kondisi pikiran dan konsentrasimu saat itu?',
      options: [
        'Berkabut (brain fog) dan sulit fokus pada hal nyata',
        'Gelisah, cemas, dan overthinking',
        'Capek mental padahal tubuh tidak bergerak',
        'Bingung kenapa waktu terasa hilang begitu cepat',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_insecurity',
      text:
          'Pernahkah kamu membuka media sosial dalam keadaan tenang, tapi menutupnya dengan perasaan insecure dan merasa hidupmu tertinggal?',
      options: [
        'Sering, melihat hidup orang lain bikin kecil hati',
        'Kadang-kadang, terutama soal karir dan pencapaian',
        'Jarang, tapi sesekali tetap memicu cemas',
        'Iya, media sosial sering mencuri rasa syukurku',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_presence',
      text:
          'Pernahkah kamu asyik scrolling padahal di sampingmu ada orang tersayang atau momen nyata yang menunggumu?',
      options: [
        'Pernah, dan ada rasa bersalah yang menusuk',
        'Sering, ragaku ada di sana tapi pikiranku di feed',
        'Sesekali saat percakapan sedang jeda',
        'Aku takut kehilangan kebersamaan nyata ini',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_phantom_reflex',
      text:
          'Ketika ada jeda hening beberapa detik saja dalam harimu, seberapa cepat tanganmu refleks meraih ponsel?',
      options: [
        'Detik itu juga, aku cemas jika tanganku menganggur',
        'Sangat cepat, layar ponsel jadi tameng rasa canggung',
        'Refleks otomatis tanpa kusadari sama sekali',
        'Kadang-kadang, terutama jika merasa bosan',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_opportunity_cost',
      text:
          'Kira-kira, impian atau hal penting apa dalam hidupmu yang tertunda belakangan ini karena energimu tersedot ke layar?',
      options: [
        'Kesehatanku (tidur berantakan, kurang istirahat)',
        'Membaca buku atau mempelajari skill impian',
        'Waktu berkualitas untuk diri sendiri dan keluarga',
        'Ketenangan batin dan kedamaian pikiran',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_vicious_cycle',
      text:
          'Saat kamu merasa stres atau bersalah karena terlalu lama scrolling, apa yang biasanya refleks kamu lakukan?',
      options: [
        'Ironisnya, aku malah kembali scrolling lagi',
        'Menyalahkan diri sendiri tapi tetap memegang ponsel',
        'Melempar ponsel sejenak dengan rasa frustrasi',
        'Mencoba mencari hal lain tapi pikiran tetap terpaku',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_control_plea',
      text:
          'Di lubuk hatimu yang paling jujur, apakah kamu merasa media sosial sedang perlahan merampas kendali harimu?',
      options: [
        'Iya, aku sangat butuh bantuan dan pendampingan untuk lepas',
        'Iya, rasanya hidupku berjalan di mode autopilot',
        'Terkadang iya, dan itu membuatku takut',
        'Aku ingin sekali merebut kembali fokus dan hariku',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_energy_leak',
      text:
          'Setelah meletakkan ponsel usai scrolling panjang, apa rasa yang paling dominan tertinggal di dalam dadamu?',
      options: [
        'Rasa hampa yang dingin dan tidak nyaman',
        'Kelelahan aneh seperti kehabisan baterai jiwa',
        'Penyesalan karena waktu berharga terbuang lagi',
        'Biasa saja, tapi ada perasaan bersalah yang samar',
      ],
    ),
    SpotCheckPrompt(
      id: 'inc_silent_cry',
      text:
          'Jika ada satu hal yang paling ingin kamu selamatkan dari jeratan scroll saat ini, apakah itu?',
      options: [
        'Waktu tidur dan kesegaran tubuhku di pagi hari',
        'Kemampuanku untuk fokus dan berpikir mendalam',
        'Kesehatan mentalku dari rasa insecure',
        'Hubungan nyata dengan orang-orang di sekitarku',
      ],
    ),
  ];

  /// Pertanyaan saat penggunaan relatif stabil / berada dalam rutinitas autopilot.
  /// Bertujuan menggugah kesadaran metakognitif agar pengguna tersentak dari zona nyaman semu.
  static const steady = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'std_purpose',
      text:
          'Saat kamu mengetuk ikon media sosial hari ini, apakah kamu benar-benar punya tujuan, atau hanya dorongan jari bawah sadar?',
      options: [
        'Murni dorongan bawah sadar tanpa tujuan apa pun',
        'Awalnya mau cek satu hal, tapi terbawa berjam-jam',
        'Mencari hiburan sesaat untuk mengisi waktu',
        'Sebagian besar memang sudah terbiasa otomatis',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_silence_fear',
      text:
          'Kapan terakhir kali kamu duduk melamun atau menikmati minuman selama 10 menit tanpa sekali pun menyentuh ponsel?',
      options: [
        'Sudah lama sekali, aku lupa rasanya',
        'Hampir mustahil rasanya tanpa memegang HP',
        'Sesekali, tapi tanganku tetap gatal ingin cek',
        'Kadang bisa, jika ponsel sengaja kujauhkan',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_fake_tired',
      text:
          'Seberapa sering kamu merasa "capek padahal seharian belum melakukan hal produktif apa pun"?',
      options: [
        'Sering banget, scrolling ternyata sangat menguras energi',
        'Hampir setiap sore menjelang malam',
        'Kadang-kadang, saat terlalu banyak berganti aplikasi',
        'Iya, lelah mental akibat banjir stimulasi singkat',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_offline_panic',
      text:
          'Jika hari ini kamu kehilangan akses internet selama 24 jam penuh, emosi apa yang paling pertama muncul?',
      options: [
        'Panik, cemas, dan merasa terasing dari dunia',
        'Gelisah dan bingung mau melakukan apa',
        'Campuran antara panik dan sedikit lega',
        'Akan terasa hening yang aneh dan canggung',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_reopen_glitch',
      text:
          'Pernahkah kamu menutup aplikasi media sosial, lalu 3 detik kemudian tanpa sadar membukanya kembali?',
      options: [
        'Sering banget! Otakku seperti mengalami korsleting',
        'Pernah, itu tanda jelas aku sedang bosan akut',
        'Kadang terjadi saat sedang melamun',
        'Iya, jari-jemariku bergerak sendiri tanpa izin',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_body_delay',
      text:
          'Seberapa sering kamu menunda buang air, makan, atau mandi hanya karena "tanggung satu video lagi"?',
      options: [
        'Jujur, sering banget sampai menahan diri',
        'Kadang-kadang, terutama saat menemukan konten seru',
        'Pernah, dan setelah sadar rasanya konyol',
        'Hampir setiap kali masuk kamar mandi membawa HP',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_reading_span',
      text:
          'Apa yang biasanya terjadi pada rentang konsentrasimu saat mencoba membaca buku atau artikel panjang sekarang?',
      options: [
        'Baru dua paragraf, pikiranku sudah gelisah ingin cek notif',
        'Sulit fokus mendalam seperti beberapa tahun lalu',
        'Cepat mengantuk atau bosan jika teksnya panjang',
        'Masih bisa fokus, tapi butuh perjuangan berat',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_spectator_life',
      text:
          'Apakah kamu merasa lebih banyak menjadi "penonton kehidupan orang lain" dibanding menjalani ceritamu sendiri?',
      options: [
        'Iya, aku lebih tahu kabar orang asing daripada kabarku',
        'Terkadang rasanya hidupku cuma scrolling hidup orang',
        'Mulai terasa tidak seimbang',
        'Aku ingin kembali jadi pemeran utama hariku',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_notification_anxiety',
      text:
          'Berapa kali kamu merasa tertekan oleh notifikasi yang sebenarnya sama sekali tidak darurat?',
      options: [
        'Sering, bunyi lentingannya bikin jantung kaget',
        'Membuat pikiranku terpecah-pecah sepanjang hari',
        'Cukup mengganggu ketenangan dan ritme kerjaku',
        'Aku ingin sekali membisukan semuanya',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_five_years',
      text:
          'Bila kamu melihat dirimu 5 tahun ke depan, apakah kamu rela jika 3-4 jam setiap harimu tetap habis untuk scrolling?',
      options: [
        'Tentu tidak! Aku ingin hidupku punya karya nyata',
        'Membayangkannya saja membuatku ngeri dan sedih',
        'Aku ingin waktu itu untuk hal yang kubanggakan',
        'Inilah alasan kenapa aku butuh ARIA mendampingiku',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_present_moment',
      text:
          'Saat berada di momen indah (senja, kopi hangat, kumpul teman), apa yang lebih dulu kamu pikirkan?',
      options: [
        'Bagaimana sudut terbaik untuk memotret dan mempostingnya',
        'Pikiranku sibuk mengukur reaksi atau like orang lain',
        'Menikmati sesaat, lalu sibuk mengunggahnya',
        'Mulai belajar untuk hadir utuh tanpa perlu pamer',
      ],
    ),
    SpotCheckPrompt(
      id: 'std_inner_space',
      text:
          'Kapan terakhir kali kamu membiarkan pikiranmu melahirkan ide kreatif baru tanpa disuapi konten orang lain?',
      options: [
        'Sudah lama, otakku selalu terisi suara feed',
        'Ide kreatifku sering mati karena keburu scroll',
        'Sesekali saat benar-benar menjauhkan ponsel',
        'Aku rindu kejernihan berpikir yang autentik',
      ],
    ),
  ];

  /// Pertanyaan saat penggunaan membaik / pengguna berhasil mengurangi konsumsi media sosial.
  /// Bertujuan merayakan kesadaran diri, menguatkan neuroplastisitas positif, dan menanamkan rasa syukur.
  static const improving = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'imp_peace',
      text:
          'Ketika kamu memberi jeda pada ponselmu hari ini, apa hal kecil di sekitarmu yang baru kamu sadari keindahannya?',
      options: [
        'Udara segar, suara burung, atau warna langit sore',
        'Wajah dan senyum orang-orang yang ada di dekatku',
        'Rasa makanan yang kunikmati tanpa distraction',
        'Keheningan rumah yang ternyata sangat menenangkan',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_clarity',
      text:
          'Bagaimana rasanya kepala dan matamu saat tidak dibombardir ratusan potongan video hari ini?',
      options: [
        'Jauh lebih ringan dan tidak gampang pusing',
        'Pikiranku terasa lebih jernih, tenang, dan lapang',
        'Tidur terasa lebih pulas dan berkualitas',
        'Emosiku jauh lebih stabil dan tidak gampang cemas',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_agency',
      text:
          'Saat kamu berhasil menutup aplikasi sosial media sebelum batas waktu habis, apa yang kamu rasakan tentang dirimu?',
      options: [
        'Bangga! Ternyata aku masih punya kendali atas diriku',
        'Lega, aku tidak lagi merasa jadi budak algoritma',
        'Merasa lebih berdaya atas pilihan hidupku hari ini',
        'Sebuah kemenangan kecil yang sangat berarti bagiku',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_reclaimed_time',
      text:
          'Apa satu hal atau hobi terbengkalai yang akhirnya sempat kamu sentuh hari ini karena tidak tersedot scroll?',
      options: [
        'Membaca buku atau belajar hal yang kusukai',
        'Berolahraga atau sekadar merawat tubuhku',
        'Mengobrol mendalam dengan teman atau keluarga',
        'Menikmati istirahat berkualitas tanpa rasa bersalah',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_fomo_free',
      text:
          'Ternyata, saat tidak terus-menerus mengecek update orang lain di media sosial, apakah hidupmu baik-baik saja?',
      options: [
        'Sangat baik-baik saja, bahkan jauh lebih damai',
        'Ternyata aku tidak ketinggalan hal apa pun yang esensial',
        'Kecemasanku berkurang drastis saat tidak membandingkan diri',
        'Duniaku terasa jauh lebih nyata dan bermakna',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_deep_connection',
      text:
          'Bagaimana kualitas percakapanmu dengan orang lain belakangan ini saat ponselmu tidak terus bergetar?',
      options: [
        'Jauh lebih hangat, mendalam, dan saling terhubung',
        'Aku bisa mendengarkan tanpa terburu-buru meraba saku',
        'Orang di sekitarku merasa lebih dihargai keberadaannya',
        'Rasanya sangat bahagia bisa benar-benar hadir untuk mereka',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_true_rest',
      text:
          'Apa perbedaan terbesar antara "istirahat scrolling HP" vs "istirahat yang sebenarnya" yang kamu rasakan?',
      options: [
        'Istirahat tanpa HP benar-benar memulihkan energiku',
        'Scrolling ternyata kerja keras untuk otak, bukan istirahat',
        'Tubuh dan mataku sangat berterima kasih atas jeda ini',
        'Pikiranku tidak lagi terpecah-pecah ke banyak hal',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_self_compassion',
      text:
          'Jika dorongan ingin doomscroll muncul lagi besok, pengingat apa yang ingin kamu bisikkan pada dirimu?',
      options: [
        '"Aku berhak atas hidup yang nyata, bukan ilusi layar"',
        '"Ambil napas 10 detik, ARIA ada di sini menemaniku"',
        '"Waktuku terlalu berharga untuk dijual ke algoritma"',
        '"Kemajuan kecil hari ini layak untuk terus kupertahankan"',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_morning_clarity',
      text:
          'Saat kamu tidak langsung meraih ponsel di menit pertama bangun tidur, bagaimana harimu berjalan?',
      options: [
        'Pagi terasa jauh lebih tenang dan tidak terburu-buru',
        'Mood-ku sepanjang hari jadi jauh lebih positif',
        'Tidak langsung dibebani kabar dunia orang lain',
        'Aku bisa memulai hari dengan niat yang jelas',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_gratitude',
      text:
          'Melihat usahamu yang mulai membuahkan hasil, apa pesan terima kasih yang ingin kamu sampaikan pada dirimu sendiri?',
      options: [
        'Terima kasih sudah memilih untuk peduli pada kesehatan mentalku',
        'Terima kasih sudah berani berhenti dan bernapas sejenak',
        'Terima kasih sudah membuktikan bahwa aku mampu berubah',
        'Perjalanan menuju kesadaran ini sangat layak kuperjuangkan',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_space_created',
      text:
          'Ruang lapang yang tercipta di kepalamu hari ini paling ingin kamu isi dengan apa?',
      options: [
        'Ketenangan batin dan rasa syukur yang tulus',
        'Rencana masa depan yang lebih bermakna',
        'Cinta dan perhatian bagi orang-orang terdekat',
        'Karya atau kontribusi nyata bagi sekitarku',
      ],
    ),
    SpotCheckPrompt(
      id: 'imp_companion_bond',
      text:
          'Seberapa besar peran jeda sadar dan pendampingan ARIA dalam membantumu mengenali pola perilakumu?',
      options: [
        'Sangat membantu, membuatku sadar saat mulai autopilot',
        'Cermin nyata yang mengingatkan tanpa menghakimi',
        'Membantuku mengambil jeda napas yang sangat kubutuhkan',
        'Teman pendamping yang membuatku tidak merasa sendirian',
      ],
    ),
  ];

  /// Latihan fokus visual singkat (cognitive grounding) untuk menarik atensi kembali ke masa kini.
  static const focus = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'focus_a',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus sadar: berapa kali simbol ● muncul di bawah ini?',
      challenge: '○  ●  △  ●  □  ○  ●  △',
      options: ['2 kali', '3 kali', '4 kali'],
      correctAnswer: 1,
    ),
    SpotCheckPrompt(
      id: 'focus_b',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus sadar: pilih huruf yang muncul tepat dua kali.',
      challenge: 'A   B   C   A   D   E   F',
      options: ['A', 'B', 'C'],
      correctAnswer: 0,
    ),
    SpotCheckPrompt(
      id: 'focus_c',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus sadar: ada berapa angka genap di deretan ini?',
      challenge: '3   8   1   4   7   2',
      options: ['2 angka', '3 angka', '4 angka'],
      correctAnswer: 1,
    ),
    SpotCheckPrompt(
      id: 'focus_d',
      kind: SpotPromptKind.focus,
      text: 'Latihan fokus sadar: simbol mana yang berbeda orientasi/bentuk?',
      challenge: '▲   ▲   ▲   △   ▲',
      options: ['Simbol ke-2', 'Simbol ke-4', 'Simbol ke-5'],
      correctAnswer: 1,
    ),
  ];

  /// Latihan memori kerja singkat untuk melatih ingatan jangka pendek yang kerap terfragmentasi akibat video pendek.
  static const memory = <SpotCheckPrompt>[
    SpotCheckPrompt(
      id: 'memory_a',
      kind: SpotPromptKind.memory,
      text:
          'Latihan memori kerja: perhatikan 3 kata ini sejenak, lalu ingat kembali.',
      challenge: 'KUNCI  ·  ANGGUR  ·  AWAN',
      options: ['Buku', 'Anggur', 'Daun'],
      correctAnswer: 1,
    ),
    SpotCheckPrompt(
      id: 'memory_b',
      kind: SpotPromptKind.memory,
      text: 'Latihan memori kerja: simpan 3 benda ini di pikiranmu.',
      challenge: 'LILIN  ·  KERETA  ·  KOPI',
      options: ['Kopi', 'Piring', 'Pohon'],
      correctAnswer: 0,
    ),
    SpotCheckPrompt(
      id: 'memory_c',
      kind: SpotPromptKind.memory,
      text: 'Latihan memori kerja: perhatikan 3 kata ini dengan tenang.',
      challenge: 'PANTAI  ·  KACA  ·  MANGGA',
      options: ['Kaca', 'Laut', 'Sepatu'],
      correctAnswer: 0,
    ),
    SpotCheckPrompt(
      id: 'memory_d',
      kind: SpotPromptKind.memory,
      text: 'Latihan memori kerja: rekam 3 benda ini di kepalamu.',
      challenge: 'PAYUNG  ·  ROTI  ·  BINTANG',
      options: ['Awan', 'Roti', 'Kunci'],
      correctAnswer: 1,
    ),
  ];

  /// Memilih set 5 pertanyaan untuk sesi check-in secara acak dan rotatif agar tidak monoton:
  /// - 1 Pertanyaan evaluasi kondisi batin (wellbeing)
  /// - 2 Pertanyaan refleksi mendalam yang disesuaikan dengan tren penggunaan pengguna
  /// - 1 Latihan pemusatan fokus visual (grounding)
  /// - 1 Latihan memori kerja jangka pendek
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
      final fresh = pool
          .where((item) => !recentIds.contains(item.id))
          .toList();
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
