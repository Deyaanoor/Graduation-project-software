import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/screens/Client/GarageRequestsPage.dart';
import 'package:flutter_provider/screens/Client/ReportPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LegendaryTabBar extends ConsumerStatefulWidget {
  const LegendaryTabBar({super.key});

  @override
  ConsumerState<LegendaryTabBar> createState() => _LegendaryTabBarState();
}

class _LegendaryTabBarState extends ConsumerState<LegendaryTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.withOpacity(0.3),
                  ),
                  labelColor: const Color.fromARGB(255, 247, 185, 52),
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  tabs: const [
                    Tab(icon: Icon(Icons.history), text: 'Service History'),
                    Tab(icon: Icon(Icons.assignment), text: 'Requests'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ClientReportsPage(),
                  GarageRequestsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
