import 'package:flutter/material.dart';

import 'article_detail_page.dart';

class ArtikelKesehatanPage extends StatefulWidget {
  const ArtikelKesehatanPage({super.key});

  @override
  State<ArtikelKesehatanPage> createState() => _ArtikelKesehatanPageState();
}

class _ArtikelKesehatanPageState extends State<ArtikelKesehatanPage> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _articles = [
    {
      'image':
          'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800',
      'category': 'Penyakit Jantung',
      'title': 'Mengenal Penyakit Jantung Koroner',
      'description': 'Penyakit jantung koroner merupakan salah satu penyakit yang perlu diwaspadai karena dapat memengaruhi fungsi jantung dalam memompa darah ke seluruh tubuh.',
      'date': '08 September 2026',
      'duration': '5 menit baca',
      'content': 'Penyakit jantung koroner adalah kondisi ketika pembuluh darah yang berfungsi mengalirkan darah dan oksigen ke otot jantung mengalami penyempitan atau penyumbatan. Kondisi ini dapat menyebabkan aliran darah menuju jantung menjadi berkurang.\n\nPenyempitan pembuluh darah umumnya terjadi akibat penumpukan lemak atau plak pada dinding pembuluh darah.\n\nBeberapa faktor dapat meningkatkan risiko penyakit jantung, antara lain tekanan darah tinggi, kolesterol tinggi, kurang aktivitas fisik, dan pola makan kurang sehat.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
      'category': 'Pola Hidup',
      'title': 'Makanan Sehat untuk Jantung',
      'description': 'Menjaga kesehatan jantung dapat dimulai dari pilihan makanan sehari-hari yang bergizi seimbang dan ramah kardiovaskular.',
      'date': '08 September 2026',
      'duration': '4 menit baca',
      'content': 'Pola makan yang sehat merupakan salah satu bagian penting dalam menjaga kesehatan jantung. Pemilihan makanan yang tepat dapat membantu mendukung kesehatan tubuh secara keseluruhan.\n\nBeberapa pilihan makanan yang dapat dikonsumsi antara lain sayuran, buah-buahan, biji-bijian, dan makanan yang memiliki kandungan gizi seimbang.\n\nSelain memilih makanan yang sehat, penting juga untuk memperhatikan jumlah dan pola makan sehari-hari.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
      'category': 'Pola Hidup',
      'title': 'Olahraga yang Baik untuk Kesehatan Jantung',
      'description': 'Aktivitas fisik secara rutin dapat membantu menjaga kebugaran tubuh dan mendukung daya tahan jantung secara optimal.',
      'date': '08 September 2026',
      'duration': '4 menit baca',
      'content': 'Aktivitas fisik secara rutin dapat membantu menjaga kebugaran tubuh dan mendukung kesehatan jantung. Olahraga juga dapat menjadi bagian dari pola hidup sehat apabila dilakukan secara teratur.\n\nBeberapa aktivitas fisik yang dapat dilakukan antara lain berjalan kaki, bersepeda, dan aktivitas fisik lainnya sesuai dengan kemampuan tubuh.\n\nYang penting adalah melakukan aktivitas secara rutin dan menyesuaikannya dengan kondisi masing-masing.',
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
                  Container(
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
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Artikel Kesehatan',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kumpulan artikel & tips seputar kesehatan jantung',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
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
                    // SEARCH BAR
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Cari artikel kesehatan...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // KATEGORI FILTER
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Penyakit Jantung'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pola Hidup'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // LIST ARTIKEL
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.article_outlined,
                                size: 48,
                                color: Color(0xFFCBD5E1),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Artikel tidak ditemukan',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildArticleItem(context, item);
                        },
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

  Widget _buildFilterChip(String category) {
    final active = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0098B9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF0098B9) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item['image'],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: const Color(0xFFE0F7FA),
                    child: const Icon(
                      Icons.article_outlined,
                      color: Color(0xFF0098B9),
                    ),
                  );
                },
              ),
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
                      color: const Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['category'],
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0098B9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
