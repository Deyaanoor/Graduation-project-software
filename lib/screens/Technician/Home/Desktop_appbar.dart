import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/screens/Owner/notifications/notifications_screen.dart';
import 'package:flutter_provider/screens/Technician/Home/home.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';
import 'package:flutter_provider/screens/contactUs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopCustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const DesktopCustomAppBar({Key? key, required this.userInfo})
      : super(key: key);
  final Map<String, dynamic> userInfo;

  @override
  Size get preferredSize => const Size.fromHeight(130.0);

  @override
  ConsumerState<DesktopCustomAppBar> createState() =>
      _DesktopCustomAppBarState();
}

class _DesktopCustomAppBarState extends ConsumerState<DesktopCustomAppBar>
    with RouteAware {
  bool showNotifications = false;
  OverlayEntry? _overlayEntry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // لما ترجع للصفحة، نفذ التحديث
    final userId = ref.read(userIdProvider).value;
    if (userId != null) {
      ref.watch(unreadCountProvider(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value;
    final unreadCount = ref.watch(unreadCountProvider(userId!));
    final lang = ref.watch(languageProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      elevation: 15,
      toolbarHeight: 100,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade700,
              const Color.fromARGB(255, 252, 78, 26)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(),
                      child: Image.network(
                        'https://i.postimg.cc/3wy0RfzK/Management-Application-for-Mechanic-Workshop-removebg-preview.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (screenWidth > 1100)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Home()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Management Application ',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.amber.shade700,
                                      blurRadius: 15,
                                      offset: const Offset(2, 2),
                                    ),
                                    Shadow(
                                      color: Colors.deepOrange.shade900,
                                      blurRadius: 25,
                                      offset: const Offset(-2, -2),
                                    ),
                                  ],
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        Colors.yellow.shade100,
                                        Colors.amber.shade400,
                                        Colors.orange.shade700,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 400, 100),
                                    ),
                                ),
                              ),
                              TextSpan(
                                text: 'for Mechanic Workshop',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blueGrey.shade800,
                                      blurRadius: 15,
                                      offset: const Offset(2, 2),
                                    ),
                                    Shadow(
                                      color: Colors.orange.shade600,
                                      blurRadius: 25,
                                      offset: const Offset(-2, -2),
                                    ),
                                  ],
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        const Color.fromARGB(
                                            255, 249, 250, 250),
                                        const Color.fromARGB(
                                            255, 222, 231, 236),
                                        const Color.fromARGB(255, 31, 133, 180),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 400, 100),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (screenWidth > 600)
                    unreadCount.when(
                      data: (count) => _buildDesktopActions(
                          context, widget.userInfo, count, lang),
                      loading: () => const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      error: (err, stack) =>
                          Icon(Icons.error, color: Colors.red),
                    )
                  else
                    _buildMobileMenu(context, lang),
                ],
              ),
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade800, Colors.deepOrange.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActions(
      BuildContext context,
      Map<String, dynamic> userInfo,
      int unreadCount,
      Map<String, String> lang) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            if (userInfo['role'] != 'admin')
              TextButton(
                onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 600,
                          height: 400,
                          child: ContactUsPage(),
                        ),
                      ),
                    ),
                  )
                },
                child: Text(
                  lang['contactUs'] ?? 'Contact Us',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            if (userInfo['role'] == 'owner' ||
                userInfo['role'] == 'employee' ||
                userInfo['role'] == 'admin')
              IconButton(
                icon: unreadCount > 0
                    ? Badge(
                        label: Text(
                          unreadCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.notifications,
                            color: Colors.white, size: 30),
                      )
                    : const Icon(Icons.notifications,
                        color: Colors.white, size: 30),
                onPressed: () {
                  if (_overlayEntry == null) {
                    _showNotifications(context);
                  } else {
                    _hideNotifications();
                  }
                },
              ),
            const SizedBox(width: 10),
            _buildProfileMenu(context, userInfo, lang),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }

  void _hideNotifications() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showNotifications(BuildContext context) {
    final overlay = Overlay.of(context);
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _hideNotifications();
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: position.dy + box.size.height - 60,
            right: position.dx + 120,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 350,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: NotificationsPage(), // صفحتك
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildMobileMenu(BuildContext context, Map<String, String> lang) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white, size: 30),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Contact Us',
          child: ListTile(
            leading: const Icon(Icons.contact_page),
            title: Text(lang['contactUs'] ?? 'Contact Us'),
          ),
        ),
        PopupMenuItem(
          value: 'Search',
          child: ListTile(
            leading: const Icon(Icons.search),
            title: Text(lang['search'] ?? 'Search'),
          ),
        ),
        PopupMenuItem(
          value: 'Notifications',
          child: ListTile(
            leading: Badge(
              label: Text('3'),
              child: const Icon(Icons.notifications),
            ),
            title: Text(lang['notifications'] ?? 'Notifications'),
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'Contact Us':
            Navigator.pushNamed(context, "contactUs");
            break;
          case 'Search':
            break;
          case 'Notifications':
            break;
        }
      },
    );
  }

  Widget _buildProfileMenu(BuildContext context, Map<String, dynamic> userInfo,
      Map<String, String> lang) {
    final avatarUrl = userInfo['avatar'];
    final hasAvatar = avatarUrl != null && avatarUrl.toString().isNotEmpty;

    return PopupMenuButton<String>(
      icon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
          child: !hasAvatar
              ? const Icon(Icons.person, size: 28, color: Colors.orange)
              : null,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'Profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'Settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'Logout':
            ref.read(logoutProvider)();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'Profile',
          child: Text(lang['profile'] ?? 'Profile'),
        ),
        PopupMenuItem<String>(
          value: 'Settings',
          child: Text(lang['settings'] ?? 'Settings'),
        ),
        PopupMenuItem<String>(
          value: 'Logout',
          child: Text(lang['logout'] ?? 'Logout'),
        ),
      ],
    );
  }
}
