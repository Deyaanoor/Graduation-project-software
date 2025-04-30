import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/news_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Admin/Garage/garage_page.dart';
import 'package:flutter_provider/screens/Owner/Employee/employee_screen.dart';
import 'package:flutter_provider/screens/Owner/OverviewPage.dart';
import 'package:flutter_provider/screens/Technician/Home/mobile_appbar.dart';
import 'package:flutter_provider/screens/Technician/reports/RecordOptionsSection.dart';
import 'package:flutter_provider/widgets/UserProfileCard.dart';
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
    final isSidebarExpanded = ref.watch(isSidebarExpandedProvider);
    final lang = ref.watch(languageProvider);

    final userIdAsync = ref.watch(userIdProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedIndex == 0 && userIdAsync.value != null) {
        ref.read(newsProvider.notifier).refreshNews(userIdAsync.value!);
      }
    });

    return userIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        print("❌ Error loading userId: $err");
        return Center(child: Text("Error loading user ID"));
      },
      data: (userId) {
        if (userId == null) {
          return Center(child: Text("User ID not found"));
        }

        final userInfoAsync = ref.watch(getUserInfoProvider(userId));

        return userInfoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            print("❌ Error loading user info: $err");
            return Center(child: Text("Error loading user info"));
          },
          data: (userInfo) {
            final userRole = userInfo['role'];
            final List<Widget> _pages = _getPagesByRole(userRole, ref);

            return LayoutBuilder(
              builder: (context, constraints) {
                if (ResponsiveHelper.isMobile(context)) {
                  return _buildMobileLayout(
                      context, lang, selectedIndex, _pages, ref, userInfo);
                } else {
                  return _buildDesktopLayout(context, lang, selectedIndex,
                      _pages, ref, isSidebarExpanded, userInfo);
                }
              },
            );
          },
        );
      },
    );
  }

  void _resetSelectedIndex(WidgetRef ref) {
    ref.read(isEditModeProvider.notifier).state = false;
  }

  List<Widget> _getPagesByRole(String role, WidgetRef ref) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [
          GaragePage(),
        ];
      case 'owner':
        return [
          OverviewPage(),
          ReportsPageList(),
          EmployeeListScreen(key: UniqueKey()),
          NewsPage(),
          RecordOptionsSection(),
          ReportPage(key: UniqueKey()),
        ];
      case 'employee':
        return [
          NewsPage(),
          ReportsPageList(),
          ChatBotPage(),
          SparePartsApp(),
          RecordOptionsSection(),
          ReportPage(key: UniqueKey()),
        ];
      default:
        return [];
    }
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    List<Widget> pages,
    WidgetRef ref,
    Map<String, dynamic> userInfo,
  ) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 248, 149, 36), // لون الخلفية الأساسي
      appBar: CustomAppBar(userInfo: userInfo),
      body: Container(
        color: const Color.fromARGB(255, 248, 149, 36), // نفس لون الخلفية
        padding: EdgeInsets.only(top: 10), // تأكد إنه ما فيه padding من فوق
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavBar(lang, selectedIndex, ref, userInfo['role']),
      drawer: _buildDrawer(context, lang, userInfo),
    );
  }

  Widget _buildBottomNavBar(
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
    String userRole,
  ) {
    if (userRole.toLowerCase() == 'admin') {
      return CurvedNavigationBar(
        color: const Color(0xFFFF8F00),
        backgroundColor: Colors.grey[200]!,
        items: <Widget>[
          buildNavItem(
              Icons.auto_awesome, lang['car_Ai'] ?? 'Car AI', 3, selectedIndex),
        ],
        onTap: (index) =>
            ref.read(selectedIndexProvider.notifier).state = index,
      );
    } else if (userRole.toLowerCase() == 'owner') {
      return CurvedNavigationBar(
        color: const Color(0xFFFF8F00),
        backgroundColor: Colors.grey[200]!,
        items: <Widget>[
          buildNavItem(Icons.dashboard, lang['dashboard'] ?? 'Dashboard', 0,
              selectedIndex),
          buildNavItem(Icons.calendar_today, lang['report'] ?? 'Report', 1,
              selectedIndex),
          buildNavItem(
              Icons.article, lang['Employee'] ?? 'Employee', 2, selectedIndex),
        ],
        onTap: (index) =>
            ref.read(selectedIndexProvider.notifier).state = index,
      );
    } else if (userRole.toLowerCase() == 'employee') {
      return CurvedNavigationBar(
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
      );
    }
    throw Exception('Unsupported user role: $userRole');
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    List<Widget> pages,
    WidgetRef ref,
    bool isSidebarExpanded,
    Map<String, dynamic> userInfo,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: DesktopCustomAppBar(userInfo: userInfo),
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
                _buildUserHeader(isSidebarExpanded, userInfo),
                Expanded(
                  child: _buildSidebarContent(
                    context,
                    lang,
                    selectedIndex,
                    ref,
                    isSidebarExpanded,
                    userInfo,
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
    Map<String, dynamic> userInfo,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainNavSection(
              context, lang, selectedIndex, ref, isExpanded, userInfo['role']),
          _buildSecondaryNavSection(
              context, lang, selectedIndex, ref, isExpanded, userInfo['role']),
          _buildSettingsSection(context, lang, isExpanded),
        ],
      ),
    );
  }

  Widget _buildUserHeader(
    bool isExpanded,
    Map<String, dynamic> userInfo,
  ) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: UserProfileCard(
        isExpanded: isExpanded,
        userInfo: userInfo,
      ),
    );
  }

  Widget _buildMainNavSection(
    BuildContext context,
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
    bool isExpanded,
    String userRole,
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
          if (userRole.toLowerCase() == 'admin' ||
              userRole.toLowerCase() == 'owner')
            _buildNavButton(
              context: context,
              icon: Icons.dashboard,
              label: lang['dashboard'] ?? 'Dashboard',
              isSelected: selectedIndex == 0,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 0,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.article,
              label: lang['news'] ?? 'News',
              isSelected: userRole.toLowerCase() == 'owner'
                  ? selectedIndex == 1
                  : selectedIndex == 0,
              onTap: () => ref.read(selectedIndexProvider.notifier).state =
                  userRole.toLowerCase() == 'owner' ? 1 : 0,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.calendar_today,
              label: lang['report'] ?? 'Reports',
              isSelected: userRole.toLowerCase() == 'owner'
                  ? selectedIndex == 2
                  : selectedIndex == 1,
              onTap: () => ref.read(selectedIndexProvider.notifier).state =
                  userRole.toLowerCase() == 'owner' ? 2 : 1,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.auto_awesome,
              label: lang['car_Ai'] ?? 'Car AI',
              isSelected: userRole.toLowerCase() == 'employee' ||
                      userRole.toLowerCase() == 'owner'
                  ? selectedIndex == 3
                  : selectedIndex == 2,
              onTap: () => ref.read(selectedIndexProvider.notifier).state =
                  userRole.toLowerCase() == 'employee' ||
                          userRole.toLowerCase() == 'owner'
                      ? 3
                      : 2,
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
    String userRole,
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
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.build,
              label: lang['spare_parts'] ?? 'Spare Parts',
              isSelected: userRole.toLowerCase() == 'employee' ||
                      userRole.toLowerCase() == 'owner'
                  ? selectedIndex == 4
                  : selectedIndex == 3,
              onTap: () => ref.read(selectedIndexProvider.notifier).state =
                  userRole.toLowerCase() == 'admin' ||
                          userRole.toLowerCase() == 'owner'
                      ? 4
                      : 3,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.assignment,
              label: lang['attendance'] ?? 'Attendance',
              isSelected: userRole.toLowerCase() == 'admin' ||
                      userRole.toLowerCase() == 'owner'
                  ? selectedIndex == 6
                  : selectedIndex == 5,
              onTap: () {
                ref.read(isEditModeProvider.notifier).state = false;

                ref.read(selectedReportProvider.notifier).state = null;
                ref.read(selectedIndexProvider.notifier).state =
                    userRole.toLowerCase() == 'admin' ||
                            userRole.toLowerCase() == 'owner'
                        ? 6
                        : 5;
              },
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

  Drawer _buildDrawer(
    BuildContext context,
    Map<String, String> lang,
    Map<String, dynamic> userInfo,
  ) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserProfileCard(
              isMobile: true,
              userInfo: userInfo,
            ),
            if (userInfo['role'].toLowerCase() == 'owner' ||
                userInfo['role'].toLowerCase() == 'admin')
              buildDrawerItem(context, lang['dashboard'] ?? 'Dashboard',
                  Icons.dashboard, NewsPage()),
            if (userInfo['role'].toLowerCase() == 'owner' ||
                userInfo['role'].toLowerCase() == 'employee')
              buildDrawerItem(
                context,
                lang['news'] ?? 'News',
                Icons.article,
                NewsPage(),
              ),
            if (userInfo['role'].toLowerCase() == 'owner' ||
                userInfo['role'].toLowerCase() == 'employee')
              buildDrawerItem(
                context,
                lang['report'] ?? 'Reports',
                Icons.assignment,
                ReportsPageList(),
              ),
            if (userInfo['role'].toLowerCase() == 'owner' ||
                userInfo['role'].toLowerCase() == 'employee')
              buildDrawerItem(
                context,
                lang['car_Ai'] ?? 'Car AI',
                Icons.auto_awesome,
                ChatBotPage(),
              ),
            if (userInfo['role'].toLowerCase() == 'owner' ||
                userInfo['role'].toLowerCase() == 'employee')
              buildDrawerItem(
                context,
                lang['spare_parts'] ?? 'Spare Parts',
                Icons.build,
                SparePartsApp(),
              ),
            if (userInfo['role'].toLowerCase() == 'owner' ||
                userInfo['role'].toLowerCase() == 'employee')
              buildDrawerItem(
                context,
                lang['attendance'] ?? 'Attendance',
                Icons.calendar_today,
                AttendanceSalaryPage(),
              ),
            buildDrawerItem(
              context,
              lang['settings'] ?? 'Settings',
              Icons.settings,
              SettingsPage(),
            ),
          ],
        ),
      ),
    );
  }
}
