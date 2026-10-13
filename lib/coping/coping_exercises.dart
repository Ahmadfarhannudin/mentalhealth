import 'package:flutter/material.dart';

enum ExerciseKind { breathing, guided, journal }

class BreathPhase {
  final String label;
  final String hint;
  final int seconds;
  final double scaleFrom;
  final double scaleTo;
  const BreathPhase(this.label, this.hint, this.seconds, this.scaleFrom, this.scaleTo);
}

class ExerciseStep {
  final String title;
  final String body;
  final String? inputHint;
  const ExerciseStep(this.title, this.body, {this.inputHint});
}

class CopingExercise {
  final String id;
  final String title;
  final String category;
  final int minutes;
  final String description;
  final IconData icon;
  final ExerciseKind kind;
  final String overview;
  final List<String> benefits;
  final String evidence;
  final String? caution;
  final List<ExerciseStep> steps;
  final List<BreathPhase> breathPhases;
  final int cycles;

  const CopingExercise({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.description,
    required this.icon,
    required this.kind,
    required this.overview,
    required this.benefits,
    required this.evidence,
    required this.steps,
    this.caution,
    this.breathPhases = const [],
    this.cycles = 0,
  });

  String get kindLabel {
    switch (kind) {
      case ExerciseKind.breathing:
        return 'Napas terpandu';
      case ExerciseKind.guided:
        return 'Latihan terpandu';
      case ExerciseKind.journal:
        return 'Tulis & refleksi';
    }
  }
}

const List<String> exerciseCategories = [
  'Semua',
  'Pernapasan',
  'Kecemasan',
  'CBT Reframing',
  'Refleksi',
];

Color categoryAccent(String category) {
  switch (category) {
    case 'Pernapasan':
      return const Color(0xFF5E9C95);
    case 'Kecemasan':
      return const Color(0xFF7C9A5E);
    case 'CBT Reframing':
      return const Color(0xFF6B8DB3);
    case 'Refleksi':
      return const Color(0xFFB98B6A);
    default:
      return const Color(0xFF7C9A5E);
  }
}

const String safetyNote =
    'Latihan ini membantu mengelola stres sehari-hari dan bukan pengganti terapi '
    'atau pertolongan profesional. Jika kamu merasa ingin menyakiti diri sendiri '
    'atau berada dalam krisis, segera hubungi layanan darurat, layanan kesehatan '
    'jiwa (119 ext. 8), atau orang tepercaya di dekatmu.';

const List<CopingExercise> copingExercises = [
  // ─────────────────────── PERNAPASAN ───────────────────────
  CopingExercise(
    id: 'slow-breathing',
    title: 'Napas Diafragma 4-6',
    category: 'Pernapasan',
    minutes: 5,
    description: 'Bernapas lambat dengan perut — hembusan lebih panjang mengaktifkan rem alami tubuh.',
    icon: Icons.air,
    kind: ExerciseKind.breathing,
    overview:
        'Pernapasan diafragma pola 4 detik tarik dan 6 detik hembus menghasilkan '
        'sekitar 6 napas per menit — frekuensi yang paling konsisten meningkatkan '
        'variabilitas detak jantung (HRV) secara klinis. Hembusan lebih panjang dari '
        'tarikan merangsang saraf vagus dan menurunkan aktivitas simpatik (fight or flight), '
        'memberi sinyal pada tubuh bahwa ancaman sudah berlalu.',
    benefits: [
      'Menurunkan kecemasan dan stres akut',
      'Meningkatkan HRV (tanda kesehatan jantung dan saraf)',
      'Membantu sulit tidur',
      'Menurunkan tekanan darah',
    ],
    evidence:
        'Dasar ilmiah: Pernapasan lambat ~6 napas/menit secara konsisten meningkatkan HRV '
        'dan sensitivitas baroreflex, serta mengurangi tekanan darah dan kecemasan '
        '(Hamasaki, 2020, Healthcare; Ma dkk., 2017, Frontiers in Psychology). '
        'Studi biofeedback HRV menunjukkan pengurangan signifikan gejala kecemasan (Moss, 2004). '
        'Rasio ekspirasi lebih panjang dari inspirasi (4:6) adalah prinsip utama yang '
        'menghasilkan efek parasimpatis, berbeda dari pernapasan biasa.',
    caution: 'Jika terasa pusing atau kesemutan, kembali ke napas normal. Wajar terjadi saat pertama kali berlatih karena CO2 darah turun sementara.',
    cycles: 18,
    breathPhases: [
      BreathPhase('Tarik napas', 'Lewat hidung, rasakan perut mengembang', 4, 0.55, 1.0),
      BreathPhase('Hembuskan', 'Pelan lewat mulut, perut mengempis', 6, 1.0, 0.55),
    ],
    steps: [
      ExerciseStep('Atur posisi',
          'Duduk tegak atau berbaring. Letakkan satu tangan di perut dan satu di dada. '
          'Tujuan: saat bernapas, hanya tangan di perut yang bergerak naik-turun.'),
      ExerciseStep('Tarik napas 4 hitungan',
          'Tarik lewat hidung 4 detik. Rasakan perut mengembang ke depan — '
          'dada nyaris diam. Ini tanda pernapasan diafragma yang benar.'),
      ExerciseStep('Hembuskan 6 hitungan',
          'Keluarkan perlahan lewat bibir yang sedikit mengerucut, seperti meniup lilin. '
          'Hembusan 6 detik mengaktifkan saraf vagus secara langsung.'),
      ExerciseStep('Lanjutkan 5 menit',
          'Target sekitar 6 napas per menit (18 siklus). '
          'Perhatikan tubuh yang perlahan melunak dan pikiran yang mulai melambat.'),
    ],
  ),

  CopingExercise(
    id: 'box-breathing',
    title: 'Box Breathing',
    category: 'Pernapasan',
    minutes: 4,
    description: 'Pola napas empat sisi yang seimbang — digunakan militer AS untuk kontrol stres akut.',
    icon: Icons.crop_square_rounded,
    kind: ExerciseKind.breathing,
    overview:
        'Tarik, tahan, hembus, tahan — masing-masing 4 detik, membentuk kotak. '
        'Pola ini menghasilkan sekitar 3,75 napas/menit, menstabilkan CO2 darah '
        'dan memutus siklus pernapasan dangkal saat panik. '
        'Digunakan secara resmi oleh Navy SEAL AS sebagai tactical breathing.',
    benefits: [
      'Kontrol kecemasan akut dan panik ringan',
      'Meningkatkan fokus dan konsentrasi',
      'Menstabilkan detak jantung dengan cepat',
      'Efektif sebelum situasi menegangkan',
    ],
    evidence:
        'Dasar ilmiah: Studi RCT pada tentara (Grossman & Christensen, 2004) menunjukkan '
        'tactical breathing meningkatkan kontrol diri di bawah tekanan. '
        'Studi PMC (2023) membandingkan box breathing vs. 6 napas/menit setelah HIIT — '
        'keduanya efektif memulihkan HRV dan menurunkan detak jantung. '
        'Pernapasan terstruktur dengan jeda tahan napas terbukti mengurangi aktivasi amigdala '
        '(Jerath dkk., 2015, Applied Psychophysiology & Biofeedback).',
    caution: 'Jika menahan napas terasa tidak nyaman atau ada gangguan pernapasan, persingkat jeda tahan menjadi 2 detik atau lewati fase menahan.',
    cycles: 10,
    breathPhases: [
      BreathPhase('Tarik napas', 'Pelan lewat hidung', 4, 0.55, 1.0),
      BreathPhase('Tahan', 'Tenang, tanpa menegang', 4, 1.0, 1.0),
      BreathPhase('Hembuskan', 'Pelan lewat mulut', 4, 1.0, 0.55),
      BreathPhase('Tahan', 'Biarkan paru kosong sejenak', 4, 0.55, 0.55),
    ],
    steps: [
      ExerciseStep('Bayangkan sebuah kotak',
          'Setiap sisi kotak = 4 hitungan. '
          'Visualisasi kotak membantu pikiran tetap fokus.'),
      ExerciseStep('Tarik & tahan',
          'Tarik napas lewat hidung 4 hitungan, isi paru penuh. '
          'Tahan 4 hitungan. Bahu dan rahang tetap rileks.'),
      ExerciseStep('Hembus & tahan',
          'Hembuskan semua udara perlahan 4 hitungan. '
          'Tahan kosong 4 hitungan. Biarkan dada rileks saat paru kosong.'),
      ExerciseStep('Ulangi 8-10 siklus',
          'Satu siklus = 16 detik. Delapan siklus sekitar 2 menit. '
          'Rasakan stabilnya ritme napas dan kejernihan pikiran yang muncul.'),
    ],
  ),

  CopingExercise(
    id: '4-7-8-breathing',
    title: 'Napas 4-7-8',
    category: 'Pernapasan',
    minutes: 5,
    description: 'Teknik berbasis pranayama untuk meredakan kecemasan akut dan membantu tertidur.',
    icon: Icons.nightlight_round,
    kind: ExerciseKind.breathing,
    overview:
        'Pola 4-7-8 berakar dari pranayama yoga kuno, dipopulerkan Dr. Andrew Weil. '
        'Menahan napas 7 detik meningkatkan tekanan parsial oksigen di alveoli. '
        'Hembusan panjang 8 detik secara kuat mengaktifkan sistem parasimpatis — '
        'rasio ekspirasi terhadap inspirasi 2:1 menghasilkan efek lebih intens '
        'dibanding pernapasan diafragma biasa.',
    benefits: [
      'Meredakan kecemasan dan panik dalam menit',
      'Membantu tertidur lebih cepat',
      'Menurunkan detak jantung dan tekanan darah sistolik',
      'Efek terasa dalam 4 siklus pertama',
    ],
    evidence:
        'Dasar ilmiah: Studi pada orang dewasa muda menunjukkan 4-7-8 breathing '
        'meningkatkan HRV secara signifikan dan menurunkan tekanan darah sistolik '
        '(Prachayasittikul dkk., 2021, PMC). RCT aktif (NCT07828028) mengevaluasi '
        'efeknya pada kecemasan dan kualitas tidur pasien kemoterapi. '
        'Mekanisme dikonfirmasi Russo dkk. (2017, Frontiers in Human Neuroscience): '
        'ekspirasi panjang meningkatkan tonus vagal dan HRV. '
        'Dr. Weil merekomendasikan 4 siklus per sesi, dua kali sehari.',
    caution: 'Pemula sering merasa sedikit pusing — normal karena bernapas jauh lebih lambat. Mulai dengan 4 siklus. Tidak dianjurkan bagi penderita asma atau PPOK tanpa konsultasi dokter.',
    cycles: 4,
    breathPhases: [
      BreathPhase('Hembuskan', 'Kosongkan paru lewat mulut dengan suara whoosh', 2, 1.0, 0.55),
      BreathPhase('Tarik napas', 'Pelan lewat hidung, hitung dalam hati 1-4', 4, 0.55, 1.0),
      BreathPhase('Tahan', 'Tutup mulut, tahan napas, hitung 1-7', 7, 1.0, 1.0),
      BreathPhase('Hembuskan', 'Lewat mulut dengan suara whoosh, hitung 1-8', 8, 1.0, 0.55),
    ],
    steps: [
      ExerciseStep('Posisi dan lidah',
          'Duduk tegak atau berbaring. Letakkan ujung lidah di langit-langit mulut, '
          'tepat di belakang gigi depan atas. Pertahankan posisi ini sepanjang latihan.'),
      ExerciseStep('Hembuskan semua dahulu',
          'Hembuskan semua udara lewat mulut dengan suara "whoosh" untuk mengosongkan paru. '
          'Ini titik awal tiap siklus.'),
      ExerciseStep('Satu siklus: 4 - 7 - 8',
          'Tarik napas lewat hidung 4 hitungan, tahan 7 hitungan, '
          'hembuskan lewat mulut 8 hitungan dengan suara "whoosh".'),
      ExerciseStep('Ulangi 3 siklus lagi',
          'Total 4 siklus per sesi (sekitar 1,5 menit). '
          'Efek membantu tidur paling kuat jika dilakukan tepat sebelum berbaring.'),
    ],
  ),

  // ─────────────────────── KECEMASAN ───────────────────────
  CopingExercise(
    id: 'grounding-54321',
    title: 'Grounding 5-4-3-2-1',
    category: 'Kecemasan',
    minutes: 5,
    description: 'Kembalikan fokus ke saat ini dengan melibatkan kelima indra satu per satu.',
    icon: Icons.spa,
    kind: ExerciseKind.guided,
    overview:
        'Teknik grounding memindahkan perhatian dari pikiran yang berputar ke pengalaman '
        'indrawi konkret saat ini. Mekanismenya berakar pada attentional retraining dan '
        'mindfulness: mengalihkan aktivitas otak dari jaringan mode default (rumination) '
        'ke pemrosesan sensorik yang lebih tenang. '
        'Cocok saat cemas, panik ringan, disosiasi, atau merasa tidak hadir.',
    benefits: [
      'Memutus pikiran yang berputar',
      'Meredakan panik dan disosiasi ringan',
      'Bisa dilakukan diam-diam di mana saja',
      'Tidak memerlukan alat apapun',
    ],
    evidence:
        'Catatan ilmiah: Teknik 5-4-3-2-1 luas digunakan dalam terapi trauma (EMDR, '
        'trauma-informed care) dan CBT, namun hingga saat ini belum ada RCT yang '
        'menguji format spesifik ini secara terkontrol. '
        'Efektivitasnya disimpulkan dari penelitian grounding berbasis mindfulness '
        '(Kabat-Zinn, 1990; van der Kolk, 2014, The Body Keeps the Score) dan prinsip '
        'attentional retraining. Banyak klinisi melaporkan manfaatnya dalam praktik, '
        'namun bukti RCT langsung masih terbatas. '
        'Gunakan sebagai alat pertolongan pertama, bukan pengganti terapi.',
    steps: [
      ExerciseStep('Tarik napas dulu',
          'Satu napas dalam dan pelan sebelum memulai. '
          'Kamu aman di sini, saat ini. Biarkan napas menjadi jangkar pertamamu.'),
      ExerciseStep('5 hal yang kamu LIHAT',
          'Lihat sekeliling perlahan. Sebutkan 5 benda dalam hati sespesifik mungkin. '
          'Contoh: "lampu putih bundar di langit-langit", bukan sekadar "lampu". '
          'Detail memperkuat efek grounding.'),
      ExerciseStep('4 hal yang kamu RASAKAN',
          'Sentuh 4 hal berbeda: tekstur kain baju, permukaan meja, '
          'telapak kaki di lantai, udara di telapak tangan. '
          'Deskripsikan suhu dan teksturnya dalam hati.'),
      ExerciseStep('3 hal yang kamu DENGAR',
          'Tutup mata sejenak. Dengarkan dari suara terjauh hingga terdekat. '
          'Beri nama tiap suara dalam hati.'),
      ExerciseStep('2 hal yang kamu CIUM',
          'Cium udara di sekitarmu. Jika tidak ada aroma, ingat 2 aroma yang kamu sukai. '
          'Memori aroma juga mengaktifkan sistem indera.'),
      ExerciseStep('1 hal yang kamu KECAP',
          'Rasakan sisa rasa di mulut, atau minum seteguk air perlahan. '
          'Satu sensasi ini melengkapi kelima inderamu.'),
      ExerciseStep('Kembali ke saat ini',
          'Tarik napas dalam sekali lagi. Perhatikan apa yang berubah — '
          'apakah pikiran sedikit lebih tenang? Tidak ada jawaban yang salah di sini.'),
    ],
  ),

  CopingExercise(
    id: 'pmr',
    title: 'Relaksasi Otot Progresif',
    category: 'Kecemasan',
    minutes: 12,
    description: 'Tegangkan lalu lepaskan kelompok otot — protokol klinis Bernstein & Borkovec.',
    icon: Icons.self_improvement,
    kind: ExerciseKind.guided,
    overview:
        'Dikembangkan Jacobson (1934), distandarkan Bernstein & Borkovec (1973). '
        'Menegangkan otot secara sengaja lalu melepaskannya menciptakan rebound effect — '
        'otot rileks melampaui titik istirahat semula. Kunci protokol: fase pelepasan '
        '20-30 detik, jauh lebih lama dari tegangan 5-7 detik, agar sistem saraf '
        'mencapai relaksasi yang lebih dalam.',
    benefits: [
      'Mengurangi ketegangan fisik kronis',
      'Membantu tidur lebih cepat dan nyenyak',
      'Menurunkan kecemasan dan stres',
      'Meredakan sakit kepala tegang',
      'Menurunkan tekanan darah',
    ],
    evidence:
        'Dasar ilmiah: Meta-analisis Manzoni dkk. (2008, Clinical Psychology Review) '
        'menganalisis 27 studi — PMR terbukti efektif mengurangi kecemasan dengan effect '
        'size sedang hingga besar. Efektif untuk insomnia (Morin dkk., 2006, Sleep) dan '
        'nyeri kepala tegang. Protokol Bernstein & Borkovec (1973): 16 kelompok otot, '
        'tegangan 5-7 detik, pelepasan 20-30 detik. '
        'Studi (PMID: 3679946) mengkonfirmasi fase pelepasan harus lebih lama dari '
        'tegangan agar rebound relaxation terjadi penuh.',
    caution: 'Lewati bagian tubuh yang cedera atau nyeri. Tegangkan hanya 70% kekuatan. Gunakan tegangan ringan untuk betis agar tidak kram.',
    steps: [
      ExerciseStep('Siapkan diri',
          'Duduk atau berbaring nyaman di tempat yang tenang. '
          'Ambil 3-5 napas perut perlahan. Biarkan mata tertutup ringan.'),
      ExerciseStep('Tangan dan lengan dominan',
          'Kepalkan tangan kanan 70% kekuatan selama 5-7 detik. '
          'Lepaskan sepenuhnya. Nikmati sensasi hangat dan berat selama 20-30 detik. '
          'Perhatikan kontrasnya — inilah rebound relaxation.'),
      ExerciseStep('Tangan dan lengan non-dominan',
          'Ulangi dengan tangan kiri: kepal 5-7 detik, lepas sepenuhnya. '
          'Perhatikan sensasi 20-30 detik.'),
      ExerciseStep('Wajah — dahi',
          'Angkat alis setinggi mungkin 5-7 detik. '
          'Lepaskan. Rasakan dahi yang menghalus selama 20-30 detik.'),
      ExerciseStep('Wajah — tengah dan rahang',
          'Pejamkan mata erat, kencangkan pipi dan hidung 5-7 detik. '
          'Lepaskan. Biarkan rahang sedikit terbuka dan rileks 20-30 detik.'),
      ExerciseStep('Leher dan bahu',
          'Angkat kedua bahu ke arah telinga 5-7 detik. '
          'Jatuhkan. Rasakan bahu yang berat turun jauh ke bawah selama 20-30 detik.'),
      ExerciseStep('Dada dan punggung atas',
          'Tarik napas dalam dan rapatkan tulang belikat 5-7 detik. '
          'Hembuskan dan lepaskan. Rasakan dada yang terbuka selama 20-30 detik.'),
      ExerciseStep('Perut',
          'Kencangkan perut seolah bersiap ditepuk 5-7 detik. '
          'Lepaskan sambil menghembuskan napas perlahan. Istirahat 20-30 detik.'),
      ExerciseStep('Paha, betis dan kaki',
          'Tekan paha ke bawah, kencangkan betis, tekuk jari kaki ke atas 5-7 detik. '
          'Lepaskan semua. Gunakan tegangan ringan di betis untuk cegah kram. '
          'Istirahat 20-30 detik.'),
      ExerciseStep('Pindai seluruh tubuh',
          'Diam 1-2 menit. Pindai perlahan dari kepala ke kaki. '
          'Jika ada area yang masih tegang, lepaskan dengan satu napas perlahan. '
          'Nikmati keadaan rileks yang dalam ini.'),
    ],
  ),

  CopingExercise(
    id: 'worry-time',
    title: 'Tunda Kekhawatiran',
    category: 'Kecemasan',
    minutes: 8,
    description: 'Jadwalkan waktu khusus untuk khawatir — bebaskan sisa harimu dari overthinking.',
    icon: Icons.schedule,
    kind: ExerciseKind.journal,
    overview:
        'Worry postponement adalah komponen CBT untuk Generalized Anxiety Disorder (GAD). '
        'Alih-alih menghentikan kekhawatiran — yang justru memperburuknya melalui efek '
        'rebound — kamu mengakuinya lalu menundanya ke waktu yang kamu tentukan sendiri. '
        'Setiap kali pikiran khawatir muncul di luar jadwal, katakan: '
        '"Aku sudah mencatatnya. Aku akan memikirkannya pukul ___."',
    benefits: [
      'Mengurangi frekuensi dan intensitas overthinking harian',
      'Melatih rasa kendali atas pikiran',
      'Memisahkan masalah nyata vs. hipotetis',
      'Memperbaiki konsentrasi saat bekerja atau belajar',
    ],
    evidence:
        'Dasar ilmiah: Meta-analisis Eisma dkk. (2021, International Journal of Cognitive '
        'Behavioral Therapy) menganalisis 7 RCT — worry postponement efektif mengurangi '
        'frekuensi dan intensitas kekhawatiran harian (effect size sedang). '
        'Komponen standar CBT untuk GAD sejak Borkovec dkk. (1983). '
        'Catatan: pada GAD dengan keyakinan kuat bahwa khawatir itu berbahaya, '
        'terapi metakognitif (MCT, Wells 2009) mungkin lebih cocok.',
    steps: [
      ExerciseStep('Tulis kekhawatiranmu',
          'Apa yang sedang kamu khawatirkan sekarang? Tulis apa adanya. '
          'Mengeluarkannya dari kepala ke tulisan sudah meringankan beban kognitif.',
          inputHint: 'Aku khawatir bahwa...'),
      ExerciseStep('Nyata atau hipotetis?',
          'Apakah ini masalah NYATA yang bisa ditindaklanjuti hari ini, '
          'atau skenario HIPOTETIS ("bagaimana jika...") yang belum tentu terjadi?',
          inputHint: 'Ini adalah masalah (nyata/hipotetis) karena...'),
      ExerciseStep('Satu langkah kecil jika nyata',
          'Jika nyata dan bisa ditindaklanjuti: tulis SATU langkah kecil hari ini. '
          'Jika hipotetis atau belum bisa ditindaklanjuti, tulis "belum bisa sekarang".',
          inputHint: 'Langkah kecil yang bisa kulakukan...'),
      ExerciseStep('Jadwalkan waktu khawatir',
          'Tentukan satu waktu spesifik hari ini sebagai waktu khawatir (contoh: 18.00, 15 menit). '
          'Di luar jadwal itu: "Sudah kucatat. Akan kupikir pukul ___."',
          inputHint: 'Waktu khawatirku hari ini: pukul...'),
      ExerciseStep('Kembali ke saat ini',
          'Pilih SATU hal konkret yang akan kamu lakukan sekarang. '
          'Bertindak adalah cara paling efektif memutus spiral kekhawatiran.',
          inputHint: 'Sekarang aku akan...'),
    ],
  ),

  // ─────────────────────── CBT REFRAMING ───────────────────────
  CopingExercise(
    id: 'thought-record',
    title: 'Catatan Pikiran (Thought Record)',
    category: 'CBT Reframing',
    minutes: 10,
    description: 'Uji pikiran otomatis dengan bukti nyata — alat inti terapi kognitif Beck.',
    icon: Icons.psychology,
    kind: ExerciseKind.journal,
    overview:
        'Thought record adalah alat utama restrukturisasi kognitif dalam CBT. '
        'Aaron Beck menemukan bahwa depresi dan kecemasan dipertahankan oleh pikiran '
        'otomatis — pikiran cepat yang muncul tanpa disadari dan mewarnai seluruh '
        'interpretasi kita. Thought record memperlambat proses ini: menulis situasi, '
        'pikiran, emosi, memeriksa buktinya, menyusun perspektif seimbang, lalu '
        'menilai ulang emosi. Format 7 kolom standar Beck Institute digunakan di sini.',
    benefits: [
      'Mengurangi intensitas emosi negatif secara terukur',
      'Mengubah pola pikir otomatis yang menyakitkan',
      'Melatih berpikir lebih fleksibel dan realistis',
      'Fondasi dari hampir semua intervensi CBT',
    ],
    evidence:
        'Dasar ilmiah: Thought record adalah komponen paling banyak diteliti dalam CBT. '
        'Beck dkk. (1979, Cognitive Therapy of Depression) adalah landasan awalnya. '
        'CBT memiliki lebih dari 400 RCT dengan efektivitas tinggi untuk depresi, '
        'kecemasan, dan PTSD (Hofmann dkk., 2012, Cognitive Behaviour Therapy). '
        'Restrukturisasi kognitif dikaitkan dengan penurunan aktivasi amigdala dan '
        'peningkatan regulasi emosi prefrontal (DeRubeis dkk., 2008, Nature Reviews Neuroscience).',
    steps: [
      ExerciseStep('Situasi',
          'Apa yang terjadi? Deskripsikan faktanya saja — di mana, kapan, bersama siapa. '
          'Belum saatnya menilai, hanya mendeskripsikan seperti kamera.',
          inputHint: 'Tadi pagi saat...'),
      ExerciseStep('Pikiran otomatis',
          'Apa yang terlintas di pikiranmu saat itu? Tulis kata per kata. '
          'Seberapa besar kamu percaya pikiran ini (0-100%)?',
          inputHint: 'Aku pikir... (kepercayaan: ...%)'),
      ExerciseStep('Emosi dan intensitas',
          'Emosi apa yang kamu rasakan? Beri nama spesifik (cemas, sedih, marah, malu) '
          'dan nilai intensitasnya 0-100%.',
          inputHint: 'Cemas 80%, sedih 60%...'),
      ExerciseStep('Bukti yang mendukung',
          'Fakta apa yang mendukung pikiran otomatis tadi? '
          'Pisahkan FAKTA dari TAFSIRAN: "dia tidak membalas pesanku" = fakta; '
          '"dia pasti marah padaku" = tafsiran.',
          inputHint: 'Fakta yang mendukung: ...'),
      ExerciseStep('Bukti yang menentang',
          'Fakta apa yang TIDAK cocok dengan pikiran otomatis itu? '
          'Bayangkan kamu jadi pengacara yang membela dirimu.',
          inputHint: 'Fakta yang menentang: ...'),
      ExerciseStep('Pikiran alternatif yang seimbang',
          'Berdasarkan semua bukti, susun pikiran yang lebih realistis dan seimbang — '
          'bukan yang paling positif, tapi yang paling akurat. '
          'Seberapa besar kamu percaya pikiran baru ini (0-100%)?',
          inputHint: 'Cara lain melihatnya: ... (kepercayaan: ...%)'),
      ExerciseStep('Nilai ulang emosi (kolom 7 standar Beck)',
          'Sekarang, seberapa besar kamu masih percaya pikiran otomatis tadi (0-100%)? '
          'Emosi apa yang kamu rasakan dan seberapa kuat? '
          'Penurunan intensitas emosi adalah tanda restrukturisasi kognitif berhasil.',
          inputHint: 'Kepercayaan pikiran lama sekarang: ...% | Emosi sekarang: ...'),
    ],
  ),

  CopingExercise(
    id: 'cognitive-distortions',
    title: 'Kenali Distorsi Kognitif',
    category: 'CBT Reframing',
    minutes: 7,
    description: 'Identifikasi pola pikir yang memelintir kenyataan dan tulis ulang dengan perspektif seimbang.',
    icon: Icons.lightbulb_outline,
    kind: ExerciseKind.journal,
    overview:
        'Aaron Beck (1960-an) menemukan bahwa depresi dipertahankan oleh triad kognitif negatif: '
        'pandangan negatif tentang diri, dunia, dan masa depan — semuanya diproses melalui '
        'distorsi kognitif yang sistematis. David Burns (1980, Feeling Good) '
        'mempopulerkan daftar 10 distorsi kognitif yang kini digunakan di seluruh dunia. '
        'Mengenali namanya menciptakan jarak psikologis antara kamu dan pikiran itu.',
    benefits: [
      'Mengenali pola pikir berulang yang menyakitkan',
      'Mengurangi self-criticism dan rasa malu',
      'Fondasi untuk menggunakan thought record secara efektif',
      'Meningkatkan kesadaran diri kognitif jangka panjang',
    ],
    evidence:
        'Dasar ilmiah: Identifikasi distorsi kognitif adalah langkah pertama restrukturisasi '
        'kognitif dalam CBT (Beck, 1979; Burns, 1980, Feeling Good). '
        'Kemampuan mengenali distorsi kognitif berkorelasi dengan penurunan gejala '
        'depresi dan kecemasan (Rnic dkk., 2016, Clinical Psychology Review). '
        'Burns Cognitive Distortion Checklist memiliki validitas baik sebagai alat ukur klinis. '
        'Latihan paling efektif jika dilakukan rutin — makin sering, makin cepat '
        'distorsi dikenali sebelum mempengaruhi emosi.',
    steps: [
      ExerciseStep('Kenali 6 distorsi paling umum',
          '1. Pikiran hitam-putih: selalu atau tidak pernah, tanpa nuansa tengah.\n'
          '2. Katastrofisasi: membayangkan skenario terburuk sebagai kepastian.\n'
          '3. Membaca pikiran: merasa tahu pasti apa yang dipikirkan orang lain.\n'
          '4. Personalisasi: menyalahkan diri atas hal yang sebagian di luar kendalimu.\n'
          '5. Generalisasi berlebihan: satu kejadian buruk = selalu begini.\n'
          '6. Penalaran emosional: aku merasa bodoh, jadi aku pasti bodoh.'),
      ExerciseStep('Tulis pikiran yang menyakitkan',
          'Pikiran negatif apa yang paling sering muncul akhir-akhir ini? '
          'Tulis apa adanya, seakurat mungkin.',
          inputHint: 'Pikiranku adalah...'),
      ExerciseStep('Cocokkan polanya',
          'Dari 6 distorsi di atas, mana yang paling mirip dengan pikiranmu? '
          'Boleh lebih dari satu. Memberi nama sudah mengurangi kekuatan pikiran itu.',
          inputHint: 'Pikiran ini mirip dengan... karena...'),
      ExerciseStep('Perspektif sahabat',
          'Bayangkan sahabat baikmu datang dengan pikiran yang persis sama. '
          'Apa yang akan kamu katakan padanya dengan jujur dan penuh perhatian? '
          'Tulis nasihat itu — lalu terapkan pada dirimu sendiri.',
          inputHint: 'Aku akan bilang padanya...'),
    ],
  ),

  // ─────────────────────── REFLEKSI ───────────────────────
  CopingExercise(
    id: 'three-good-things',
    title: 'Tiga Hal Baik',
    category: 'Refleksi',
    minutes: 5,
    description: 'Catat tiga hal yang berjalan baik hari ini beserta alasannya — melawan negativity bias.',
    icon: Icons.favorite,
    kind: ExerciseKind.journal,
    overview:
        'Otak manusia memiliki negativity bias bawaan — secara evolusioner lebih mudah '
        'mengingat ancaman daripada hal baik. Three Good Things (What Went Well) '
        'adalah latihan psikologi positif yang secara sengaja melawan bias ini. '
        'Menulis tiga hal baik BESERTA penyebabnya setiap hari melatih otak memberi '
        'perhatian lebih seimbang pada pengalaman positif.',
    benefits: [
      'Meningkatkan kebahagiaan secara terukur',
      'Menurunkan gejala depresi ringan',
      'Melatih perhatian pada hal-hal bermakna',
      'Efek bertahan hingga 6 bulan jika dilakukan rutin',
    ],
    evidence:
        'Dasar ilmiah: Seligman dkk. (2005, American Psychologist) — studi dengan '
        '577 partisipan menunjukkan Three Good Things selama 1 minggu meningkatkan '
        'kebahagiaan dan menurunkan gejala depresi secara signifikan, '
        'dengan efek bertahan 6 bulan pada yang melanjutkan. '
        'Catatan kritis: review Sin & Lyubomirsky (2009) menunjukkan effect size '
        'bervariasi antar individu. Kolom mengapa (penyebab hal baik) adalah '
        'bagian terpenting secara ilmiah — tanpa itu efeknya lebih lemah.',
    steps: [
      ExerciseStep('Hal baik pertama',
          'Tulis SATU hal yang berjalan baik hari ini — sekecil apapun. '
          'Senyuman dari orang asing, kopi yang enak, pekerjaan yang selesai. Semua valid.',
          inputHint: 'Hari ini berjalan baik ketika...'),
      ExerciseStep('Hal baik kedua',
          'Satu lagi. Jika susah menemukan, ingat: adakah momen singkat yang '
          'membuatmu merasa aman, nyaman, atau terhubung dengan seseorang?',
          inputHint: 'Hal baik berikutnya adalah...'),
      ExerciseStep('Hal baik ketiga',
          'Satu lagi untuk melengkapi tiga. Tidak harus besar — '
          'konsistensi harian lebih penting daripada besarnya hal yang ditulis.',
          inputHint: 'Dan satu lagi...'),
      ExerciseStep('Mengapa itu terjadi? (bagian terpenting)',
          'Untuk setiap hal baik, tulis MENGAPA itu terjadi. '
          'Apa peranmu? Siapa yang berkontribusi? '
          'Penelitian Seligman: langkah mengapa ini yang menghasilkan efek terbesar.',
          inputHint: 'Hal-hal itu terjadi karena...'),
    ],
  ),

  CopingExercise(
    id: 'behavioral-activation',
    title: 'Aktivasi Perilaku',
    category: 'Refleksi',
    minutes: 8,
    description: 'Rencanakan aktivitas bermakna dan uji apakah prediksi mood-mu benar-benar akurat.',
    icon: Icons.directions_walk,
    kind: ExerciseKind.journal,
    overview:
        'Saat depresi atau lesu, kita menarik diri dari aktivitas — dan penarikan diri '
        'memperburuk mood, membentuk lingkaran setan. Aktivasi Perilaku (BA) memutus '
        'lingkaran ini dengan bergerak lebih dulu, sebelum mood membaik. '
        'Kunci mekanismenya: orang dengan depresi secara sistematis meremehkan seberapa '
        'menyenangkan aktivitas — prediksi mereka hampir selalu lebih negatif dari kenyataannya.',
    benefits: [
      'Memutus siklus penarikan diri dan depresi',
      'Membuktikan bahwa prediksi mood sering keliru',
      'Membangun momentum dari aktivitas kecil ke besar',
      'Menambah pengalaman positif secara aktif',
    ],
    evidence:
        'Dasar ilmiah: Jacobson dkk. (1996, Journal of Consulting and Clinical Psychology) — '
        'BA saja sama efektifnya dengan CBT penuh untuk depresi. '
        'Dimidjian dkk. (2006, JCCP) mengkonfirmasi BA lebih efektif dari CT untuk depresi berat. '
        'Mekanisme predicted vs. actual pleasure: orang dengan depresi mengalami defisit '
        'motivasi/prediksi, bukan defisit kemampuan menikmati — ketika mencoba aktivitas, '
        'mereka menikmatinya sama seperti orang tanpa depresi '
        '(Kieslich dkk., 2022, Psychological Medicine).',
    steps: [
      ExerciseStep('Pilih aktivitas yang pernah kamu nikmati',
          'Pilih sesuatu ringan dan konkret: jalan 10 menit, menelepon teman, '
          'merapikan satu sudut meja, membaca 5 halaman, mendengarkan satu lagu. '
          'Makin kecil makin baik — mudah dimulai adalah yang terpenting.',
          inputHint: 'Aktivitas yang akan kulakukan: ...'),
      ExerciseStep('Tentukan kapan dan di mana',
          'Waktu dan tempat spesifik meningkatkan kemungkinan terlaksana. '
          '"Besok pagi" lebih lemah dari "Besok pukul 08.00 di kamar sebelum sarapan".',
          inputHint: 'Aku akan melakukannya: hari... pukul... di...'),
      ExerciseStep('Prediksi seberapa menyenangkan (0-10)',
          'Sebelum melakukan, prediksi seberapa menyenangkan menurutmu (0-10). '
          'Tulis angkanya sekarang — ini penting untuk dibandingkan nanti.',
          inputHint: 'Prediksi kenikmatan: .../10 | Karena aku merasa...'),
      ExerciseStep('Catat hasil aktual setelah selesai',
          'Kembali setelah melakukan aktivitas. Seberapa menyenangkan kenyataannya (0-10)? '
          'Bagi kebanyakan orang dengan mood rendah, aktual lebih tinggi dari prediksi — '
          'ini bukti nyata bahwa pikiranmu tidak selalu akurat tentang kesenangan.',
          inputHint: 'Kenyataannya: .../10 | Perbedaan dari prediksi: ...'),
    ],
  ),

  CopingExercise(
    id: 'self-compassion',
    title: 'Jeda Welas Asih',
    category: 'Refleksi',
    minutes: 5,
    description: 'Perlakukan dirimu seperti kamu memperlakukan sahabat baik — tiga komponen Kristin Neff.',
    icon: Icons.volunteer_activism,
    kind: ExerciseKind.guided,
    overview:
        'Self-compassion didefinisikan Kristin Neff (2003) sebagai tiga komponen yang '
        'bekerja bersama: (1) Mindfulness — mengakui rasa sakit tanpa menghindarinya, '
        '(2) Common humanity — menyadari bahwa penderitaan adalah bagian universal dari '
        'pengalaman manusia, bukan kelemahan pribadi, dan (3) Self-kindness — bersikap '
        'hangat pada diri sendiri daripada menghakimi. '
        'Jeda Welas Asih adalah latihan singkat Neff & Germer yang mengaktifkan '
        'ketiga komponen dalam beberapa menit.',
    benefits: [
      'Mengurangi kritik diri yang berlebihan',
      'Menenangkan rasa malu dan rasa gagal',
      'Membangun ketangguhan emosi (resiliensi)',
      'Menurunkan kecemasan, depresi, dan perfeksionisme',
    ],
    evidence:
        'Dasar ilmiah: Neff (2003, Self and Identity) memvalidasi Self-Compassion Scale — '
        'self-compassion berkorelasi negatif kuat dengan depresi, kecemasan, dan perfeksionisme. '
        'RCT program Mindful Self-Compassion (MSC) Neff & Germer menunjukkan peningkatan '
        'signifikan kesejahteraan dan penurunan depresi, kecemasan, stres '
        '(Germer & Neff, 2013, Journal of Clinical Psychology). '
        'Meta-analisis MacBeth & Gumley (2012, Clinical Psychology Review): 14 studi, '
        'self-compassion berkorelasi kuat dengan kesehatan mental lebih baik (r = -0.54). '
        'Sentuhan fisik di dada memicu pelepasan oksitosin dan meredam respons ancaman '
        '(Porges, 2011, Polyvagal Theory).',
    caution: 'Bagi sebagian orang, self-compassion awalnya terasa asing atau memicu emosi kuat — ini normal. Jika muncul rasa sedih mendalam, beri waktu untuk itu; tidak perlu dihentikan.',
    steps: [
      ExerciseStep('Akui momen yang sulit (Mindfulness)',
          'Hentikan sejenak apa yang sedang kamu lakukan. '
          'Katakan dalam hati: "Ini saat yang sulit" atau "Ini terasa menyakitkan." '
          'Mengakui rasa sakit — bukan menghindarinya — adalah langkah pertama.'),
      ExerciseStep('Kamu tidak sendirian (Common Humanity)',
          'Katakan pada dirimu: "Penderitaan adalah bagian dari menjadi manusia. '
          'Banyak orang juga merasakan hal yang serupa saat ini." '
          'Ini bukan mengatakan situasimu tidak penting — ini mengatakan kamu tidak terisolasi.'),
      ExerciseStep('Sentuhan yang menenangkan (Self-Kindness fisik)',
          'Letakkan satu atau kedua tangan di dada. Rasakan kehangatan dan tekanan ringannya. '
          'Sentuhan fisik ini merangsang sistem penenangan diri melalui oksitosin — '
          'sama seperti ketika seseorang yang kamu percaya memelukmu.'),
      ExerciseStep('Kata-kata yang kamu butuhkan (Self-Kindness verbal)',
          'Apa yang paling ingin kamu dengar saat ini dari seseorang yang peduli padamu? '
          'Ucapkan kata-kata itu pada dirimu sendiri. Contoh: "Kamu sudah berusaha keras", '
          '"Tidak apa-apa tidak sempurna", "Kamu berhak istirahat." '
          'Pilih kata yang terasa paling jujur dan hangat untukmu.'),
    ],
  ),
];
