import 'package:flutter/material.dart';
import 'package:heartcare/services/theme_service.dart';

class ArticleDetailPage extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final String description;
  final String content;
  final String date;

  const ArticleDetailPage({
    super.key,
    required this.image,
    required this.category,
    required this.title,
    required this.description,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCoronary = title.toLowerCase().contains('koroner');

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        final Color textColor =
            isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
        final Color headingColor =
            isDark ? Colors.white : const Color(0xFF0F172A);

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.22, 0.6],
                colors: isDark
                    ? const [
                        Color(0xFF1E293B),
                        Color(0xFF131D2E),
                        Color(0xFF0F172A),
                      ]
                    : const [
                        Color(0xFFE8F6FA),
                        Color(0xFFF4FAFC),
                        Color(0xFFF8FAFC),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. TOP BAR NAVIGASI
                          _buildTopNav(context, isDark),

                          const SizedBox(height: 18),

                          // 2. FOTO UTAMA ARTIKEL
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: image.startsWith('http')
                                ? Image.network(
                                    image,
                                    width: double.infinity,
                                    height: 195,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 195,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE0F2FE),
                                        child: Icon(
                                          Icons.favorite_rounded,
                                          color: isDark
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFF0284C7),
                                          size: 60,
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    image,
                                    width: double.infinity,
                                    height: 195,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 195,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE0F2FE),
                                        child: Icon(
                                          Icons.favorite_rounded,
                                          color: isDark
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFF0284C7),
                                          size: 60,
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          const SizedBox(height: 14),

                          // 3. BADGES KATEGORI & DURASI
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF079BC1).withValues(alpha: 0.25)
                                      : const Color(0xFFD9F5FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCoronary ? '6 menit baca' : '5 menit baca',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // 4. JUDUL ARTIKEL
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: headingColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 5. INFO PENULIS & TANGGAL
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                isCoronary
                                    ? 'Kajian Medis • Triyono et al.'
                                    : 'by Tim Medis HeartCare',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Divider(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            thickness: 1,
                            height: 1,
                          ),

                          const SizedBox(height: 16),

                          // ========================================================
                          // FULL TEKS ARTIKEL SCROLL (BACAAN MENGALIR PROFESIONAL)
                          // ========================================================
                          if (isCoronary) ...[
                            // PARAGRAF PEMBUKA (LEAD PARAGRAPH)
                            _buildLeadParagraph(
                              'Penyakit jantung koroner (PJK) merupakan salah satu masalah kesehatan kardiovaskular yang paling umum sekaligus menduduki peringkat teratas penyebab kematian di Indonesia. Penyakit ini terjadi saat pembuluh darah arteri koroner yang bertugas menyuplai darah, oksigen, dan nutrisi penting ke otot jantung mengalami penyempitan atau penyumbatan akibat penumpukan plak kolesterol. Memahami mekanisme penyakit, mengenali tanda-tanda klinis sejak dini, serta mengendalikan faktor-faktor risikonya merupakan kunci terpenting dalam mencegah komplikasi fatal serangan jantung.',
                              textColor,
                            ),

                            _buildSubheading('Beban Epidemiologi PJK di Indonesia dan Global', headingColor),

                            _buildBodyParagraph(
                              'Dalam beberapa tahun terakhir, Indonesia mengalami peningkatan yang signifikan pada kasus penyakit jantung koroner. Berdasarkan data Riset Kesehatan Dasar (Riskesdas), PJK menduduki peringkat ketujuh dalam daftar penyakit tidak menular dengan prevalensi yang terus meningkat di berbagai kelompok usia produktif. Di beberapa provinsi, seperti Sulawesi Selatan, angka prevalensi PJK bahkan tercatat mencapai 1,46% dari total populasi.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Kondisi ini sejalan dengan data Organisasi Kesehatan Dunia (WHO) yang mencatat bahwa penyakit kardiovaskular, termasuk PJK, menyumbang sekitar 9,4 juta kematian di seluruh dunia setiap tahunnya. Selain mengancam kelangsungan hidup, PJK juga menimbulkan beban sosial dan ekonomi yang sangat besar bagi pasien dan keluarga akibat tingginya biaya perawatan medis jangka panjang yang diperlukan.',
                              textColor,
                            ),

                            _buildSubheading('Mekanisme Terjadinya Penyakit Jantung Koroner', headingColor),

                            _buildBodyParagraph(
                              'Otot jantung (miokardium) membutuhkan pasokan darah kaya oksigen secara terus-menerus tanpa henti agar dapat memompa darah ke seluruh tubuh. Pasokan ini dialirkan melalui pembuluh darah arteri koroner kanan dan kiri yang melingkari permukaan jantung.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Penyakit jantung koroner berawal dari proses aterosklerosis, yaitu penumpukan bertahap zat lemak, kolesterol, kalsium, dan sisa seluler (disebut plak ateroma) pada dinding bagian dalam arteri koroner. Akibat penumpukan plak ini, dinding pembuluh darah menjadi kaku, tebal, dan rongga pembuluh darah (lumen) menyempit secara perlahan.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Ketika diameter arteri koroner menyempit lebih dari 50 hingga 70 persen, aliran darah menuju miokardium menjadi terhambat (iskemia miokard). Jika kebutuhan oksigen jantung meningkat—misalnya saat beraktivitas fisik berat atau stres emosional—otot jantung akan mengalami kekurangan suplai oksigen yang menimbulkan rasa nyeri dada hebat. Pada kondisi yang lebih parah, permukaan plak dapat mengalami ruptur (robek), memicu pembentukan bekuan darah (trombus) yang menyumbat total arteri secara mendadak dan menyebabkan serangan jantung (infark miokard akut) hingga kematian mendadak.',
                              textColor,
                            ),

                            _buildSubheading('Tanda dan Gejala Klinis yang Wajib Diwaspadai', headingColor),

                            _buildBodyParagraph(
                              'Gejala penyakit jantung koroner sering kali berkembang secara bertahap dan tidak selalu disadari oleh penderita pada stadium awal. Beberapa gejala klinis utama yang perlu diwaspadai meliputi:',
                              textColor,
                            ),

                            _buildBulletItem(
                              'Nyeri Dada Khas (Angina Pectoris): ',
                              'Gejala paling klasik yang dirasakan penderita berupa rasa dada seperti tertekan, tertindih beban yang sangat berat, dicengkeram kuat, atau rasa panas terbakar di area tengah dada (substernal). Nyeri ini biasanya berlangsung beberapa menit dan dapat dipicu oleh aktivitas fisik atau stres.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Pola Penjalaran Nyeri yang Luas: ',
                              'Karakteristik penting dari angina adalah rasa nyeri yang menjalar dari dada ke leher, rahang bawah, gigi, bahu kiri, tembus ke punggung di antara dua belikat, hingga ke sepanjang lengan kiri sampai jari-jari tangan.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Sesak Napas (Dyspnea): ',
                              'Rasa kesulitan bernapas atau napas terasa pendek dan berat, yang timbul akibat jantung tidak mampu memompa darah dengan efektif untuk memenuhi kebutuhan oksigen jaringan tubuh.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Keringat Dingin (Diaforesis) dan Lemas: ',
                              'Keringat dingin yang mengucur deras secara mendadak tanpa sebab suhu panas, sering kali disertai rasa lemas ekstrem, tubuh gemetar, dan hilangnya tenaga secara tiba-tiba.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Pusing, Rasa Melayang, dan Mual: ',
                              'Penurunan curah jantung menyebabkan aliran darah ke otak berkurang sehingga penderita merasa pusing, limbung, atau pingsan. Sebagian pasien—terutama wanita dan lansia—juga kerap mengeluhkan mual, begah, atau rasa perih di ulu hati yang kerap keliru dianggap sebagai sakit maag biasa.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Palpitasi (Jantung Berdebar): ',
                              'Sensasi denyut jantung yang berdetak sangat kencang, tidak teratur, atau terasa seperti ada detakan yang melompat akibat gangguan sistem kelistrikan jantung.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Faktor Risiko Utama Berdasarkan Bukti Ilmiah', headingColor),

                            _buildBodyParagraph(
                              'Berdasarkan kajian pustaka ilmiah yang dilakukan oleh Dedy Triyono dkk. (2024), terdapat beberapa faktor risiko dominan yang mempercepat proses aterosklerosis pada populasi di Indonesia:',
                              textColor,
                            ),

                            _buildNumberedItem(
                              '1',
                              'Kebiasaan Merokok: ',
                              'Merupakan salah satu faktor risiko modifikasi terbesar. Senyawa beracun dan nikotin dalam rokok merusak lapisan endotel pembuluh darah, memicu vasokonstriksi arteri, meningkatkan kolesterol jahat (LDL), serta menurunkan kolesterol baik (HDL). Berbagai studi menunjukkan perokok memiliki risiko 2 hingga 4 kali lebih besar mengalami serangan jantung fatal dibanding non-perokok.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '2',
                              'Hipertensi (Tekanan Darah Tinggi): ',
                              'Tekanan darah yang tinggi secara terus-menerus merusak integritas dinding arteri dan mempercepat pembentukan plak ateroma. Setiap peningkatan 20 mmHg pada tekanan darah sistolik terbukti menggandakan risiko terjadinya serangan jantung.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '3',
                              'Kadar Kolesterol Tinggi (Dislipidemia): ',
                              'Tingginya kolesterol total dan kolesterol LDL akibat pola makan tinggi lemak jenuh secara langsung mempercepat akumulasi deposit plak pada dinding arteri koroner yang mempersempit aliran darah.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '4',
                              'Diabetes Melitus: ',
                              'Kadar gula darah yang tinggi secara kronis merusak pembuluh darah mikro dan makro di seluruh tubuh serta mengganggu persarafan otonom jantung, sehingga penderita diabetes memiliki risiko morbiditas jantung yang jauh lebih tinggi.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '5',
                              'Inaktivitas Fisik dan Gaya Hidup Sedentari: ',
                              'Kurang berolahraga dan perilaku menetap (kurang bergerak) menurunkan metabolisme lipid, memicu resistensi insulin, serta meningkatkan risiko obesitas yang memperberat kerja jantung.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '6',
                              'Paparan Polusi Udara (Partikulat PM2.5): ',
                              'Paparan polusi udara jangka panjang terbukti memicu reaksi peradangan sistemik (inflamasi vaskular) dan disfungsi endotel yang mempercepat komplikasi kardiovaskular.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '7',
                              'Faktor Genetik dan Riwayat Keluarga: ',
                              'Adanya riwayat keluarga yang menderita penyakit jantung dini meningkatkan predisposisi biologis seseorang, sehingga pemeriksaan kesehatan rutin harus dilakukan sedini mungkin.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Strategi Pencegahan Dini yang Efektif', headingColor),

                            _buildBodyParagraph(
                              'Pencegahan penyakit jantung koroner harus dilakukan secara komprehensif melalui dua pilar pendekatan utama:',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Pertama, Perubahan Gaya Hidup Mandiri. Langkah ini mencakup penghentian total kebiasaan merokok karena perbaikan kesehatan vaskular langsung dimulai segera setelah seseorang berhenti merokok. Selain itu, terapkan pola makan rendah lemak jenuh dan rendah natrium (garam dibatasi maksimal 2.000 mg atau 1 sendok teh per hari), serta perbanyak asupan serat dari sayur-sayuran, buah-buahan segar, dan gandum utuh. Lakukan olahraga aerobik secara teratur minimal 150 menit per minggu, seperti jalan cepat, senam jantung sehat, atau bersepeda santai 30 menit sehari selama 5 hari per minggu untuk meningkatkan HDL dan menjaga tekanan darah tetap stabil.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Kedua, Pencegahan Medis dan Deteksi Dini Berkala. Langkah ini meliputi pemantauan tekanan darah secara berkala guna mendeteksi hipertensi tersembunyi, pemeriksaan laboratorium profil lipid (kolesterol total, LDL, HDL, trigliserida), pemantauan kadar gula darah puasa, serta pemeriksaan rekam jantung (elektrokardiogram / EKG) secara periodik, terutama bagi individu berusia di atas 40 tahun atau memiliki riwayat keluarga penyakit jantung.',
                              textColor,
                            ),

                            _buildSubheading('Kesimpulan', headingColor),

                            _buildBodyParagraph(
                              'Penyakit jantung koroner adalah kondisi kronis yang perkembangannya memakan waktu bertahun-tahun sebelum akhirnya memicu serangan jantung mendadak. Namun, sebagian besar faktor risikonya—seperti merokok, hipertensi, dislipidemia, pola makan tidak sehat, dan kurangnya aktivitas fisik—sebenarnya dapat dicegah dan dikendalikan sejak dini. Dengan meningkatkan literasi kesehatan, mengenali gejala khas seperti angina pectoris, menerapkan pola hidup sehat, serta memanfaatkan fitur skrining dan konsultasi medis rutin, kita dapat melindungi kesehatan jantung dan menurunkan risiko fatal PJK secara nyata.',
                              textColor,
                            ),

                            const SizedBox(height: 12),
                            Divider(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                            const SizedBox(height: 12),

                            _buildSubheading('Daftar Pustaka & Referensi Ilmiah', headingColor),

                            _buildReferenceText(
                              'Triyono, D., Liani, R., Utami, A. W., Tristiyanti, S., & Supriatna, A. (2024). Penyakit Jantung Koroner di Indonesia: Peran Faktor Risiko dan Upaya Pencegahan. Humanis, 17(1), 86–94.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Badan Penelitian dan Pengembangan Kesehatan (Balitbangkes) Kementerian Kesehatan RI. (2022). Riset Kesehatan Dasar (Riskesdas): Prevalensi Penyakit Tidak Menular di Indonesia.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'World Health Organization (WHO). (2021). Cardiovascular Diseases (CVDs) Fact Sheets & Global Mortality Data.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Laksono, S. (2023). Polusi Udara dan Penyakit Kardiovaskular: Tinjauan Pustaka. Menara Medika, 6(1), 55–64.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Iman, B. N., Rafikasitha, R., & Kemalasari, K. (2022). Perancangan dan Implementasi Alat Pendeteksi Dini Penyakit Jantung Koroner. Jurnal Rekayasa Elektrika, 18(4).',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Untoro, M. C. (2023). Penerapan K-Means Clustering Pada Imbalance Dataset Gejala Penyakit Jantung. Ilkomnika, 5(1), 1–7.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Pashar, I. (2024). Hubungan Pola Makan dan Aktivitas Fisik Dengan Penyakit Jantung Koroner Di RSUD Labuang Baji Makassar. JPS, 2(01), 31–42.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Nurhijriah, S. (2022). Pengaruh Aktivitas Fisik, Perilaku Menetap, Status Gizi Terhadap Penyakit Jantung Koroner. Window of Public Health Journal, 3(3), 400–406.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Santosa, W. N., & Baharuddin, B. (2020). Penyakit Jantung Koroner dan Antioksidan. Keluwih Jurnal Kesehatan dan Kedokteran, 1(2), 98–103.',
                              textColor,
                            ),
                          ] else ...[
                            // FORMAT TEKS ARTIKEL LAINNYA
                            _buildLeadParagraph(description, textColor),
                            const SizedBox(height: 10),
                            ...content.split('\n\n').map(
                                  (p) => _buildBodyParagraph(p.trim(), textColor),
                                ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // HEADER NAVIGASI ATAS
  Widget _buildTopNav(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edukasi Kesehatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Informasi kesehatan jantung tepercaya',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // SUBJUDUL ARTIKEL (H2 BERSIH & TEGAS SEPERTI ARTIKEL BERITA MEDIS)
  Widget _buildSubheading(String title, Color headingColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 9),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          height: 1.35,
          letterSpacing: -0.2,
          color: headingColor,
        ),
      ),
    );
  }

  // PARAGRAF LEAD / PEMBUKA TEKS
  Widget _buildLeadParagraph(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 14,
          height: 1.7,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // PARAGRAF REGULER
  Widget _buildBodyParagraph(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.68,
          color: textColor,
        ),
      ),
    );
  }

  // BULLET POINT TEKS NATURAL (BUKAN KOTAK KARTU)
  Widget _buildBulletItem(
    String boldPrefix,
    String text,
    Color textColor,
    Color headingColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 2, bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: headingColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: boldPrefix,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      color: headingColor,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NUMBERED LIST TEKS NATURAL
  Widget _buildNumberedItem(
    String number,
    String boldPrefix,
    String text,
    Color textColor,
    Color headingColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 2, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$number.',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                height: 1.6,
                color: headingColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: boldPrefix,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      color: headingColor,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORMAT SITASI DAFTAR PUSTAKA
  Widget _buildReferenceText(String citation, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Expanded(
            child: Text(
              citation,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

