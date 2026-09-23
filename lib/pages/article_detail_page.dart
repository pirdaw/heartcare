import 'package:flutter/material.dart';

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
                        image,
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
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 7,
                          color: Color(0xFF168BB2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // JUDUL
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // INFO ARTIKEL
                    Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'by Pirdaawaan',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // DESKRIPSI
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ISI ARTIKEL
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.5,
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
