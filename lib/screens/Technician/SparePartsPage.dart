import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/Responsive_helper.dart';
import 'package:flutter_provider/screens/Technician/Home/Desktop_appbar.dart';
import 'package:flutter_provider/screens/Technician/SparePartDetails.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'data.dart';

class SparePartsApp extends StatefulWidget {
  const SparePartsApp({super.key});

  @override
  _SparePartsAppState createState() => _SparePartsAppState();
}

class _SparePartsAppState extends State<SparePartsApp> {
  @override
  Widget build(BuildContext context) {
    double heightItem = ResponsiveHelper.isMobile(context) ? 200 : 400;
    double widthItem = ResponsiveHelper.isMobile(context) ? 150 : 300;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            searchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleList(index),
                      SizedBox(
                        height: heightItem,
                        child: HorizontalItemsList(
                          items: categories[index]['items'],
                          widthItem: widthItem,
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

  Padding titleList(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        categories[index]['title'],
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Container searchBar() {
    return Container(
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class HorizontalItemsList extends StatefulWidget {
  final List<dynamic> items;
  final double widthItem;

  const HorizontalItemsList({
    required this.items,
    required this.widthItem,
    super.key,
  });

  @override
  _HorizontalItemsListState createState() => _HorizontalItemsListState();
}

class _HorizontalItemsListState extends State<HorizontalItemsList> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = false;
  bool _isScrollable = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateButtonVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScrollability());
  }

  void _checkScrollability() {
    final maxWidth = widget.items.length * widget.widthItem;
    final availableWidth = _scrollController.position.viewportDimension;

    setState(() {
      _isScrollable = maxWidth > availableWidth;
      _showRightButton = _isScrollable;
    });
  }

  void _updateButtonVisibility() {
    if (!_isScrollable) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      _showLeftButton = currentScroll > 0;
      _showRightButton = currentScroll < maxScroll;
    });
  }

  void _scroll(double direction) {
    final newOffset = _scrollController.offset + (direction * 200);
    _scrollController.animateTo(
      newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget itemCard(item, double widthItem) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: OpenContainer(
        closedColor: Colors.transparent,
        closedElevation: 0,
        transitionDuration: Duration(milliseconds: 400),
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => SparePartDetails(item: item),
        closedBuilder: (context, openContainer) => GestureDetector(
          onTap: openContainer,
          child: Container(
            width: widthItem,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item['type'],
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                var item = widget.items[index];
                return itemCard(item, widget.widthItem);
              },
            );
          },
        ),
        if (_isScrollable) ...[
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _showLeftButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ScrollButton(
                  icon: Icons.arrow_back_ios,
                  onPressed: () => _scroll(-1),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _showRightButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.centerRight,
                child: ScrollButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: () => _scroll(1),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}

class ScrollButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ScrollButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        icon: Icon(icon, color: Colors.orange),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shadowColor: Colors.black26,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
