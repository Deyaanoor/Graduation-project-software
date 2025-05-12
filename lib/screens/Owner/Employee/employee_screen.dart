import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/employeeProvider.dart';
import 'package:flutter_provider/screens/Owner/Employee/add_employee_screen.dart';
import 'package:flutter_provider/screens/Owner/Employee/employee_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isInitialized = false;

  String get userId {
    final userIdValue = ref.watch(userIdProvider).value;
    return userIdValue ?? '';
  }

  void _sortData(
      List<Map<String, dynamic>> employees, int columnIndex, String key) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = !_sortAscending;
      employees.sort((a, b) {
        final aValue = a[key];
        final bValue = b[key];
        if (aValue is num && bValue is num) {
          return _sortAscending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else {
          return _sortAscending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final uid = ref.read(userIdProvider).value;
    if (uid != null && uid.isNotEmpty) {
      ref.invalidate(employeesProvider(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الموظفين'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'بحث بالاسم',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: employeesAsync.when(
                data: (employees) {
                  final filtered = employees.where((e) {
                    final name = (e['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  final isMobile = ResponsiveHelper.isMobile(context);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortAscending: _sortAscending,
                      sortColumnIndex: _sortColumnIndex,
                      columns: [
                        if (!isMobile) const DataColumn(label: Text('رقم')),
                        DataColumn(
                          label: const Text('الاسم'),
                          onSort: (i, _) => _sortData(filtered, i, 'name'),
                        ),
                        if (!isMobile)
                          DataColumn(
                            label: const Text('الإيميل'),
                            onSort: (i, _) => _sortData(filtered, i, 'email'),
                          ),
                        DataColumn(
                          label: const Text('رقم الهاتف'),
                          onSort: (i, _) => _sortData(filtered, i, 'phone'),
                        ),
                        if (!isMobile)
                          DataColumn(
                            label: const Text('الراتب'),
                            numeric: true,
                            onSort: (i, _) => _sortData(filtered, i, 'salary'),
                          ),
                        const DataColumn(label: Text('إجراءات')),
                      ],
                      rows: List.generate(filtered.length, (index) {
                        final employee = filtered[index];
                        return DataRow(cells: [
                          if (!isMobile) DataCell(Text('${index + 1}')),
                          DataCell(Text(employee['name'] ?? '')),
                          if (!isMobile)
                            DataCell(Text(employee['email'] ?? '')),
                          DataCell(Text(employee['phoneNumber'] ?? '')),
                          if (!isMobile)
                            DataCell(Text(employee['salary'].toString())),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  if (isMobile) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeDetailScreen(
                                                employee: employee),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: EmployeeDetailScreen(
                                            employee: employee),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: Text(
                                          'هل أنت متأكد من حذف ${employee['name']}؟'),
                                      actions: [
                                        TextButton(
                                          child: const Text('إلغاء'),
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                        ),
                                        ElevatedButton(
                                          child: const Text('حذف'),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    try {
                                      final deleteEmployee =
                                          ref.read(deleteEmployeeProvider);
                                      await deleteEmployee(employee['email'],
                                          userId); // Pass userId here
                                      ref.invalidate(employeesProvider(userId));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('فشل في الحذف: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          )),
                        ]);
                      }),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (ResponsiveHelper.isDesktop(context)) {
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
                    child: AddEmployeeScreen(),
                  ),
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEmployeeScreen(),
              ),
            );
          }
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
