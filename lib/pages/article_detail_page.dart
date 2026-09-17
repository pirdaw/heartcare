import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F1F1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 17,
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Edukasi Kesehatan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Belajar informasi kesehatan jantung agar hidup\n'
                              'lebih sehat.',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // GAMBAR ARTIKEL
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150,
                            color: const Color(0xFFE7F6FF),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 70,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // KATEGORI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9F5FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Penyakit Jantung',
                        style: TextStyle(
                          fontSize: 7,
                          color: Color(0xFF168BB2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // JUDUL
                    const Text(
                      'Mengenal Penyakit Jantung Koroner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // INFO ARTIKEL
                    const Row(
                      children: [
                        Text(
                          '08 September 2026',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'by Pirdaawaan',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Penyakit jantung koroner merupakan salah satu '
                      'penyakit yang perlu diwaspadai karena dapat '
                      'memengaruhi fungsi jantung dalam memompa darah '
                      'ke seluruh tubuh.',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Apa Itu Penyakit Jantung Koroner?',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Penyakit jantung koroner adalah kondisi ketika '
                      'pembuluh darah yang berfungsi mengalirkan darah '
                      'dan oksigen ke otot jantung mengalami penyempitan '
                      'atau penyumbatan. Kondisi ini dapat menyebabkan '
                      'aliran darah menuju jantung menjadi berkurang.',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 13),

                    const Text(
                      'Penyempitan pembuluh darah umumnya terjadi '
                      'akibat penumpukan lemak atau plak pada dinding '
                      'pembuluh darah.',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Faktor Risiko Penyakit Jantung',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Beberapa faktor dapat meningkatkan risiko '
                      'penyakit jantung, antara lain:',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      '• Tekanan darah tinggi\n'
                      '• Kolesterol tinggi\n'
                      '• Kurang aktivitas fisik\n'
                      '• Pola makan kurang sehat',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.6,
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
  }
}