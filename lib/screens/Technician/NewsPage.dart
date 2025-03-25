import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/Responsive_helper.dart';

class NewsPage extends StatelessWidget {
  final List<Map<String, String>> newsItems = [
    {
      'title': 'عطلة رسمية',
      'content': 'يوم الاثنين الموافق 15/8 إجازة رسمية بمناسبة اليوم الوطني',
      'admin': 'إدارة الموارد البشرية',
      'time': 'قبل ساعتين'
    },
    {
      'title': 'تغيير دوام',
      'content': 'الدوام يوم الثلاثاء يبدأ الساعة 9:00 صباحًا بدلًا من 8:00',
      'admin': 'قسم العمليات',
      'time': 'قبل 5 ساعات'
    },
  ];

  NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.new_releases_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  'الأخبار الفورية',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                return Center(
                  child: SizedBox(
                    width: ResponsiveHelper.isDesktop(context)
                        ? screenWidth * 0.6
                        : screenWidth * 0.9,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.campaign,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                Text(
                                  newsItems[index]['time']!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              newsItems[index]['title']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              newsItems[index]['content']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'مرسل بواسطة: ${newsItems[index]['admin']}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
