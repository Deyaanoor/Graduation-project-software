import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/screens/Owner/notifications/notifications_screen.dart';
import 'package:flutter_provider/screens/Technician/Home/home.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';
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

class _DesktopCustomAppBarState extends ConsumerState<DesktopCustomAppBar> {
  bool showNotifications = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(userIdProvider).value;

      if (userId != null) {
        ref
            .read(notificationsProvider.notifier)
            .fetchUnreadCount(adminId: userId, ref: ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountStateProvider);
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
                        'https://i.postimg.cc/65vkqwg3/cleaned-image-3-removebg-preview.png',
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
                    _buildDesktopActions(context, widget.userInfo, unreadCount)
                  else
                    _buildMobileMenu(context),
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
              child: Center(
                child: Text(
                  'Welcome,Deyaa!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActions(
      BuildContext context, Map<String, dynamic> userInfo, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "contactUs"),
              child: const Text(
                'Contact Us',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 30),
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            if (userInfo['role'] == 'owner' || userInfo['role'] == 'employee')
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
            _buildProfileMenu(context, userInfo),
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

  Widget _buildMobileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white, size: 30),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Contact Us',
          child: ListTile(
            leading: Icon(Icons.contact_page),
            title: Text('Contact Us'),
          ),
        ),
        const PopupMenuItem(
          value: 'Search',
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
          ),
        ),
        const PopupMenuItem(
          value: 'Notifications',
          child: ListTile(
            leading: Badge(
              label: Text('3'),
              child: Icon(Icons.notifications),
            ),
            title: Text('Notifications'),
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

  Widget _buildProfileMenu(
      BuildContext context, Map<String, dynamic> userInfo) {
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem<String>(
          value: 'Profile',
          child: Text('Profile'),
        ),
        PopupMenuItem<String>(
          value: 'Settings',
          child: Text('Settings'),
        ),
        PopupMenuItem<String>(
          value: 'Logout',
          child: Text('Logout'),
        ),
      ],
    );
  }
}
