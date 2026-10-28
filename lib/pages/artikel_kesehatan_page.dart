import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'article_detail_page.dart';

class ArtikelKesehatanPage extends StatefulWidget {
  const ArtikelKesehatanPage({super.key});

  @override
  State<ArtikelKesehatanPage> createState() => _ArtikelKesehatanPageState();
}

class _ArtikelKesehatanPageState extends State<ArtikelKesehatanPage> {
  static const Color brandPrimary = Color(0xFF0284C7);
  static const Color brandLight = Color(0xFFE0F2FE);

  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _articles = [
    {
      'image':
          'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800',
      'category': 'Penyakit Jantung',
      'title': 'Mengenal Penyakit Jantung Koroner',
      'description':
          'Penyakit jantung koroner merupakan salah satu penyakit yang perlu diwaspadai karena dapat memengaruhi fungsi jantung dalam memompa darah ke seluruh tubuh.',
      'date': '08 September 2026',
      'duration': '5 menit baca',
      'content':
          'Penyakit jantung koroner adalah kondisi ketika pembuluh darah yang berfungsi mengalirkan darah dan oksigen ke otot jantung mengalami penyempitan atau penyumbatan. Kondisi ini dapat menyebabkan aliran darah menuju jantung menjadi berkurang.\n\nPenyempitan pembuluh darah umumnya terjadi akibat penumpukan lemak atau plak pada dinding pembuluh darah.\n\nBeberapa faktor dapat meningkatkan risiko penyakit jantung, antara lain tekanan darah tinggi, kolesterol tinggi, kurang aktivitas fisik, dan pola makan kurang sehat.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
      'category': 'Pola Hidup',
      'title': 'Makanan Sehat untuk Jantung',
      'description':
          'Menjaga kesehatan jantung dapat dimulai dari pilihan makanan sehari-hari yang bergizi seimbang dan ramah kardiovaskular.',
      'date': '08 September 2026',
      'duration': '4 menit baca',
      'content':
          'Pola makan yang sehat merupakan salah satu bagian penting dalam menjaga kesehatan jantung. Pemilihan makanan yang tepat dapat membantu mendukung kesehatan tubuh secara keseluruhan.\n\nBeberapa pilihan makanan yang dapat dikonsumsi antara lain sayuran, buah-buahan, biji-bijian, dan makanan yang memiliki kandungan gizi seimbang.\n\nSelain memilih makanan yang sehat, penting juga untuk memperhatikan jumlah dan pola makan sehari-hari.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
      'category': 'Pola Hidup',
      'title': 'Olahraga yang Baik untuk Kesehatan Jantung',
      'description':
          'Aktivitas fisik secara rutin dapat membantu menjaga kebugaran tubuh dan mendukung daya tahan jantung secara optimal.',
      'date': '08 September 2026',
      'duration': '4 menit baca',
      'content':
          'Aktivitas fisik secara rutin dapat membantu menjaga kebugaran tubuh dan mendukung kesehatan jantung. Olahraga juga dapat menjadi bagian dari pola hidup sehat apabila dilakukan secara teratur.\n\nBeberapa aktivitas fisik yang dapat dilakukan antara lain berjalan kaki, bersepeda, dan aktivitas fisik lainnya sesuai dengan kemampuan tubuh.\n\nYang penting adalah melakukan aktivitas secara rutin dan menyesuaikannya dengan kondisi masing-masing.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredArticles {
    final query = _searchController.text.toLowerCase().trim();
    return _articles.where((article) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          article['category'] == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          article['title'].toString().toLowerCase().contains(query) ||
          article['description'].toString().toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredArticles;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              // 1. BACKGROUND GRADIENT DENGAN AMBIENT ORNAMEN
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 1.0],
                      colors: isDark
                          ? const [
                              Color(0xFF0F2338),
                              Color(0xFF131D2E),
                              Color(0xFF0F172A),
                            ]
                          : const [
                              Color(0xFFE0F2FE),
                              Color(0xFFF0F9FF),
                              Color(0xFFF8FAFC),
                            ],
                    ),
                  ),
                ),
              ),

              // Ambient Accent Circle Kanan Atas
              Positioned(
                top: -45,
                right: -40,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF38BDF8))
                        .withValues(alpha: isDark ? 0.12 : 0.22),
                  ),
                ),
              ),

              // Ambient Accent Circle Kiri Tengah
              Positioned(
                top: 130,
                left: -50,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFFBAE6FD))
                        .withValues(alpha: isDark ? 0.08 : 0.30),
                  ),
                ),
              ),

              // 2. KONTEN UTAMA
              SafeArea(
                child: Column(
                  children: [
                    // HEADER BAR
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 18, right: 18, top: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.2 : 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Artikel Kesehatan',
                                  style: TextStyle(
                                    fontSize: 19.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kumpulan artikel & tips seputar kesehatan jantung',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
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

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SEARCH BAR BERWARNA & ELEGAN (MENYERUPAI MENU DOKTER)
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFBAE6FD),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(
                                        alpha: isDark ? 0.2 : 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cari artikel kesehatan...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 22,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : brandPrimary,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // KATEGORI FILTER DENGAN GRADIENT & SHADOW MENARIK
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('Semua', isDark: isDark),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Penyakit Jantung',
                                      isDark: isDark),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Pola Hidup',
                                      isDark: isDark),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // SUBHEADER JUMLAH ARTIKEL SEPERTI MENU DOKTER
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Daftar Artikel',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F2B3E)
                                        : brandLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF1E3A5F)
                                          : const Color(0xFFBAE6FD),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${filtered.length} Artikel',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : brandPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // LIST ARTIKEL
                            if (filtered.isEmpty)
                              _buildEmptyState(isDark: isDark)
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return _buildArticleItem(context, item,
                                      isDark: isDark);
                                },
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // WIDGET CHIP FILTER KATEGORI (GAYA DOKTER PAGE)
  Widget _buildFilterChip(String category, {required bool isDark}) {
    final active = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0EA5E9),
                    Color(0xFF0284C7),
                  ],
                )
              : null,
          color: active
              ? null
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  // BADGE KATEGORI BERWARNA KHAS
  Widget _buildCategoryBadge(String category, {required bool isDark}) {
    Color bg;
    Color border;
    Color text;
    IconData icon;

    if (category == 'Penyakit Jantung') {
      bg = isDark ? const Color(0xFF3B151E) : const Color(0xFFFEE2E2);
      border = isDark ? const Color(0xFF6B1D2F) : const Color(0xFFFECACA);
      text = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      icon = Icons.favorite_rounded;
    } else if (category == 'Pola Hidup') {
      bg = isDark ? const Color(0xFF063321) : const Color(0xFFDCFCE7);
      border = isDark ? const Color(0xFF135B3B) : const Color(0xFFBBF7D0);
      text = isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A);
      icon = Icons.spa_rounded;
    } else {
      bg = isDark ? const Color(0xFF0F2B3E) : brandLight;
      border = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD);
      text = isDark ? const Color(0xFF38BDF8) : brandPrimary;
      icon = Icons.article_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KARTU ARTIKEL LEBIH BERWARNA & BERDIMENSI
  Widget _buildArticleItem(
    BuildContext context,
    Map<String, dynamic> item, {
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0284C7))
                .withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailPage(
                  image: item['image'],
                  category: item['category'],
                  title: item['title'],
                  description: item['description'],
                  date: item['date'],
                  content: item['content'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // FOTO ARTIKEL DENGAN BORDER & CONTAINER BERGAYA DOKTER
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDark
                        ? const Color(0xFF0F2B3E)
                        : const Color(0xFFEFF6FF),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFBAE6FD),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.5),
                    child: Image.network(
                      item['image'],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.article_outlined,
                            size: 36,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : brandPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                // KONTEN ARTIKEL (FONT STANDAR LEBIH JELAS & PROPORSIONAL)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryBadge(item['category'] as String,
                          isDark: isDark),
                      const SizedBox(height: 6),
                      Text(
                        item['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (item['duration'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : brandPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['duration'] as String,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : brandPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // TOMBOL CHEVRON / DETAIL MENYERUPAI DOKTER PAGE
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F2B3E) : brandLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFBAE6FD),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? const Color(0xFF38BDF8) : brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // EMPTY STATE JIKA PENCARIAN KOSONG
  Widget _buildEmptyState({bool isDark = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 42,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Artikel tidak ditemukan',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba gunakan kata kunci pencarian yang lain.',
              style: TextStyle(
                fontSize: 12.5,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
