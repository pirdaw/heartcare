import 'package:flutter/material.dart';
import 'article_detail_page.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

                    const SizedBox(height: 18),

                    // SEARCH
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFBDBDBD),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: '',
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 9),
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    // FILTER
                    Row(
                      children: [
                        _filter('Semua', true),
                        _filter('Penyakit Jantung', false),
                        _filter('Pola Hidup', false),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ARTIKEL 1
                    _articleCard(
                      context,
                      image:
                          'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=500',
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
        image:
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800',
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

                    const SizedBox(height: 17),

                    // ARTIKEL 2
                    _articleCard(
                      context,
                      image:
                          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500',
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
        image:
            'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
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

                    const SizedBox(height: 17),

                    // ARTIKEL 3
                    _articleCard(
                      context,
                      image:
                          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=500',
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
        image:
            'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
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
  }

  Widget _filter(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF159BC2) : Colors.white,
        border: Border.all(
          color: active
              ? const Color(0xFF159BC2)
              : const Color(0xFFBBBBBB),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: active ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _articleCard(
    BuildContext context, {
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
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBDBDBD),
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
                    color: const Color(0xFFE7F6FF),
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

                  const SizedBox(height: 4),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        height: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
