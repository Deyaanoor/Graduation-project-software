import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Admin/reports_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  // قائمة بالبيانات التي سيتم عرضها في الـ GridView
  final List<Map<String, dynamic>> statsData = [
    {'value': '150', 'label': 'Cars Fixed', 'icon': Icons.directions_car},
    {'value': '\$25,000', 'label': 'Revenue', 'icon': Icons.attach_money},
    {'value': '18', 'label': 'Present Employees', 'icon': Icons.groups},
    {'value': '5', 'label': 'Unpaid Invoices', 'icon': Icons.warning},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/profile.jpg'),
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text('Admin',
                      style: GoogleFonts.poppins(
                          fontSize: 20, color: Colors.white)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home'),
            _buildDrawerItem(Icons.person, 'Employees'),
            _buildDrawerItem(Icons.receipt_long, 'Invoices'),
            _buildDrawerItem(Icons.inventory, 'Inventory'),
            _buildDrawerItem(Icons.bar_chart, 'Reports'),
            _buildDrawerItem(Icons.settings, 'Settings'),
            _buildDrawerItem(Icons.help, 'Help'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildActionButton('Add Employee', Icons.person_add),
                _buildActionButton('Invoice', Icons.receipt),
                _buildActionButton('Search Car', Icons.search),
                _buildActionButton('Order Parts', Icons.build),
              ],
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 165 / 52,
              children: [
                _buildDashboardButton(context, 'Employees', Icons.person),
                _buildDashboardButton(context, 'Invoices', Icons.receipt_long),
                _buildDashboardButton(context, 'Inventory', Icons.inventory),
                _buildDashboardButton(context, 'Reports', Icons.receipt_long),
                _buildDashboardButton(context, 'Chart', Icons.bar_chart),
              ],
            ),
            SizedBox(height: 20),
            // استخدام GridView.builder لعرض البطاقات ديناميكيًا
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عدد الأعمدة
                crossAxisSpacing: 10, // المسافة الأفقية بين العناصر
                mainAxisSpacing: 10, // المسافة الرأسية بين العناصر
                childAspectRatio: 1.5, // نسبة العرض إلى الارتفاع
              ),
              itemCount: statsData.length, // عدد العناصر
              itemBuilder: (context, index) {
                return _buildStatsCard(
                  statsData[index]['value'],
                  statsData[index]['label'],
                  statsData[index]['icon'],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Invoices'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Help'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () {},
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, IconData icon) {
    return SizedBox(
      width: 165,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(10),
          backgroundColor: Color(0xFF636AE8).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (title == 'Reports') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportsScreen()),
            );
          }
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String value, String label, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      onPressed: () {},
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
