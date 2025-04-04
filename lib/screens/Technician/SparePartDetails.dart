import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SparePartDetails extends StatelessWidget {
  final Map<String, dynamic> item;

  const SparePartDetails({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? '',
            style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.orange[800],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.orange.shade100,
              Colors.orange.shade300,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الصورة الرئيسية
                    Container(
                      height: screenHeight * 0.45,
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.orange.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: Offset(0, 5)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          item['image'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Text(
                            item['type'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              color: Colors.orange[600],
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange[800]!,
                                  Colors.orange[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text(
                                'أخذ القطعة',
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
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
