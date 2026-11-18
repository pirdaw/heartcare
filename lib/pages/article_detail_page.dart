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
    final bool isExercise = title.toLowerCase().contains('olahraga') ||
        title.toLowerCase().contains('latihan');

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
                                isCoronary
                                    ? '6 menit baca'
                                    : (isExercise
                                        ? '7 menit baca'
                                        : '5 menit baca'),
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
                                    : (isExercise
                                        ? 'Kajian Ilmiah • Eddy Purnomo'
                                        : 'by Tim Medis HeartCare'),
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
                          ] else if (isExercise) ...[
                            // PARAGRAF PEMBUKA (LEAD PARAGRAPH)
                            _buildLeadParagraph(
                              'Latihan olahraga yang teratur, terarah, dan terprogram merupakan salah satu sarana utama dalam meningkatkan kebugaran jasmani serta menghindarkan diri dari penyakit degeneratif, khususnya penyakit jantung dan pembuluh darah. Di era modernisasi saat ini, kemajuan teknologi yang serba otomatis mendorong manusia menjadi kurang bergerak (gaya hidup sedentari), sehingga meningkatkan risiko gangguan kardiovaskular. Melalui kajian ilmiah kedokteran olahraga oleh Eddy Purnomo (1993), pemahaman mengenai kapasitas kerja pompa jantung, penerapan takaran latihan yang terukur (prinsip FITT: intensitas denyut nadi sasaran 70%–85% DJM, frekuensi 3–5 kali seminggu, dan durasi 20–45 menit), uji kesiapan fisik mandiri, serta pemilihan bentuk olahraga aerobik yang tepat menjadi kunci vital mewujudkan jantung yang sehat, kuat, dan berdaya guna tinggi.',
                              textColor,
                            ),

                            _buildSubheading('Perubahan Gaya Hidup & Ancaman Penyakit Jantung Modern', headingColor),

                            _buildBodyParagraph(
                              'Masyarakat Indonesia dewasa ini dihadapkan pada masalah penyakit dan gangguan kesehatan yang semakin kompleks akibat perubahan demografik dan epidemiologik. Perubahan demografik ditandai dengan pergeseran struktur populasi ke usia dewasa dan lanjut usia, sedangkan perubahan epidemiologik ditandai dengan transisi beban penyakit dari infeksi menular menuju penyakit degeneratif.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Salah satu penyakit degeneratif yang paling ditakuti adalah penyakit jantung dan pembuluh darah koroner. Berdasarkan data kesehatan nasional, penyakit kardiovaskular menduduki urutan ketiga penyebab kematian di Indonesia, serta menempati urutan pertama penyebab kematian pada kelompok usia di atas 45 tahun (Sahabuddin, 1992). Salah satu penyebab melonjaknya angka penyakit ini adalah kemajuan teknologi yang serba otomatis yang mengakibatkan masyarakat minim gerak badan dalam aktivitas kesehariannya.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Secara medis, penyebab penyakit jantung dikelompokkan menjadi dua macam: sakit jantung bawaan (kelainan anatomis sejak lahir) dan sakit jantung didapat (organ jantung lahir dalam kondisi normal namun kemudian mengalami gangguan). Faktor risiko yang mempercepat timbulnya penyakit jantung antara lain diabetes melitus, hipertensi, kegemukan (obesitas), proses penuaan dini pembuluh darah, kebiasaan merokok, tingkat stres emosional yang tinggi, serta kurangnya latihan gerak badan secara teratur (Hanafi, 1993; Puruhito, 1992).',
                              textColor,
                            ),

                            _buildSubheading('Susunan Anatomis & Kapasitas Pompa Jantung Manusia', headingColor),

                            _buildBodyParagraph(
                              'Jantung merupakan organ vital dalam tubuh manusia yang bekerja tanpa henti sebagai pompa pengalir darah ke seluruh jaringan tubuh melalui sistem pembuluh darah. Pada orang dewasa normal, besar jantung kira-kira setara dengan kepalan tangannya sendiri.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Kapasitas kerja jantung sangat luar biasa. Dalam satu kali kontraksi memompa (stroke), jantung mengeluarkan kurang lebih 70–80 cc darah. Pada saat istirahat, jantung orang dewasa normal memompakan sekitar 5 liter (5.000 cc) darah setiap menit. Jika diakumulasikan, dalam satu jam jantung memompakan 300 liter darah, dan dalam satu hari penuh mencapai 7.200 liter darah yang dipompa secara terus-menerus ke seluruh tubuh (Puruhito, 1992).',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Ditinjau dari karakteristik jenis ototnya, otot jantung tergolong jenis otot polos involunter khusus yang berbeda dengan otot lurik bergaris pada lengan atau tungkai kaki (James G. Hay, 1987). Otot jantung berkontraksi secara reflektorik dan otonom—yaitu bekerja secara otomatis tanpa diperintah oleh otak sadar dan tidak dapat dikontrol kehendak.',
                              textColor,
                            ),

                            _buildBodyParagraph(
                              'Jantung tersusun atas 4 rongga utama (dua serambi dan dua bilik) yang menggerakkan dua sistem sirkulasi darah:',
                              textColor,
                            ),

                            _buildBulletItem(
                              'Peredaran Darah Pendek (Sirkulasi Pulmonal): ',
                              'Darah miskin oksigen dari seluruh tubuh ditampung di serambi kanan, melewati katup trikuspid menuju bilik kanan, lalu dipompakan melalui katup pulmonal menuju paru-paru untuk proses oksigenasi (pembersihan dan pengikatan oksigen murni).',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Peredaran Darah Panjang (Sirkulasi Sistemik): ',
                              'Darah kaya oksigen dari paru-paru kembali ke serambi kiri, mengalir melalui katup mitral menuju bilik kiri, kemudian dipompakan dengan kekuatan tinggi melalui katup aorta ke pembuluh nadi utama (aorta) guna disebarkan ke seluruh sel dan jaringan tubuh.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Bagaimana Olahraga Memperkuat Kerja Pompa Jantung?', headingColor),

                            _buildBodyParagraph(
                              'Jantung perlu dipelihara dan dilatih dengan baik. Melakukan program latihan olahraga yang teratur, terarah, dan terprogram akan merangsang kerja jantung dan paru-paru, sehingga efisiensi kedua organ tersebut meningkat secara bermakna (Bambang Soempeno, 1992).',
                              textColor,
                            ),

                            _buildBulletItem(
                              'Keterlibatan Otot-Otot Besar Tungkai: ',
                              'Bentuk olahraga aerobik yang sangat dianjurkan banyak melibatkan otot tungkai kaki (seperti berjalan cepat, joging, dan bersepeda). Otot-otot tungkai memiliki massa yang lebih besar dan lebih kuat dibandingkan otot lengan. Gerakan tungkai kaki secara ritmis menuntut pasokan energi dan oksigen yang jauh lebih besar, sehingga memberikan stimulasi yang lebih optimal terhadap peningkatan curah jantung dan kelenturan dinding arteri.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Peningkatan Kapasitas Aerobik (VO2 Max): ',
                              'Tujuan utama latihan olahraga adalah meningkatkan jumlah oksigen yang dapat diolah tubuh dalam satuan waktu tertentu (kemampuan aerobik). Kemampuan aerobik bergantung langsung pada kerja paru-paru yang efisien, kekuatan miokardium jantung, dan kelenturan sistem sirkulasi pembuluh darah.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Peningkatan Volume Sekuncup (Stroke Volume): ',
                              'Menurut dr. Sadoso Sumosardjuno (1993), latihan fisik yang melibatkan otot-otot besar secara ritmis dan berkesinambungan selama 20–30 menit membuat miokardium lebih padat, tebal, kuat, dan berdaya guna.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Bradikardia Fisiologis (Denyut Istirahat Lebih Rendah): ',
                              'Jantung individu yang terlatih secara aerobik akan berdenyut lebih lambat sewaktu istirahat maupun saat bekerja ringan, namun memiliki kemampuan memompakan volume darah yang jauh lebih besar dan kuat pada setiap detakan (Stroke Volume besar), sehingga kerja jantung menjadi jauh lebih efisien dan hemat energi.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Takaran Latihan yang Baik dan Benar (Prinsip Terukur)', headingColor),

                            _buildBodyParagraph(
                              'Latihan olahraga yang benar adalah latihan yang memenuhi takaran-takaran terukur yang meliputi intensitas latihan, lama/durasi latihan, frekuensi latihan mingguan, serta tahapan sesi latihan (Bambang Soempeno, 1992; Sadoso Sumosardjuno, 1991):',
                              textColor,
                            ),

                            _buildNumberedItem(
                              '1',
                              'Takaran Intensitas Latihan (Zona Sasaran Denyut Nadi): ',
                              'Intensitas mengukur seberapa berat latihan fisik dilaksanakan. Intensitas diukur secara objektif dengan menghitung frekuensi denyut nadi per menit. Denyut Nadi Maksimal (DJM) yang boleh dicapai seseorang dihitung dengan rumus: 220 dikurangi Umur (dalam tahun). Latihan yang efektif dan aman bagi jantung adalah yang mencapai 70% sampai 85% dari DJM (idealnya 72% – 85%). Latihan di bawah 70% DJM kurang memberikan stimulasi adaptasi fisiologis; sebaliknya, melampaui 85% DJM berisiko membahayakan miokardium.',
                              textColor,
                              headingColor,
                            ),

                            _buildCalloutBox(
                              icon: Icons.calculate_rounded,
                              title: 'Rumus Denyut Nadi Maksimal (DJM) & Zona Target',
                              description:
                                  '• Denyut Nadi Maksimal: DJM = 220 - Umur (tahun)\n• Zona Sasaran Latihan: 70% – 85% dari DJM\n• Contoh Kasus Usia 50 Tahun:\n  - DJM = 220 - 50 = 170 denyut/menit\n  - Batas Bawah (70%): 0,70 x 170 = 119 bpm\n  - Batas Atas (85%): 0,85 x 170 = 144,5 bpm\n  - Target Denyut Nadi Latihan: 119 – 144,5 denyut/menit',
                              isDark: isDark,
                              accentColor: const Color(0xFF0284C7),
                            ),

                            _buildNumberedItem(
                              '2',
                              'Durasi / Lama Latihan (20 – 45 Menit): ',
                              'Untuk memperoleh adaptasi kardiovaskular yang optimal terhadap jantung dan peredaran darah, seseorang sebaiknya mempertahankan denyut nadi di dalam zona sasaran (target zone) selama 20 sampai dengan 45 menit per sesi. Durasi latihan di zona target yang kurang dari 20 menit dinilai kurang memberikan tekanan adaptasi bagi elastisitas pembuluh darah (Sadoso Sumosardjuno, 1991; Hasyim Effendi, 1983).',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '3',
                              'Frekuensi Latihan Mingguan (3 – 5 Kali Seminggu): ',
                              'Latihan aerobik dianjurkan dilakukan minimal 3 kali per minggu, dan yang paling baik adalah 4 sampai 5 kali per minggu. Landasan ilmiahnya adalah karena setelah 48 jam (dua hari), daya tahan dan kebugaran tubuh akan mulai mengalami penurunan kembali. Oleh karena itu, sebelum daya tahan tubuh menurun, tubuh hendaknya sudah mendapatkan rangsangan latihan berikutnya.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '4',
                              'Urutan Pelaksanaan Latihan yang Disiplin: ',
                              'Setiap sesi latihan harus mengikuti urutan terstruktur: (a) Latihan pemanasan (warming-up) sekitar 10 menit untuk menaikkan suhu tubuh dan sirkulasi darah bertahap; (b) Latihan inti aerobik selama 20 hingga 45 menit di zona sasaran denyut nadi; dan (c) Latihan pendinginan (cooling-down) sekitar 5 menit untuk menormalkan detak jantung serta mencegah pusing akibat penumpukan darah di tungkai.',
                              textColor,
                              headingColor,
                            ),

                            _buildNumberedItem(
                              '5',
                              'Protokol Khusus Penderita Jantung Koroner: ',
                              'Bagi penderita penyakit jantung koroner atau pasien dalam masa rehabilitasi pasca-serangan, dianjurkan untuk berlatih dengan intensitas stabil sekitar 70% DJM secara konsisten selama satu tahun penuh, sebelum dipertimbangkan untuk meningkatkan intensitas secara bertahap hingga 85% di bawah pengawasan dokter (Bambang Soempeno, 1992).',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Uji Kesiapan Mandiri Sebelum Latihan (Tes Jalan Cepat 5 Menit)', headingColor),

                            _buildBodyParagraph(
                              'Sebelum memulai program latihan olahraga rutin, setiap orang sebaiknya menguji respons fisiologis jantungnya sendiri melalui tes jalan cepat 5 menit:',
                              textColor,
                            ),

                            _buildCalloutBox(
                              icon: Icons.timer_outlined,
                              title: 'Protokol Tes Kesiapan Mandiri (5 Menit Jalan Cepat)',
                              description:
                                  '1. Lakukan jalan cepat selama 5 menit berturut-turut dalam intensitas di mana Anda masih sanggup berbicara santai (talk test).\n2. Hentikan aktivitas dan beristirahatlah dengan duduk santai selama 10 menit penuh.\n3. Raba dan hitung denyut nadi per menit pada pergelangan tangan serta rasakan kelancaran pernapasan Anda.',
                              isDark: isDark,
                              accentColor: const Color(0xFF0D9488),
                            ),

                            _buildBulletItem(
                              'Jantung Sehat & Siap Berlatih: ',
                              'Jika setelah 10 menit istirahat denyut nadi telah kembali turun di bawah 100 denyut per menit dan bernapas tidak terasa sukar (tidak terengah-engah), berarti kondisi jantung sehat dan layak untuk memulai program latihan olahraga.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Perlu Pemeriksaan Dokter: ',
                              'Jika setelah 10 menit istirahat denyut nadi masih bertahan di atas 100 denyut per menit dan napas masih terasa sesak atau terengah-engah, jangan memaksakan diri berlatih. Segera periksakan kondisi kesehatan Anda ke dokter spesialis jantung atau dokter olahraga untuk deteksi dini.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Rekomendasi Bentuk Olahraga Aerobik yang Dianjurkan', headingColor),

                            _buildBodyParagraph(
                              'Berdasarkan kajian Drs. Eddy Purnomo (1993) dan dr. Kenneth H. Cooper (1983), berikut adalah bentuk latihan aerobik yang mudah dilakukan, berbiaya murah, melibatkan otot-otot besar, dan terbukti sangat efektif bagi kesehatan jantung:',
                              textColor,
                            ),

                            _buildBulletItem(
                              '1. Jalan Kaki Cepat (Brisk Walking): ',
                              'Bentuk olahraga aerobik yang paling aman, berisiko cedera sendi sangat minimal, dan cocok untuk semua tingkatan usia, penderita obesitas, lansia, maupun pemula yang baru memulai aktivitas fisik.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              '2. Lari Santai / Joging (Jogging): ',
                              'Sangat efektif meningkatkan kapasitas aerobik maksimal (VO2 max), memperkuat ventrikel jantung, dan memperbaiki profil lipid darah.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              '3. Bersepeda & Sepeda Statis: ',
                              'Mengaktifkan otot-otot besar tungkai bawah secara ritmis tanpa membebani persendian lutut dengan benturan keras, sangat ideal sebagai latihan di luar ruangan maupun dalam ruangan.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              '4. Berenang: ',
                              'Melibatkan hampir seluruh kelompok otot tubuh secara harmonis dengan proteksi daya apung air yang melindungi sendi dari kompresi gravitasi, sekaligus melatih kapasitas paru-paru.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              '5. Senam Aerobik (Aerobic Dance): ',
                              'Gerakan ritmis, terkoordinasi, dan dinamis yang melatih kelenturan tubuh, kapasitas sirkulasi kardiovaskular, dan koordinasi motorik.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Panduan Memulai Berdasarkan Kategori Kebugaran & Usia', headingColor),

                            _buildBodyParagraph(
                              'Untuk menentukan titik awal program latihan yang aman, dr. Kenneth H. Cooper menyusun pedoman berdasarkan rentang usia dan riwayat olahraga:',
                              textColor,
                            ),

                            _buildBulletItem(
                              'Usia di Bawah 35 Tahun: ',
                              'Dapat mengambil tes lari 12 menit (Cooper Test) sebagai evaluasi pendahuluan untuk menetapkan kategori kebugaran jasmani (Kurang Sekali: <1 mil; Kurang: 1–1,24 mil; Sedang: 1,25–1,49 mil; Baik: 1,50–1,74 mil; Baik Sekali: >1,75 mil), kecuali bila memiliki gangguan kesehatan tertentu.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Usia di Atas 35 Tahun (Sudah Rutin Berlatih): ',
                              'Boleh mengambil tes lari 12 menit jika telah melakukan latihan fisik secara teratur sekurang-kurangnya 3 kali seminggu selama minimal 6 minggu berturut-turut.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Usia di Atas 35 Tahun (Jarang / Belum Pernah Olahraga): ',
                              'Dilarang langsung mengambil tes pendahuluan lari 12 menit. Langsung tempatkan diri pada program adaptasi awal jalan kaki santai (kategori pertama) tanpa tes lari 12 menit demi menghindari risiko lonjakan beban kardiovaskular mendadak.',
                              textColor,
                              headingColor,
                            ),

                            _buildBulletItem(
                              'Progresivitas Program (10 – 16 Minggu): ',
                              'Jalankan program secara bertahap (program 10 hingga 16 minggu). Tingkatkan jarak dan durasi latihan secara bertahap setiap minggu sesuai kemampuan, lalu lanjutkan ke program pemeliharaan (maintenance) seumur hidup.',
                              textColor,
                              headingColor,
                            ),

                            _buildSubheading('Kesimpulan & Rekomendasi Medis', headingColor),

                            _buildBodyParagraph(
                              'Latihan olahraga merupakan sarana alami yang sangat ampuh untuk menghindarkan diri dari penyakit degeneratif dan meningkatkan kesehatan jantung. Kunci keberhasilan latihan bukan terletak pada intensitas berat sesaat, melainkan pada konsistensi latihan yang teratur, terprogram, dan terkontrol sesuai takaran yang benar (zona denyut nadi 70%–85% DJM, frekuensi 3–5 kali seminggu, dan durasi 20–45 menit). Pilihlah olahraga yang disukai dan sesuai dengan kemampuan fisik individu, selalu awali dengan pemanasan dan akhiri dengan pendinginan, serta lakukan pemeriksaan ke dokter spesialis sebelum memulai bila memiliki faktor risiko kardiovaskular.',
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
                              'Purnomo, E. (1993). Jantung Sehat dan Program Latihan Olahraga yang Baik dan Benar. Cakrawala Pendidikan: Jurnal Ilmiah Pendidikan, Nomor 2, Tahun XII, 131–144.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Cooper, K. H. (1983). Aerobics. Jakarta: Penerbit Gramedia.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Soempeno, B. (1992). Olahraga yang Baik dan Benar untuk Menghindarkan Penyakit Jantung. Makalah Seminar Penyakit Jantung, Yogyakarta.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Soemosardjuno, S. (1991). Program Latihan Olahraga untuk Kebugaran Para Eksekutif. Makalah Seminar Olahraga bagi Eksekutif, Jakarta.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Puruhito. (1992). Apa dan Mengapa Sakit Jantung. Yogyakarta: Yayasan Jantung Sehat Indonesia.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Effendi, H. (1983). Fisiologi Kerja dan Olahraga serta Peranan Tes Kerja untuk Diagnostik. Bandung: Penerbit Alumni.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Sahabuddin, B. (1992). Strategi Menuju Jantung Sehat Menjelang Tahun 2000. Yogyakarta: Yayasan Jantung Sehat Indonesia.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Hay, J. G., & Reid, J. G. (1982). Anatomy, Mechanics and Human Motion. Englewood Cliffs, New Jersey: Prentice-Hall.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Selamihardja, N. (1993). Olahraga dan Pencegahan Penyakit Kardiovaskular. Majalah Intisari Kesehatan, Edisi Maret 1993, hal. 130–138.',
                              textColor,
                            ),
                            _buildReferenceText(
                              'Soedarmo, S. P. (1992). Metode dan Program Latihan Ketahanan Fisik. Surabaya: Komite Olahraga Nasional Indonesia (KONI) Jawa Timur.',
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

  // KOTAK HIGHLIGHT EDUKASI / CALLOUT
  Widget _buildCalloutBox({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    Color accentColor = const Color(0xFF0284C7),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.12)
            : accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? accentColor.withValues(alpha: 0.35)
              : accentColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark
                  ? accentColor.withValues(alpha: 0.22)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

