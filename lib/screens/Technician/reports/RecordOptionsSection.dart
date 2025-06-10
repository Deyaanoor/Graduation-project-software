import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
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
  String _searchType = 'owner';
  String _searchQuery = '';

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
      ref.read(selectedIndexProvider.notifier).state = 3;
    });
  }

  Widget _buildWebMasterpiece(Map<String, dynamic> lang,
      List<Map<String, dynamic>> _searchTypes, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final Color mainColor = theme.colorScheme.secondary;
    final Color bgColor = theme.scaffoldBackgroundColor;
    final Color cardColor = theme.cardColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              mainColor.withOpacity(0.18),
              mainColor.withOpacity(0.08),
              bgColor
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _TopSearchSection(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    color: mainColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    searchType: _searchType,
                    searchTypes: _searchTypes,
                    onSearchTypeChanged: (value) =>
                        setState(() => _searchType = value!),
                    onBackPressed: () => _toggleSearch(false),
                  )),
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _SearchResultsPanel(
                results: filteredReports,
                onItemSelected: _handleResultSelection,
                color: mainColor,
                cardColor: cardColor,
                textColor: textColor,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          buildAddReportButton(lang, mainColor, textColor, theme),
    );
  }

  Widget _buildMobileMasterpiece(Map<String, dynamic> lang,
      List<Map<String, dynamic>> _searchTypes, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final Color mainColor = theme.colorScheme.secondary;
    final Color bgColor = theme.scaffoldBackgroundColor;
    final Color cardColor = theme.cardColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.5, 0.9],
            colors: [
              mainColor.withOpacity(0.18),
              mainColor.withOpacity(0.08),
              bgColor
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
              child: _MobileSearchSection(
                controller: _searchController,
                results: filteredReports,
                onItemSelected: _handleResultSelection,
                onClose: () => _toggleSearch(false),
                color: mainColor,
                cardColor: cardColor,
                textColor: textColor,
                searchType: _searchType,
                onSearchTypeChanged: (value) =>
                    setState(() => _searchType = value!),
                searchTypes: _searchTypes,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          buildAddReportButton(lang, mainColor, textColor, theme),
    );
  }

  Widget buildAddReportButton(
    Map<String, dynamic> lang,
    Color mainColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: FloatingActionButton.extended(
        onPressed: () {
          ref.read(selectedReportProvider.notifier).state = null;
          ref.read(selectedIndexProvider.notifier).state = 3;
        },
        label: Text(
          lang['addReport'] ?? 'إضافة تقرير',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        icon: Icon(Icons.add, color: textColor),
        backgroundColor: mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> _searchTypes = [
      {'value': 'owner', 'label': lang['searchByOwner'] ?? 'بحث بالمالك'},
      {'value': 'plate', 'label': lang['searchByPlate'] ?? 'بحث برقم اللوحة'},
    ];

    return ResponsiveHelper.isDesktop(context)
        ? _buildWebMasterpiece(lang, _searchTypes, theme)
        : _buildMobileMasterpiece(lang, _searchTypes, theme);
  }
}

// ---------------------------- Web Components ----------------------------
class _TopSearchSection extends ConsumerWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final String searchType;
  final List<Map<String, dynamic>> searchTypes;
  final Function(String?) onSearchTypeChanged;
  final VoidCallback onBackPressed;

  const _TopSearchSection({
    required this.controller,
    required this.onChanged,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.searchType,
    required this.searchTypes,
    required this.onSearchTypeChanged,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Container(
          width: 600,
          decoration: BoxDecoration(
            color: cardColor,
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
                  style: TextStyle(color: textColor, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: lang['search'] ?? 'بحث...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
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

class _MobileSearchSection extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final Function(Map<String, dynamic>) onItemSelected;
  final VoidCallback onClose;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final String searchType;
  final Function(String?) onSearchTypeChanged;
  final List<Map<String, dynamic>> searchTypes;

  const _MobileSearchSection({
    required this.controller,
    required this.results,
    required this.onItemSelected,
    required this.onClose,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.searchType,
    required this.onSearchTypeChanged,
    required this.searchTypes,
  });

  @override
  ConsumerState<_MobileSearchSection> createState() =>
      _MobileSearchSectionState();
}

class _MobileSearchSectionState extends ConsumerState<_MobileSearchSection> {
  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final cardColor = widget.cardColor;
    final textColor = widget.textColor;
    final controller = widget.controller;
    final results = widget.results;
    final onItemSelected = widget.onItemSelected;
    final onClose = widget.onClose;
    final searchType = widget.searchType;
    final onSearchTypeChanged = widget.onSearchTypeChanged;
    final searchTypes = widget.searchTypes;
    final lang = ref.watch(languageProvider);

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
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
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: color.withOpacity(0.1),
                              hintText: lang['search'] ?? 'بحث...',
                              hintStyle:
                                  TextStyle(color: textColor.withOpacity(0.6)),
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
                      dropdownColor: cardColor,
                    ),
                  ],
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.only(top: 15),
                itemCount: results.length,
                shrinkWrap: true, // مهم جدًا
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.description, color: color),
                  title: Text(
                    '${results[index]['owner']} - ${results[index]['plateNumber']}',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  trailing: Icon(Icons.chevron_left, color: color),
                  onTap: () => onItemSelected(results[index]),
                ),
              )
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
          backgroundColor: Theme.of(context).cardColor,
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
  final Color cardColor;
  final Color textColor;

  const _SearchResultsPanel({
    required this.results,
    required this.onItemSelected,
    required this.color,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (_, __) => Divider(color: color.withOpacity(0.2)),
            itemBuilder: (context, index) => ListTile(
              leading: Icon(Icons.description, color: color),
              title: Text(
                '${results[index]['owner']} - ${results[index]['plateNumber']}',
                style: TextStyle(color: textColor, fontSize: 16),
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
