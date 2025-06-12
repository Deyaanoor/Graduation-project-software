import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/screens/Admin/Garage/GarageDetailsPage.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/EditGaragePage.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/GarageForm.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/AddCart.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/GarageCard.dart';
import 'package:flutter_provider/screens/Admin/Garage/AddGaragePage.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_provider/widgets/CustomPainter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';

// String extension to add capitalize method
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class GaragePage extends ConsumerWidget {
  GaragePage({super.key});

  final searchQueryProvider = StateProvider<String>((ref) => '');

  void _openAddForm(
      BuildContext context, WidgetRef ref, Map<String, String> lang) {
    if (ResponsiveHelper.isMobile(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddGaragePage()),
      );
    } else {
      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
      final List<TextEditingController> _controllers = [
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ];

      Future<void> _submitForm() async {
        if (_formKey.currentState!.validate()) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final addGarage = ref.read(addGarageProvider);
            await addGarage(
              name: _controllers[0].text,
              location: _controllers[1].text,
              ownerName: _controllers[2].text,
              ownerEmail: _controllers[3].text,
              cost: _controllers[4].text,
            );
            final refreshGarages = ref.read(refreshGaragesProvider);
            refreshGarages(ref);

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(); // pop loading dialog

            CustomDialogPage.show(
              // ignore: use_build_context_synchronously
              context: context,
              type: MessageType.success,
              title: lang['success'] ?? 'Success',
              content: lang['garageAdded'] ?? 'Garage added successfully',
            );
          } catch (e) {
            CustomDialogPage.show(
              context: context,
              type: MessageType.error,
              title: lang['error'] ?? 'Error',
              content: '${lang['errorOccurred'] ?? 'An error occurred'}: $e',
            );
          }
        }
      }

      Widget _buildTextFormField({
        required BuildContext context,
        required TextEditingController controller,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
        required String label,
        String? Function(String?)? validator,
      }) {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(icon),
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          validator: validator,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garagesAsync = ref.watch(garagesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final lang = ref.watch(languageProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final waveColor = Colors.orange;

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: WaveBackground(
              color1: waveColor,
              color2: backgroundColor,
            ),
            size: Size.infinite,
          ),
          Column(
            children: [
              _buildSearchBar(ref, lang),
              Expanded(
                child: garagesAsync.when(
                  data: (garages) {
                    final filteredGarages = garages.where((garage) {
                      final name =
                          garage['name']?.toString().toLowerCase() ?? '';
                      final query = searchQuery.toLowerCase();
                      return name.contains(query);
                    }).toList();

                    if (filteredGarages.isEmpty) {
                      return Center(
                          child:
                              Text(lang['noResults'] ?? 'No results found.'));
                    }

                    return _GarageTable(
                        garages: filteredGarages, ref: ref, lang: lang);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('${lang['error'] ?? 'Error'}: $e')),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref, Map<String, String> lang) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          hintText: lang['searchGarages'] ?? 'Search garages...',
          hintStyle: const TextStyle(color: Color.fromARGB(255, 235, 186, 112)),
          prefixIcon: const Icon(Icons.search, color: Colors.orange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        style: const TextStyle(color: Colors.orange),
      ),
    );
  }
}

class _GarageTable extends StatelessWidget {
  final List<Map<String, dynamic>> garages;
  final WidgetRef ref;
  final Map<String, String> lang;

  const _GarageTable(
      {required this.garages, required this.ref, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDarkMode ? Colors.orange.shade700 : Colors.orange.shade500;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900];
    final rowColor = isDarkMode ? Colors.grey[850] : Colors.orange[50];
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: constraints.maxWidth,
              color: backgroundColor,
              child: Scrollbar(
                child: DataTable2(
                  showCheckboxColumn: false,
                  columnSpacing: 20,
                  horizontalMargin: 20,
                  minWidth: constraints.maxWidth,
                  dataRowHeight: 60,
                  headingRowHeight: 70,
                  border: TableBorder(
                    verticalInside: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  columns: [
                    DataColumn2(
                      label: _SimpleHeader(
                          lang['garageName'] ?? 'Garage Name', headerColor),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _SimpleHeader(
                          lang['ownerName'] ?? 'Owner Name', headerColor),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _SimpleHeader(
                          lang['status'] ?? 'Status', headerColor),
                      size: ColumnSize.M,
                    ),
                  ],
                  rows: List<DataRow2>.generate(
                    garages.length,
                    (index) => DataRow2(
                      color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.orange.withOpacity(0.3);
                          }
                          return index.isEven
                              ? rowColor!.withOpacity(0.8)
                              : Colors.transparent;
                        },
                      ),
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          _onRowTap(context, garages[index]);
                        }
                      },
                      cells: [
                        DataCell(
                          Text(
                            garages[index]['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            garages[index]['ownerName'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: ['Active', 'Inactive'].contains(
                                    garages[index]['status']
                                        ?.toString()
                                        .trim()
                                        .toLowerCase()
                                        .capitalize())
                                ? garages[index]['status']
                                    .toString()
                                    .trim()
                                    .toLowerCase()
                                    .capitalize()
                                : 'Active',
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color, // لون النص حسب الثيم
                            ),
                            dropdownColor: Theme.of(context)
                                .cardColor, // لون خلفية القائمة حسب الثيم
                            onChanged: (value) async {
                              if (value != null) {
                                try {
                                  await updateGarageStatus(
                                      garages[index]['_id'], value);
                                  garages[index]['status'] = value;
                                  final refreshGarages =
                                      ref.read(refreshGaragesProvider);
                                  refreshGarages(ref);
                                } catch (e) {
                                  CustomDialogPage.show(
                                    context: context,
                                    type: MessageType.error,
                                    title: lang['error'] ?? 'Error',
                                    content:
                                        '${lang['errorOccurred'] ?? 'An error occurred'}: $e',
                                  );
                                }
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'Active',
                                child: Text(
                                  lang['active'] ?? 'Active',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary, // برتقالي للـ Active
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Inactive',
                                child: Text(
                                  lang['inactive'] ?? 'Inactive',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.red[300]
                                        : Colors
                                            .red[700], // أحمر متناسب مع الثيم
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editGarage(BuildContext context, Map<String, dynamic> garage) {
    if (ResponsiveHelper.isMobile(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditGaragePage(garageId: garage['_id']),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SizedBox(
              width: 600,
              height: 500,
              child: EditGaragePage(garageId: garage['_id']),
            ),
          );
        },
      );
    }
  }

  void _deleteGarage(BuildContext context, Map<String, dynamic> garage) {
    // Implement delete logic
  }

  void _onRowTap(BuildContext context, Map<String, dynamic> garage) {
    if (ResponsiveHelper.isMobile(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GarageDetailsPage(garageId: garage['_id']),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SizedBox(
              width: 600,
              height: 600,
              child: GarageDetailsPage(garageId: garage['_id']),
            ),
          );
        },
      );
    }
  }
}

class _SimpleHeader extends StatelessWidget {
  final String text;
  final Color headerColor;

  const _SimpleHeader(this.text, this.headerColor);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: headerColor,
      ),
    );
  }
}
