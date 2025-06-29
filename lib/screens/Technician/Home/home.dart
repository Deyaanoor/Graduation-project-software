import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/news_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Admin/Garage/ContactUsInboxPage.dart';
import 'package:flutter_provider/screens/Admin/Garage/garage_page.dart';
import 'package:flutter_provider/screens/Admin/Garage/plan_Page.dart';
import 'package:flutter_provider/screens/Admin/Garage/registrationRequests.dart';
import 'package:flutter_provider/screens/Client/ClientGaragesPage.dart';
import 'package:flutter_provider/screens/Client/EmergencyRequestPage.dart';
import 'package:flutter_provider/screens/Client/GarageRequestsPage.dart';
import 'package:flutter_provider/screens/Client/RequestDetailsPage.dart';
import 'package:flutter_provider/screens/Client/client_screen.dart';
import 'package:flutter_provider/screens/Client/garageDetails.dart';
import 'package:flutter_provider/screens/Owner/Employee/employee_garage_info_screen.dart';
import 'package:flutter_provider/screens/Owner/Employee/employee_screen.dart';
import 'package:flutter_provider/screens/Owner/GarageInfoScreen.dart';
import 'package:flutter_provider/screens/Owner/OverviewPage.dart';
import 'package:flutter_provider/screens/Technician/Home/mobile_appbar.dart';
import 'package:flutter_provider/screens/Technician/reports/RecordOptionsSection.dart';
import 'package:flutter_provider/screens/Client/roboflow_screen.dart';
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
import 'package:flutter_provider/screens/Admin/Garage/Dashboard.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isSidebarExpanded = ref.watch(isSidebarExpandedProvider);
    final lang = ref.watch(languageProvider);

    final userIdAsync = ref.watch(userIdProvider);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (selectedIndex == 0 && userIdAsync.value != null) {
    //     ref.read(newsProvider.notifier).refreshNews(userIdAsync.value!);
    //   }
    // });

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
        print("UseerId: $userId");

        print("userInfoAsync: $userInfoAsync");
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
          ContactUsInboxPage(),
          RegistrationRequests(),
          AdminDashboardPage(),
          PlansPage(),
        ];
      case 'owner':
        return [
          OverviewPage(key: UniqueKey()),
          ReportsPageList(key: UniqueKey()),
          RecordOptionsSection(),
          ReportPage(key: UniqueKey()),
          NewsPage(),
          EmployeeListScreen(key: UniqueKey()),
          ClientListScreen(key: UniqueKey()),
          GarageRequestsPage(key: UniqueKey()),
          RequestDetailsPage(key: UniqueKey()),
          GarageInfoScreen(key: UniqueKey()),
        ];
      case 'employee':
        return [
          NewsPage(),
          ReportsPageList(key: UniqueKey()),
          RecordOptionsSection(),
          ReportPage(key: UniqueKey()),
          EmployeeGarageInfoPage(key: UniqueKey()),
        ];
      case 'client':
        return [
          ClientGaragesPage(),
          RoboflowScreen(),
          ChatBotPage(),
          SettingsPage(),
          RequestDetailsPage(key: UniqueKey()),
          LegendaryTabBar(key: UniqueKey()),
          EmergencyRequestPage(key: UniqueKey()),
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
      backgroundColor: const Color.fromARGB(255, 248, 149, 36),
      appBar: CustomAppBar(userInfo: userInfo),
      body: Container(
        color: const Color.fromARGB(255, 248, 149, 36),
        padding: const EdgeInsets.only(top: 10),
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: userInfo['role'].toLowerCase() == 'client'
          ? _buildClientBottomNavBar(lang, selectedIndex, ref)
          : _buildBottomNavBar(lang, selectedIndex, ref, userInfo['role']),
      drawer: _buildDrawer(context, ref, lang, userInfo),
    );
  }

  Widget _buildBottomNavBar(
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
    String userRole,
  ) {
    final theme = Theme.of(ref.context);

    final orange = theme.colorScheme.primary; // برتقالي من الثيم

    if (userRole.toLowerCase() == 'admin') {
      return CurvedNavigationBar(
        color: orange,
        backgroundColor: theme.scaffoldBackgroundColor,
        items: <Widget>[
          buildNavItem(Icons.dashboard, lang['dashboard'] ?? 'Dashboard', 0,
              selectedIndex),
          buildNavItem(
              Icons.support, lang['support'] ?? 'support', 1, selectedIndex),
          buildNavItem(Icons.markunread_mailbox, lang['request'] ?? 'request',
              2, selectedIndex),
        ],
        onTap: (index) =>
            ref.read(selectedIndexProvider.notifier).state = index,
      );
    } else if (userRole.toLowerCase() == 'owner') {
      return CurvedNavigationBar(
        color: orange,
        backgroundColor: theme.scaffoldBackgroundColor,
        items: <Widget>[
          buildNavItem(Icons.dashboard, lang['dashboard'] ?? 'Dashboard', 0,
              selectedIndex),
          buildNavItem(Icons.calendar_today, lang['reports'] ?? 'Report', 1,
              selectedIndex),
          buildNavItem(Icons.article, lang['news'] ?? 'News', 4, selectedIndex),
        ],
        onTap: (index) {
          if (index == 2) {
            index = 4;
          }
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      );
    } else if (userRole.toLowerCase() == 'employee') {
      return CurvedNavigationBar(
        color: orange,
        backgroundColor: theme.scaffoldBackgroundColor,
        items: <Widget>[
          buildNavItem(Icons.article, lang['news'] ?? 'News', 0, selectedIndex),
          buildNavItem(Icons.calendar_today, lang['reports'] ?? 'Report', 1,
              selectedIndex),
          buildNavItem(
              Icons.garage, lang['Garagey'] ?? 'Garagey ', 4, selectedIndex),
        ],
        onTap: (index) {
          if (index == 2) {
            index = 4;
          }
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      );
    }
    throw Exception('Unsupported user role: $userRole');
  }

  Widget _buildClientBottomNavBar(
    Map<String, String> lang,
    int selectedIndex,
    WidgetRef ref,
  ) {
    final theme = Theme.of(ref.context);

    // اختر ألوان متناسبة مع الثيم
    final selectedColor = theme.colorScheme.primary; // برتقالي أو حسب الثيم
    final unselectedColor = theme.brightness == Brightness.dark
        ? Colors.grey[400]
        : Colors.grey[700];

    if (selectedIndex >= 3) {
      selectedIndex = 0;
    }
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      backgroundColor: theme.colorScheme.background,
      onTap: (index) => ref.read(selectedIndexProvider.notifier).state = index,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.garage),
          label: lang['Garagey'] ?? 'garages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.memory),
          label: lang['IconIQ '] ?? 'IconIQ ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: lang['AutoCheck'] ?? 'AutoCheck',
        ),
      ],
    );
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
          userInfo['role'].toLowerCase() == 'client'
              ? const SizedBox()
              : _buildSecondaryNavSection(context, lang, selectedIndex, ref,
                  isExpanded, userInfo['role']),
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
                (lang['mainNavigation'] ?? 'Main Navigation').toUpperCase(),
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
          if (userRole.toLowerCase() == 'admin')
            _buildNavButton(
              context: context,
              icon: Icons.support_agent,
              label: lang['ContactUsInboxPage'] ?? 'ContactUsInboxPage',
              isSelected: selectedIndex == 1,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'admin')
            _buildNavButton(
              context: context,
              icon: Icons.how_to_reg,
              label: lang['registrationRequests'] ?? 'registrationRequests',
              isSelected: selectedIndex == 2,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 2,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'admin')
            _buildNavButton(
              context: context,
              icon: Icons.analytics,
              label: lang['statics'] ?? 'statics',
              isSelected: selectedIndex == 3,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 3,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'admin')
            _buildNavButton(
              context: context,
              icon: Icons.event_note,
              label: lang['plan'] ?? 'plans',
              isSelected: selectedIndex == 4,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 4,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.article,
              label: lang['news'] ?? 'News',
              isSelected: userRole.toLowerCase() == 'owner'
                  ? selectedIndex == 4
                  : selectedIndex == 0,
              onTap: () => ref.read(selectedIndexProvider.notifier).state =
                  userRole.toLowerCase() == 'owner' ? 4 : 0,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'client')
            _buildNavButton(
              context: context,
              icon: Icons.garage,
              label: lang['garage'] ?? 'Garage',
              isSelected: selectedIndex == 0,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 0,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'client')
            _buildNavButton(
              context: context,
              icon: Icons.memory,
              label: lang['IconIQ '] ?? 'IconIQ ',
              isSelected: selectedIndex == 1,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'client')
            _buildNavButton(
              context: context,
              icon: Icons.auto_awesome,
              label: lang['AutoCheck'] ?? 'AutoCheck',
              isSelected: selectedIndex == 2,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 2,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'client')
            _buildNavButton(
              context: context,
              icon: Icons.emergency,
              label: lang['EmergencyRequest'] ?? 'EmergencyRequest',
              isSelected: selectedIndex == 6,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 6,
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
              child: (userRole.toLowerCase() != 'admin')
                  ? Text(
                      'More Features'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : SizedBox(),
            ),
          if (userRole.toLowerCase() == 'owner' ||
              userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.calendar_today,
              label: lang['reports'] ?? 'Reports',
              isSelected: selectedIndex == 1,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'employee')
            _buildNavButton(
              context: context,
              icon: Icons.analytics,
              label: lang['statics'] ?? 'Statics',
              isSelected: selectedIndex == 4,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 4,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner')
            _buildNavButton(
              context: context,
              icon: Icons.people_outline,
              label: lang['Employees'] ?? 'Employees',
              isSelected: selectedIndex == 5,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 5,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner')
            _buildNavButton(
              context: context,
              icon: Icons.people_alt,
              label: lang['Clients'] ?? 'Clients',
              isSelected: selectedIndex == 6,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 6,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner')
            _buildNavButton(
              context: context,
              icon: Icons.markunread_mailbox,
              label: lang['requests'] ?? 'Request',
              isSelected: selectedIndex == 7,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 7,
              isExpanded: isExpanded,
            ),
          if (userRole.toLowerCase() == 'owner')
            _buildNavButton(
              context: context,
              icon: Icons.event_note,
              label: lang['Subscription'] ?? 'Subscription ',
              isSelected: selectedIndex == 9,
              onTap: () => ref.read(selectedIndexProvider.notifier).state = 9,
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
    WidgetRef ref,
    Map<String, String> lang,
    Map<String, dynamic> userInfo,
  ) {
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // خلفية متجاوبة مع الثيم
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserProfileCard(
              isMobile: true,
              userInfo: userInfo,
            ),
            if (userInfo['role'].toLowerCase() == 'owner')
              buildDrawerItem(
                context,
                ref,
                lang['Employees'] ?? 'Employees',
                Icons.people_outline,
                5,
              ),
            if (userInfo['role'].toLowerCase() == 'owner')
              buildDrawerItem(
                context,
                ref,
                lang['Clients'] ?? 'Client',
                Icons.people,
                6,
              ),
            if (userInfo['role'].toLowerCase() == 'owner')
              buildDrawerItem(
                context,
                ref,
                lang['requests'] ?? 'Request',
                Icons.markunread_mailbox,
                7,
              ),
            if (userInfo['role'].toLowerCase() == 'owner')
              buildDrawerItem(
                context,
                ref,
                lang['Subscription'] ?? 'Subscription',
                Icons.event_note,
                9,
              ),
            if (userInfo['role'].toLowerCase() == 'client')
              buildDrawerItem(
                context,
                ref,
                lang['EmergencyRequest'] ?? 'Emergency Request',
                Icons.emergency,
                6,
              ),
            if (userInfo['role'].toLowerCase() == 'admin')
              buildDrawerItem(
                context,
                ref,
                lang['statics'] ?? 'Statics',
                Icons.analytics,
                3,
              ),
            if (userInfo['role'].toLowerCase() == 'admin')
              buildDrawerItem(
                context,
                ref,
                lang['garages'] ?? 'Garage',
                Icons.garage,
                0,
              ),
            if (userInfo['role'].toLowerCase() == 'admin')
              buildDrawerItem(
                context,
                ref,
                lang['ContactUsInboxPage'] ?? 'ContactUsInboxPage',
                Icons.support_agent,
                1,
              ),
            if (userInfo['role'].toLowerCase() == 'admin')
              buildDrawerItem(
                context,
                ref,
                lang['registrationRequests'] ?? 'registrationRequests',
                Icons.how_to_reg,
                2,
              ),
            if (userInfo['role'].toLowerCase() == 'admin')
              buildDrawerItem(
                context,
                ref,
                lang['plans'] ?? 'Plans',
                Icons.event_note,
                4,
              ),
            if (userInfo['role'].toLowerCase() != 'admin')
              buildDrawerItem(
                context,
                ref,
                lang['contactUs'] ?? 'contact Us',
                Icons.contact_support,
                -2,
              ),
            buildDrawerItem(
              context,
              ref,
              lang['settings'] ?? 'Settings',
              Icons.settings,
              -1,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: <Widget>[
                  Image.network(
                    'https://i.postimg.cc/prZL3jYb/edit-the-uploaded-image-to-make-it-suitable-for-an-app-icon-removebg-preview.png',
                    height: 180,
                    width: 160,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
