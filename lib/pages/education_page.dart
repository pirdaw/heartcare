import 'package:flutter/material.dart';
import 'package:heartcare/services/theme_service.dart';
import 'article_detail_page.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F1F1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 17,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edukasi Kesehatan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Belajar informasi kesehatan jantung agar hidup\nlebih sehat.',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // SEARCH
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFBDBDBD),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari artikel kesehatan...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF64748B) : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // FILTER
                        Row(
                          children: [
                            _filter('Semua', true, isDark),
                            _filter('Penyakit Jantung', false, isDark),
                            _filter('Pola Hidup', false, isDark),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ARTIKEL 1
                        _articleCard(
                          context,
                          isDark: isDark,
                          image: 'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=500',
                          category: 'Penyakit Jantung',
                          title: 'Mengenal Penyakit\nJantung Koroner',
                          description:
                              'Penyakit jantung koroner merupakan salah satu '
                              'penyakit yang perlu diwaspadai karena dapat '
                              'mengganggu fungsi jantung.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArticleDetailPage(
                                  image: 'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800',
                                  category: 'Penyakit Jantung',
                                  title: 'Mengenal Penyakit Jantung Koroner',
                                  description:
                                      'Penyakit jantung koroner merupakan salah satu penyakit '
                                      'yang perlu diwaspadai karena dapat memengaruhi fungsi '
                                      'jantung dalam memompa darah ke seluruh tubuh.',
                                  date: '08 September 2026',
                                  content:
                                      'Penyakit jantung koroner adalah kondisi ketika pembuluh '
                                      'darah yang berfungsi mengalirkan darah dan oksigen ke '
                                      'otot jantung mengalami penyempitan atau penyumbatan. '
                                      'Kondisi ini dapat menyebabkan aliran darah menuju '
                                      'jantung menjadi berkurang.\n\n'
                                      'Penyempitan pembuluh darah umumnya terjadi akibat '
                                      'penumpukan lemak atau plak pada dinding pembuluh darah.\n\n'
                                      'Beberapa faktor dapat meningkatkan risiko penyakit '
                                      'jantung, antara lain tekanan darah tinggi, kolesterol '
                                      'tinggi, kurang aktivitas fisik, dan pola makan kurang sehat.',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ARTIKEL 2
                        _articleCard(
                          context,
                          isDark: isDark,
                          image: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500',
                          category: 'Pola Hidup',
                          title: 'Makanan Sehat\nuntuk Jantung',
                          description:
                              'Menjaga kesehatan jantung dapat dimulai dari '
                              'pilihan makanan sehari-hari.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArticleDetailPage(
                                  image: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
                                  category: 'Pola Hidup',
                                  title: 'Makanan Sehat untuk Jantung',
                                  description:
                                      'Menjaga kesehatan jantung dapat dimulai dari pilihan '
                                      'makanan sehari-hari.',
                                  date: '08 September 2026',
                                  content:
                                      'Pola makan yang sehat merupakan salah satu bagian penting '
                                      'dalam menjaga kesehatan jantung. Pemilihan makanan yang '
                                      'tepat dapat membantu mendukung kesehatan tubuh secara '
                                      'keseluruhan.\n\n'
                                      'Beberapa pilihan makanan yang dapat dikonsumsi antara '
                                      'lain sayuran, buah-buahan, biji-bijian, dan makanan yang '
                                      'memiliki kandungan gizi seimbang.\n\n'
                                      'Selain memilih makanan yang sehat, penting juga untuk '
                                      'memperhatikan jumlah dan pola makan sehari-hari.',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ARTIKEL 3
                        _articleCard(
                          context,
                          isDark: isDark,
                          image: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=500',
                          category: 'Pola Hidup',
                          title: 'Olahraga yang Baik\nuntuk Kesehatan Jantung',
                          description:
                              'Aktivitas fisik secara rutin dapat membantu '
                              'menjaga kebugaran tubuh dan mendukung kesehatan.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArticleDetailPage(
                                  image: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
                                  category: 'Pola Hidup',
                                  title: 'Olahraga yang Baik untuk Kesehatan Jantung',
                                  description:
                                      'Aktivitas fisik secara rutin dapat membantu menjaga '
                                      'kebugaran tubuh dan mendukung kesehatan.',
                                  date: '08 September 2026',
                                  content:
                                      'Aktivitas fisik secara rutin dapat membantu menjaga '
                                      'kebugaran tubuh dan mendukung kesehatan jantung. Olahraga '
                                      'juga dapat menjadi bagian dari pola hidup sehat apabila '
                                      'dilakukan secara teratur.\n\n'
                                      'Beberapa aktivitas fisik yang dapat dilakukan antara lain '
                                      'berjalan kaki, bersepeda, dan aktivitas fisik lainnya '
                                      'sesuai dengan kemampuan tubuh.\n\n'
                                      'Yang penting adalah melakukan aktivitas secara rutin dan '
                                      'menyesuaikannya dengan kondisi masing-masing.',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filter(String text, bool active, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF159BC2)
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        border: Border.all(
          color: active
              ? const Color(0xFF159BC2)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFBBBBBB)),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: active
              ? Colors.white
              : (isDark ? const Color(0xFF94A3B8) : Colors.black87),
        ),
      ),
    );
  }

  Widget _articleCard(
    BuildContext context, {
    required bool isDark,
    required String image,
    required String category,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 119,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFBDBDBD),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // GAMBAR
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                image,
                width: 96,
                height: 95,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 96,
                    height: 95,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE7F6FF),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            // TEKS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
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
                        fontSize: 7,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF168BB2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        height: 1.2,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
