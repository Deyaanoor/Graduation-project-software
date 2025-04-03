import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/news_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    print(selectedIndex);
    final isSidebarExpanded = ref.watch(isSidebarExpandedProvider);
    final lang = ref.watch(languageProvider);

    if (selectedIndex == 0) {
      ref.read(newsProvider.notifier).refreshNews();
    }

    final List<Widget> _pages = [
      NewsPage(),
      ReportsPage(),
      ChatBotPage(),
      SparePartsApp(),
      ReportPage(),
      AttendanceSalaryPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isMobile(context)) {
          return _buildMobileLayout(context, lang, selectedIndex, _pages, ref);
        } else {
          return _buildDesktopLayout(
            context,
            lang,
            selectedIndex,
            _pages,
            ref,
            isSidebarExpanded,
          );
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
    bool isSidebarExpanded,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: const DesktopCustomAppBar(),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSidebarExpanded ? 280 : 80,
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
            child: Column(
              children: [
                _buildUserHeader(isSidebarExpanded),
                Expanded(
                  child: _buildSidebarContent(
                    context,
                    lang,
                    selectedIndex,
                    ref,
                    isSidebarExpanded,
                  ),
                ),
                _buildCollapseButton(context, ref, isSidebarExpanded),
              ],
            ),
          ),
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

  Widget _buildSidebarContent(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
    bool isExpanded,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainNavSection(context, lang, selectedIndex, ref, isExpanded),
          _buildSecondaryNavSection(
              context, lang, selectedIndex, ref, isExpanded),
          _buildSettingsSection(context, lang, isExpanded),
        ],
      ),
    );
  }

  Widget _buildUserHeader(bool isExpanded) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: isExpanded
          ? Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1485290334039-a3c69043e517'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ],
            )
          : const Center(
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1485290334039-a3c69043e517'),
              ),
            ),
    );
  }

  Widget _buildMainNavSection(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
    bool isExpanded,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        children: [
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                'Main Navigation'.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          _buildNavButton(
            context: context,
            icon: Icons.article,
            label: lang['news'] ?? 'News',
            isSelected: selectedIndex == 0,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 0,
            isExpanded: isExpanded,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.calendar_today,
            label: lang['report'] ?? 'Reports',
            isSelected: selectedIndex == 1,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
            isExpanded: isExpanded,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.auto_awesome,
            label: lang['car_Ai'] ?? 'Car AI',
            isSelected: selectedIndex == 2,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 2,
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryNavSection(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
    bool isExpanded,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        children: [
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                'More Features'.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          _buildNavButton(
            context: context,
            icon: Icons.build,
            label: lang['spare_parts'] ?? 'Spare Parts',
            isSelected: selectedIndex == 3,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 3,
            isExpanded: isExpanded,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.map,
            label: lang['map'] ?? 'Map',
            isSelected: selectedIndex == 4,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 4,
            isExpanded: isExpanded,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.chat,
            label: lang['chat_with_admin'] ?? 'Chat',
            isSelected: selectedIndex == 5,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 5,
            isExpanded: isExpanded,
          ),
          _buildNavButton(
            context: context,
            icon: Icons.assignment,
            label: lang['attendance'] ?? 'Attendance',
            isSelected: selectedIndex == 6,
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 6,
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    Map<String, String> lang,
    bool isExpanded,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        children: [
          const Divider(),
          _buildNavButton(
            context: context,
            icon: Icons.settings,
            label: lang['settings'] ?? 'Settings',
            isSelected: false,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
            isExpanded: isExpanded,
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
    required bool isExpanded,
  }) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        // تمت إزالة الـ Tooltip
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 15 : 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.orange[300]!, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.orange[800] : Colors.grey[700],
              ),
              if (isExpanded) ...[
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.orange[800] : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton(
    BuildContext context,
    WidgetRef ref,
    bool isExpanded,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(10),
      child: IconButton(
        icon: Icon(
          isExpanded ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.orange[800],
          size: 30,
        ),
        onPressed: () =>
            ref.read(isSidebarExpandedProvider.notifier).state = !isExpanded,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, Map<String, String> lang) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1485290334039-a3c69043e517',
                ),
              ),
              accountEmail: Text(
                'jane.doe@example.com',
                style: TextStyle(color: Colors.black87),
              ),
              accountName: const Text(
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
              const ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['report'] ?? '',
              Icons.assignment,
              const ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['attendance'] ?? '',
              Icons.calendar_today,
              const AttendanceSalaryPage(),
            ),
            buildDrawerItem(
              context,
              lang['spare_parts'] ?? '',
              Icons.build,
              const SparePartsApp(),
            ),
            buildDrawerItem(
              context,
              lang['map'] ?? '',
              Icons.map,
              const ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['chat_with_admin'] ?? '',
              Icons.chat,
              const ReportPage(),
            ),
            buildDrawerItem(
              context,
              lang['settings'] ?? '',
              Icons.settings,
              const SettingsPage(),
            ),
          ],
        ),
      ),
    );
  }
}
