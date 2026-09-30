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
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
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

                        const SizedBox(height: 20),

                        // GAMBAR ARTIKEL
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            image,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 180,
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE7F6FF),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 70,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 14),

                        // KATEGORI
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
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF168BB2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // JUDUL
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // INFO ARTIKEL
                        Row(
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'by Pirdaawaan',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // DESKRIPSI
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ISI ARTIKEL
                        Text(
                          content,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.6,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                          ),
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
}
