import 'package:flutter/material.dart';

// ============================================================================
// HALAMAN UTAMA: EDUKASI KESEHATAN
// ============================================================================
class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  static const Color primaryTeal = Color(0xFF0098B9);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color subSlate = Color(0xFF475569);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BAR
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  _buildBackButton(context),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edukasi Kesehatan',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: darkSlate,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Panduan hidup sehat untuk mendukung kesehatan jantung',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: subSlate,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // KONTEN UTAMA
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER PENGANTAR
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE3F7FB), Color(0xFFD0F0F7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFB8E6F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryTeal.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: primaryTeal,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jaga Jantung Tetap Prima',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: darkSlate,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Pahami langkah penting sehari-hari untuk mendukung pemulihan dan kualitas hidup optimal.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: subSlate,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Pilihan Topik Edukasi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih materi yang ingin Anda pelajari di bawah ini:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),

                    const SizedBox(height: 14),

                    // CARD 1: POLA MAKAN SEHAT
                    _buildMenuCard(
                      context,
                      title: 'Pola Makan Sehat',
                      description: 'Panduan nutrisi tepat, pemilihan bahan makanan bergizi, dan pembatasan garam serta lemak untuk penderita penyakit jantung.',
                      tag: 'Nutrisi & Makanan',
                      icon: Icons.restaurant_rounded,
                      iconBgColor: const Color(0xFFE0F7FA),
                      iconColor: const Color(0xFF0098B9),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PolaMakanSehatPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // CARD 2: AKTIVITAS FISIK
                    _buildMenuCard(
                      context,
                      title: 'Aktivitas Fisik',
                      description: 'Aktivitas fisik yang aman, terukur, dan bertahap sesuai kemampuan serta kondisi kesehatan jantung masing-masing.',
                      tag: 'Latihan & Gerak',
                      icon: Icons.directions_walk_rounded,
                      iconBgColor: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AktivitasFisikPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // CARD 3: KEBIASAAN SEHAT
                    _buildMenuCard(
                      context,
                      title: 'Kebiasaan Sehat',
                      description: 'Menjaga pola istirahat yang cukup, menghindari rokok, mengelola stres emosional, dan kepatuhan dalam perawatan medis.',
                      tag: 'Gaya Hidup',
                      icon: Icons.spa_rounded,
                      iconBgColor: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF16A34A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KebiasaanSehatPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // CATATAN KAKI INFORMASI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: lightBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorder),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Informasi dalam edukasi ini bertujuan sebagai panduan umum. Selalu konsultasikan kondisi dan kebutuhan spesifik Anda dengan tenaga kesehatan.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildBackButton(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required String tag,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Icon(icon, color: iconColor, size: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: darkSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: lightBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. DETAIL PAGE: POLA MAKAN SEHAT
// ============================================================================
class PolaMakanSehatPage extends StatelessWidget {
  const PolaMakanSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BAR
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  EducationPage._buildBackButton(context),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pola Makan Sehat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Panduan makanan bergizi untuk kesehatan jantung',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER RINGKASAN
                    _buildOverviewCard(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Pola Makan Bagi Pasien Jantung',
                      description: 'Membahas pola makan sehat untuk orang yang sudah memiliki penyakit jantung, berfokus pada pemilihan makanan alami berkualitas dan pembiasaan waktu makan yang mendukung kerja jantung.',
                      color: const Color(0xFF0098B9),
                      bgColor: const Color(0xFFE0F7FA),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Materi Edukasi Nutrisi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // MATERI A: Perbanyak Makanan Sehat
                    _buildDetailCard(
                      label: 'A',
                      title: 'Perbanyak Makanan Sehat',
                      tag: 'Direkomendasikan',
                      tagColor: const Color(0xFF15803D),
                      tagBgColor: const Color(0xFFDCFCE7),
                      icon: Icons.eco_rounded,
                      iconColor: const Color(0xFF16A34A),
                      iconBgColor: const Color(0xFFDCFCE7),
                      summary: 'Penuhi kebutuhan harian dengan makanan segar kaya serat, antioksidan, dan lemak baik yang menjaga elastisitas pembuluh darah.',
                      points: const [
                        'Memperbanyak buah dan sayuran segar aneka warna sebagai sumber serat larut dan vitamin.',
                        'Memilih ikan berlemak sehat kaya asam lemak Omega-3 (seperti salmon, kembung, tuna, tongkol).',
                        'Memilih kacang-kacangan dan biji-bijian utuh (seperti oatmeal, kedelai, kacang almond) untuk menekan kolesterol LDL.',
                        'Menjaga menu makanan tetap beragam dan seimbang agar kebutuhan nutrisi harian tercukupi.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI B: Batasi Lemak, Gula, dan Garam
                    _buildDetailCard(
                      label: 'B',
                      title: 'Batasi Lemak, Gula, dan Garam',
                      tag: 'Perlu Dibatasi',
                      tagColor: const Color(0xFFB45309),
                      tagBgColor: const Color(0xFFFEF3C7),
                      icon: Icons.tune_rounded,
                      iconColor: const Color(0xFFD97706),
                      iconBgColor: const Color(0xFFFEF3C7),
                      summary: 'Konsumsi lemak jenuh, gula, dan natrium berlebih berpotensi menaikkan tekanan darah serta memperberat beban pompa jantung.',
                      points: const [
                        'Membatasi makanan tinggi lemak jenuh dan lemak trans yang dapat mempersempit rongga pembuluh darah.',
                        'Membatasi makanan dan minuman tinggi gula untuk mengontrol berat badan serta mencegah risiko diabetes.',
                        'Membatasi makanan tinggi garam (natrium maksimal 1 sendok teh atau 2.000 mg/hari) demi menjaga kestabilan tekanan darah.',
                        'Menghindari konsumsi camilan atau bumbu penyedap instan secara berlebihan.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI C: Kurangi Makanan yang Kurang Sehat
                    _buildDetailCard(
                      label: 'C',
                      title: 'Kurangi Makanan yang Kurang Sehat',
                      tag: 'Hindari / Kurangi',
                      tagColor: const Color(0xFFB91C1C),
                      tagBgColor: const Color(0xFFFEE2E2),
                      icon: Icons.no_food_outlined,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      summary: 'Beberapa jenis olahan makanan memicu peradangan pada pembuluh darah dan menaikkan kolesterol jahat dalam darah.',
                      points: const [
                        'Makanan yang digoreng (deep fried): Minyak goreng yang dipanaskan berulang kali menghasilkan lemak trans berbahaya.',
                        'Makanan tinggi lemak hewani: Daging merah berlemak tebal dan jeroan memicu penumpukan plak koroner.',
                        'Makanan bersantan kental: Masakan santan yang dihangatkan berulang dapat meningkatkan kadar kolesterol darah.',
                        'Makanan siap saji & olahan (ultra-processed): Mengandung kadar garam, pengawet, dan lemak tersembunyi yang tinggi.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI D: Atur Waktu Makan
                    _buildDetailCard(
                      label: 'D',
                      title: 'Atur Waktu Makan',
                      tag: 'Kebiasaan Rutin',
                      tagColor: const Color(0xFF0369A1),
                      tagBgColor: const Color(0xFFE0F2FE),
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFF0284C7),
                      iconBgColor: const Color(0xFFE0F2FE),
                      summary: 'Jadwal makan yang tertata baik menjaga ritme metabolisme tubuh dan stabilitas energi jantung secara teratur.',
                      points: const [
                        'Menjaga waktu makan tetap teratur setiap hari (sarapan, makan siang, dan makan malam).',
                        'Tidak membiasakan makan dengan waktu yang tidak teratur atau sering melewatkan jam makan utama.',
                        'Menjaga pola makan secara konsisten agar tubuh tidak mengalami stres metabolisme.',
                        'Memberi jeda minimal 2-3 jam antara makan malam dan waktu tidur agar lambung tidak tertekan.',
                      ],
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL KEMBALI
                    _buildBackButtonBottom(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. DETAIL PAGE: AKTIVITAS FISIK
// ============================================================================
class AktivitasFisikPage extends StatelessWidget {
  const AktivitasFisikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BAR
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  EducationPage._buildBackButton(context),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivitas Fisik',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Panduan aktivitas gerak aman bagi penderita jantung',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER RINGKASAN
                    _buildOverviewCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Aktivitas Fisik Aman & Terukur',
                      description: 'Aktivitas fisik sangat bermanfaat menjaga kekuatan pompa jantung dan kebugaran tubuh, asalkan dilakukan secara sederhana, bertahap, dan disesuaikan dengan kapasitas tubuh masing-masing.',
                      color: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFE0F2FE),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Pilihan Bentuk Aktivitas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // MATERI A: Jalan Kaki
                    _buildDetailCard(
                      label: 'A',
                      title: 'Jalan Kaki',
                      tag: 'Aktivitas Dasar',
                      tagColor: const Color(0xFF0369A1),
                      tagBgColor: const Color(0xFFE0F2FE),
                      icon: Icons.directions_walk_rounded,
                      iconColor: const Color(0xFF0284C7),
                      iconBgColor: const Color(0xFFE0F2FE),
                      summary: 'Salah satu aktivitas fisik terbaik, minim risiko cedera, serta sangat mudah dilakukan untuk menjaga kelancaran aliran darah.',
                      points: const [
                        'Dilakukan secara bertahap mulai dari 10-15 menit per hari dengan langkah santai di lintasan yang rata.',
                        'Dapat ditingkatkan secara perlahan hingga 20-30 menit jika tidak ada keluhan sesak napas atau lelah berlebih.',
                        'Dianjurkan berjalan santai di waktu pagi atau sore hari saat suhu lingkungan sejuk dan segar.',
                        'Gunakan alas kaki yang nyaman dan tetap terhidrasi dengan air putih secukupnya.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI B: Latihan Pernapasan
                    _buildDetailCard(
                      label: 'B',
                      title: 'Latihan Pernapasan',
                      tag: 'Relaksasi Jantung',
                      tagColor: const Color(0xFF0098B9),
                      tagBgColor: const Color(0xFFE0F7FA),
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF0098B9),
                      iconBgColor: const Color(0xFFE0F7FA),
                      summary: 'Latihan pernapasan dalam (deep breathing) yang tenang dan teratur membantu menstabilkan detak jantung serta meredakan ketegangan tubuh.',
                      points: const [
                        'Duduk dalam posisi tegak dan rileks di kursi yang nyaman, letakkan tangan di perut.',
                        'Tarik napas perlahan melalui hidung selama 3-4 detik hingga rongga dada dan perut mengembang.',
                        'Hembuskan napas perlahan melalui mulut secara tenang selama 4-6 detik.',
                        'Lakukan secara teratur 5-10 menit setiap hari atau saat merasa cemas dan tegang.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI C: Mobilisasi Bertahap
                    _buildDetailCard(
                      label: 'C',
                      title: 'Mobilisasi Bertahap',
                      tag: 'Penyesuaian Gerak',
                      tagColor: const Color(0xFF7E22CE),
                      tagBgColor: const Color(0xFFF3E8FF),
                      icon: Icons.accessibility_new_rounded,
                      iconColor: const Color(0xFF9333EA),
                      iconBgColor: const Color(0xFFF3E8FF),
                      summary: 'Gerak tubuh yang ditingkatkan secara bertingkat agar otot jantung beradaptasi dengan baik tanpa mengalami beban mendadak.',
                      points: const [
                        'Dimulai dari peregangan ringan sendi pergelangan tangan, kaki, dan leher saat duduk atau berbaring.',
                        'Lanjutkan dengan aktivitas berpindah posisi (duduk ke berdiri) secara perlahan untuk mencegah pusing.',
                        'Lakukan tugas harian ringan di rumah secara bertahap tanpa mengangkat beban berat.',
                        'Selalu beristirahat sejenak di antara aktivitas jika napas mulai terasa berat.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI D: Aktivitas Aerobik
                    _buildDetailCard(
                      label: 'D',
                      title: 'Aktivitas Aerobik',
                      tag: 'Kebugaran Terukur',
                      tagColor: const Color(0xFF15803D),
                      tagBgColor: const Color(0xFFDCFCE7),
                      icon: Icons.fitness_center_rounded,
                      iconColor: const Color(0xFF16A34A),
                      iconBgColor: const Color(0xFFDCFCE7),
                      summary: 'Latihan aerobik intensitas rendah hingga sedang membantu melatih efisiensi kerja otot jantung dan kapasitas paru.',
                      points: const [
                        'Pilihan aktivitas meliputi senam jantung ringan, bersepeda statis tanpa beban berat, atau jalan santai teratur.',
                        'Menyesuaikan intensitas latihan dengan kemampuan fisik (gunakan prinsip \'Talk Test\': masih dapat berbicara nyaman tanpa tersengal-sengal).',
                        'Awali selalu dengan pemanasan 5 menit dan akhiri dengan pendinginan 5 menit.',
                        'Hindari olahraga kompetitif atau latihan yang menahan napas (manuver valsalva).',
                      ],
                    ),

                    const SizedBox(height: 18),

                    // CATATAN KHUSUS TENAGA KESEHATAN (HIGHLIGHT BOX)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.health_and_safety_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PENTING DIPERHATIKAN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF92400E),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Orang dengan penyakit jantung perlu menyesuaikan intensitas dan durasi aktivitas fisik dengan kondisi masing-masing serta selalu mengikuti anjuran dan rekomendasi dari dokter atau tenaga kesehatan yang merawat.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.45,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL KEMBALI
                    _buildBackButtonBottom(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. DETAIL PAGE: KEBIASAAN SEHAT
// ============================================================================
class KebiasaanSehatPage extends StatelessWidget {
  const KebiasaanSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BAR
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Row(
                children: [
                  EducationPage._buildBackButton(context),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kebiasaan Sehat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pola hidup sehari-hari untuk menjaga kondisi jantung',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER RINGKASAN
                    _buildOverviewCard(
                      icon: Icons.spa_rounded,
                      title: 'Kebiasaan Baik Setiap Hari',
                      description: 'Membahas kebiasaan sehari-hari yang dapat membantu menjaga kondisi jantung tetap stabil, seperti menjaga pola istirahat, menghindari rokok, mengelola stres, dan mengikuti perawatan medis yang dianjurkan.',
                      color: const Color(0xFF16A34A),
                      bgColor: const Color(0xFFDCFCE7),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Pilar Kebiasaan Sehat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // MATERI A: Hindari Rokok
                    _buildDetailCard(
                      label: 'A',
                      title: 'Hindari Rokok',
                      tag: 'Wajib Dihindari',
                      tagColor: const Color(0xFFB91C1C),
                      tagBgColor: const Color(0xFFFEE2E2),
                      icon: Icons.smoke_free_rounded,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      summary: 'Menghindari kebiasaan merokok dan paparan asap rokok adalah langkah paling efektif untuk mencegah kerusakan pembuluh darah koroner.',
                      points: const [
                        'Zat beracun dan nikotin dalam rokok merusak dinding arteri dan mempercepat penumpukan plak aterosklerosis.',
                        'Merokok menyempitkan pembuluh darah, menaikkan denyut nadi, serta menurunkan kadar oksigen yang dibawa ke otot jantung.',
                        'Hindari pula paparan sebagai perokok pasif karena memiliki dampak bahaya yang sama tingginya.',
                        'Berhenti merokok memberikan dampak perbaikan sirkulasi darah jantung secara signifikan dalam waktu singkat.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI B: Istirahat yang Cukup
                    _buildDetailCard(
                      label: 'B',
                      title: 'Istirahat yang Cukup',
                      tag: 'Pemulihan Organ',
                      tagColor: const Color(0xFF0369A1),
                      tagBgColor: const Color(0xFFE0F2FE),
                      icon: Icons.bedtime_rounded,
                      iconColor: const Color(0xFF0284C7),
                      iconBgColor: const Color(0xFFE0F2FE),
                      summary: 'Waktu tidur yang berkualitas dan cukup memberi kesempatan bagi organ jantung untuk beristirahat dan menstabilkan tekanan darah.',
                      points: const [
                        'Menjaga kecukupan waktu istirahat dan tidur berkualitas selama 7-8 jam setiap malam.',
                        'Menjaga jam tidur dan bangun secara teratur setiap hari untuk keselarasan ritme sirkadian tubuh.',
                        'Kurang tidur kronis terbukti meningkatkan hormon stres dan memicu kenaikan tekanan darah tinggi.',
                        'Ciptakan suasana kamar tidur yang tenang, sejuk, dan hindari paparan layar gawai menjelang tidur.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI C: Kelola Stres
                    _buildDetailCard(
                      label: 'C',
                      title: 'Kelola Stres',
                      tag: 'Kesehatan Emosional',
                      tagColor: const Color(0xFF15803D),
                      tagBgColor: const Color(0xFFDCFCE7),
                      icon: Icons.self_improvement_rounded,
                      iconColor: const Color(0xFF16A34A),
                      iconBgColor: const Color(0xFFDCFCE7),
                      summary: 'Kondisi emosional yang terkendali melindungi jantung dari lonjakan hormon adrenalin dan kortisol yang memicu hipertensi.',
                      points: const [
                        'Mengenali pemicu stres harian dan meluangkan waktu untuk relaksasi, ibadah, meditasi, atau hobi santai.',
                        'Membiasakan berbincang dan berbagi cerita dengan keluarga atau sahabat saat menghadapi rasa cemas.',
                        'Mengatur ritme kerja dan beban pikiran agar tidak mengalami kelelahan mental yang berlebihan.',
                        'Menjaga pikiran positif dan menghindari reaksi kemarahan mendadak yang membebani kinerja pompa jantung.',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // MATERI D: Ikuti Perawatan
                    _buildDetailCard(
                      label: 'D',
                      title: 'Ikuti Perawatan',
                      tag: 'Kepatuhan Medis',
                      tagColor: const Color(0xFF0098B9),
                      tagBgColor: const Color(0xFFE0F7FA),
                      icon: Icons.medical_services_rounded,
                      iconColor: const Color(0xFF0098B9),
                      iconBgColor: const Color(0xFFE0F7FA),
                      summary: 'Kepatuhan terhadap rencana terapi dokter dan pemeriksaan berkala adalah jaminan terbaik untuk kestabilan kesehatan jantung.',
                      points: const [
                        'Meminum obat-obatan yang diresepkan oleh dokter secara teratur sesuai dosis dan jadwal yang telah ditentukan.',
                        'Melakukan kontrol atau pemeriksaan kesehatan berkala sesuai anjuran untuk memantau fungsi jantung.',
                        'Memantau parameter penting seperti tekanan darah dan denyut nadi secara mandiri di rumah jika dianjurkan.',
                        'Segera berkonsultasi kembali kepada dokter jika merasakan perubahan kondisi atau gejala baru yang mengganggu.',
                      ],
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL KEMBALI
                    _buildBackButtonBottom(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS DETAIL PAGES
// ============================================================================
Widget _buildOverviewCard({
  required IconData icon,
  required String title,
  required String description,
  required Color color,
  required Color bgColor,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(icon, color: color, size: 24)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailCard({
  required String label,
  required String title,
  required String tag,
  required Color tagColor,
  required Color tagBgColor,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  required String summary,
  required List<String> points,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: tagColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          summary,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 10),
        ...points.map((point) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: Color(0xFF0098B9),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

Widget _buildBackButtonBottom(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 46,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(
        Icons.arrow_back_rounded,
        size: 18,
        color: Color(0xFF0098B9),
      ),
      label: const Text(
        'Kembali ke Edukasi Kesehatan',
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0098B9),
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF0098B9), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
