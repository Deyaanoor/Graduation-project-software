import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Technician/SparePartDetails.dart';
import 'package:flutter_provider/widgets/appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart'; // Import animations package
import 'data.dart';

void main() {
  runApp(SparePartsApp());
}

class SparePartsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: SparePartsScreen(),
    );
  }
}

class SparePartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: "قطع الغيار",
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن قطعة...',
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          categories[index]['title'],
                          style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                      ),
                      // إضافة Scrollable هوريزنتالي هنا
                      Container(
                        height: 200, // التحكم في ارتفاع الـ ListView
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories[index]['items'].length,
                          itemBuilder: (context, itemIndex) {
                            var item = categories[index]['items'][itemIndex];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: OpenContainer(
                                closedColor: Colors.transparent,
                                closedElevation: 0,
                                transitionDuration: Duration(milliseconds: 400),
                                transitionType: ContainerTransitionType.fade,
                                openBuilder: (context, _) =>
                                    SparePartDetails(item: item),
                                closedBuilder: (context, openContainer) =>
                                    GestureDetector(
                                  onTap: openContainer,
                                  child: Container(
                                    width: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6)
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                            child: Image.asset(item['image'],
                                                fit: BoxFit.cover,
                                                width: double.infinity),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(item['name'],
                                                  style: GoogleFonts.cairo(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(item['type'],
                                                  style: GoogleFonts.cairo(
                                                      color: Colors.grey)),
                                            ],
                                          ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
