import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Technician/reports/report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordOptionsSection extends ConsumerStatefulWidget {
  const RecordOptionsSection({super.key});

  @override
  ConsumerState<RecordOptionsSection> createState() =>
      _RecordOptionsSectionState();
}

class _RecordOptionsSectionState extends ConsumerState<RecordOptionsSection> {
  bool _showSearch = false;

  final TextEditingController _searchController = TextEditingController();
  final Color _primaryColor = Colors.orange;
  String _searchType = 'owner';
  String _searchQuery = '';
  final List<Map<String, dynamic>> _searchTypes = [
    {'value': 'owner', 'label': 'بحث بالمالك'},
    {'value': 'plate', 'label': 'بحث برقم اللوحة'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(userIdProvider).value;

      if (userId != null) {
        ref.read(reportsProvider.notifier).fetchReports(userId: userId);
      }
    });
    _searchController.addListener(() => _handleSearch(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get reports {
    return ref.watch(reportsProvider).maybeWhen(
          data: (data) => data,
          orElse: () => [],
        );
  }

  List<Map<String, dynamic>> get filteredReports {
    List<Map<String, dynamic>> filtered = _searchQuery.isEmpty
        ? reports
        : reports.where((report) {
            final value = _searchType == 'owner'
                ? report['owner']?.toString().toLowerCase() ?? ''
                : report['plateNumber']?.toString().toLowerCase() ?? '';
            return value.contains(_searchQuery.toLowerCase());
          }).toList();

    // تصفية التكرار حسب owner و plateNumber
    final seen = <String>{};
    final uniqueReports = <Map<String, dynamic>>[];

    for (var report in filtered) {
      final key = '${report['owner']}_${report['plateNumber']}';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueReports.add(report);
      }
    }

    return uniqueReports;
  }

  void _toggleSearch(bool show) => setState(() => _showSearch = show);

  void _handleSearch(String query) => setState(() => _searchQuery = query);

  void _handleResultSelection(Map<String, dynamic> report) {
    ref.read(selectedReportProvider.notifier).state = report;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedIndexProvider.notifier).state = 5;
    });
  }

  Widget _buildWebMasterpiece() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            _primaryColor.withOpacity(0.2),
            _primaryColor.withOpacity(0.1),
            Colors.white
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showSearch
                  ? _TopSearchSection(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      color: _primaryColor,
                      searchType: _searchType,
                      searchTypes: _searchTypes,
                      onSearchTypeChanged: (value) =>
                          setState(() => _searchType = value!),
                      onBackPressed: () => _toggleSearch(false),
                    )
                  : _WebMainActions(
                      onSearchPressed: () => _toggleSearch(true),
                      color: _primaryColor,
                    ),
            ),
          ),
          if (_showSearch)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _SearchResultsPanel(
                results: filteredReports,
                onItemSelected: _handleResultSelection,
                color: _primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileMasterpiece() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.5, 0.9],
            colors: [
              Colors.orange.shade200,
              Colors.orange.shade50,
              Colors.white
            ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutBack,
              top: _showSearch ? 80 : MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: _MobileMainActions(
                showSearch: _showSearch,
                onSearchPressed: () => _toggleSearch(true),
                color: _primaryColor,
              ),
            ),
            if (_showSearch)
              WillPopScope(
                onWillPop: () async {
                  _toggleSearch(false);
                  return false;
                },
                child: _MobileSearchSection(
                  controller: _searchController,
                  results: filteredReports,
                  onItemSelected: _handleResultSelection,
                  onClose: () => _toggleSearch(false),
                  color: _primaryColor,
                  searchType: _searchType,
                  onSearchTypeChanged: (value) =>
                      setState(() => _searchType = value!),
                  searchTypes: _searchTypes,
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? _buildWebMasterpiece()
        : _buildMobileMasterpiece();
  }
}

// ---------------------------- Web Components ----------------------------
class _TopSearchSection extends ConsumerWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Color color;
  final String searchType;
  final List<Map<String, dynamic>> searchTypes;
  final Function(String?) onSearchTypeChanged;

  final VoidCallback onBackPressed;

  const _TopSearchSection({
    required this.controller,
    required this.onChanged,
    required this.color,
    required this.searchType,
    required this.searchTypes,
    required this.onSearchTypeChanged,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Container(
          width: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: color),
                onPressed: onBackPressed,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: searchType,
                    items: searchTypes.map<DropdownMenuItem<String>>((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'],
                        child: Text(
                          type['label'],
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onSearchTypeChanged,
                    icon: Icon(Icons.arrow_drop_down, color: color),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: TextStyle(color: color, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالسجل أو المستخدم...',
                    prefixIcon: Icon(Icons.search, color: color),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close, color: color),
                      onPressed: () => controller.clear(),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebMainActions extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final Color color;

  const _WebMainActions({
    required this.onSearchPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'إدارة السجلات',
            style: TextStyle(
              fontSize: 36,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  return _ActionButton(
                    icon: Icons.person_add,
                    label: 'إنشاء جديد',
                    onPressed: () {
                      ref.read(selectedReportProvider.notifier).state = null;
                      ref.read(selectedIndexProvider.notifier).state = 5;
                    },
                    color: color,
                    isWeb: true,
                  );
                },
              ),
              const SizedBox(width: 40),
              _ActionButton(
                icon: Icons.folder_open,
                label: 'فتح سجل',
                onPressed: onSearchPressed,
                color: color,
                isWeb: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------- Mobile Components ----------------------------
class _MobileMainActions extends StatelessWidget {
  final bool showSearch;
  final VoidCallback onSearchPressed;
  final Color color;

  const _MobileMainActions({
    required this.showSearch,
    required this.onSearchPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: showSearch ? 0 : 120,
          child: OverflowBox(
            maxHeight: 120,
            child: Consumer(
              builder: (context, ref, _) {
                return _ActionButton(
                  icon: Icons.person_add,
                  label: 'جديد',
                  onPressed: () {
                    ref.read(selectedReportProvider.notifier).state = null;
                    ref.read(selectedIndexProvider.notifier).state = 5;
                  },
                  color: color,
                  isWeb: false,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 30),
        AnimatedOpacity(
          opacity: showSearch ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: _ActionButton(
            icon: Icons.search,
            label: 'بحث',
            onPressed: onSearchPressed,
            color: color,
            isWeb: false,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'اختر أحد الخيارات',
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MobileSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final Function(Map<String, dynamic>) onItemSelected;
  final VoidCallback onClose;
  final Color color;
  final String searchType;
  final Function(String?) onSearchTypeChanged;
  final List<Map<String, dynamic>> searchTypes;

  const _MobileSearchSection({
    required this.controller,
    required this.results,
    required this.onItemSelected,
    required this.onClose,
    required this.color,
    required this.searchType,
    required this.onSearchTypeChanged,
    required this.searchTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: color),
                          onPressed: onClose,
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: TextStyle(color: color),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: color.withOpacity(0.1),
                              hintText: 'اكتب للبحث...',
                              prefixIcon: Icon(Icons.search, color: color),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: searchType,
                      items: searchTypes.map<DropdownMenuItem<String>>((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Text(
                            type['label'],
                            style: TextStyle(color: color),
                          ),
                        );
                      }).toList(),
                      onChanged: onSearchTypeChanged,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: color.withOpacity(0.1),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: color),
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 15),
                  itemCount: results.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Icon(Icons.description, color: color),
                    title: Text(
                      '${results[index]['owner']} - ${results[index]['plateNumber']}',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                    ),
                    trailing: Icon(Icons.chevron_left, color: color),
                    onTap: () => onItemSelected(results[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Shared Components ----------------------------
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isWeb;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isWeb ? 200 : 140,
      height: isWeb ? 200 : 140,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: color, width: 2),
          ),
          padding: const EdgeInsets.all(20),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isWeb ? 50 : 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isWeb ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final Function(Map<String, dynamic>) onItemSelected;
  final Color color;

  const _SearchResultsPanel({
    required this.results,
    required this.onItemSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SizedBox(
          height: 400,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(15),
            itemCount: results.length,
            separatorBuilder: (_, __) => Divider(color: color.withOpacity(0.2)),
            itemBuilder: (context, index) => ListTile(
              leading: Icon(Icons.description, color: color),
              title: Text(
                '${results[index]['owner']} - ${results[index]['plateNumber']}',
                style: TextStyle(color: Colors.grey[800], fontSize: 16),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: color, size: 18),
              onTap: () => onItemSelected(results[index]),
            ),
          ),
        ),
      ),
    );
  }
}
