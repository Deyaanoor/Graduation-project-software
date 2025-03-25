import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/Responsive_helper.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/Technician/AttendancePage.dart';
import 'package:flutter_provider/screens/Technician/Home/Desktop_appbar.dart';
import 'package:flutter_provider/screens/Technician/Home/drawer_item.dart';
import 'package:flutter_provider/screens/Technician/Home/nav_item.dart';
import 'package:flutter_provider/screens/Technician/NewsPage.dart';
import 'package:flutter_provider/screens/Technician/SparePartsPage.dart';
import 'package:flutter_provider/screens/Technician/chat_bot_page.dart';
import 'package:flutter_provider/screens/Technician/reports/ReportsListPage.dart';
import 'package:flutter_provider/screens/Technician/reports/report.dart';
import 'package:flutter_provider/screens/Technician/settings/SettingsPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final lang = ref.watch(languageProvider);

    final List<Widget> _pages = [
      NewsPage(),
      ReportsPage(),
      ChatBotPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isMobile(context)) {
          return _buildMobileLayout(context, lang, selectedIndex, _pages, ref);
        } else {
          return _buildDesktopLayout(context, lang, selectedIndex, _pages, ref);
        }
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    List<Widget> pages,
    WidgetRef ref,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(lang['home'] ?? 'Home'),
        backgroundColor: Colors.orange,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xFFFF8F00),
        backgroundColor: Colors.grey[200]!,
        items: <Widget>[
          buildNavItem(Icons.article, lang['news'] ?? 'News', 0, selectedIndex),
          buildNavItem(Icons.calendar_today, lang['report'] ?? 'Report', 1,
              selectedIndex),
          buildNavItem(
              Icons.auto_awesome, lang['car_Ai'] ?? 'Car AI', 2, selectedIndex),
        ],
        onTap: (index) =>
            ref.read(selectedIndexProvider.notifier).state = index,
      ),
      drawer: _buildDrawer(context, lang),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    List<Widget> pages,
    WidgetRef ref,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: DesktopCustomAppBar(),
      body: Row(
        children: [
          // Side Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(),
                  _buildMainNavSection(context, lang, selectedIndex, ref),
                  _buildSecondaryNavSection(context, lang),
                  _buildSettingsSection(context, lang),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(''),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jane Doe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'jane.doe@example.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainNavSection(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Main Navigation'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildNavButton(
            context: context,
            icon: Icons.article,
            label: lang['news'] ?? 'News',
            isSelected: selectedIndex == 0,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 0,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.calendar_today,
            label: lang['report'] ?? 'Reports',
            isSelected: selectedIndex == 1,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.auto_awesome,
            label: lang['car_Ai'] ?? 'Car AI',
            isSelected: selectedIndex == 2,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryNavSection(
      BuildContext context, Map<String, String> lang) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More Features'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildNavButton(
            context: context,
            icon: Icons.build,
            label: lang['spare_parts'] ?? 'Spare Parts',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SparePartsApp())),
          ),
          _buildNavButton(
            context: context,
            icon: Icons.map,
            label: lang['map'] ?? 'Map',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ReportPage())),
          ),
          _buildNavButton(
            context: context,
            icon: Icons.chat,
            label: lang['chat_with_admin'] ?? 'Chat',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ReportPage())),
          ),
          _buildNavButton(
            context: context,
            icon: Icons.assignment,
            label: lang['attendance'] ?? 'Attendance',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AttendanceSalaryPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, Map<String, String> lang) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(),
          _buildNavButton(
            context: context,
            icon: Icons.settings,
            label: lang['settings'] ?? 'Settings',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SettingsPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.orange[300]!, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.orange[800] : Colors.grey[700],
                size: 22),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? Colors.orange[800] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, Map<String, String> lang) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1485290334039-a3c69043e517',
                ),
              ),
              accountEmail: Text(
                'jane.doe@example.com',
                style: TextStyle(color: Colors.black87),
              ),
              accountName: Text(
                'Jane Doe',
                style: TextStyle(fontSize: 24.0, color: Colors.black87),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            buildDrawerItem(
              context,
              lang['home'] ?? '',
              Icons.home,
              ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['report'] ?? '',
              Icons.assignment,
              ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['attendance'] ?? '',
              Icons.calendar_today,
              AttendanceSalaryPage(),
            ),
            buildDrawerItem(
              context,
              lang['spare_parts'] ?? '',
              Icons.build,
              SparePartsApp(),
            ),
            buildDrawerItem(
              context,
              lang['map'] ?? '',
              Icons.map,
              ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['chat_with_admin'] ?? '',
              Icons.chat,
              ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['settings'] ?? '',
              Icons.settings,
              SettingsPage(),
            ),
          ],
        ),
      ),
    );
  }
}
