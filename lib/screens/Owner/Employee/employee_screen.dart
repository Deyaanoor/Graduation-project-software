import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/employeeProvider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/overviewProvider.dart';
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
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final employeesAsync = ref.watch(employeesProvider(userId));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: lang['searchByName'] ?? 'بحث بالاسم',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
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

                  // final isMobile = ResponsiveHelper.isMobile(context);

                  // return isMobile
                  //     ? DataTable(
                  //         sortAscending: _sortAscending,
                  //         sortColumnIndex: _sortColumnIndex,
                  //         columns: [
                  //           DataColumn(
                  //             label: Text(lang['name'] ?? 'الاسم'),
                  //             onSort: (i, _) => _sortData(filtered, i, 'name'),
                  //           ),
                  //           DataColumn(
                  //             label: Text(lang['phone'] ?? 'رقم الهاتف'),
                  //             onSort: (i, _) => _sortData(filtered, i, 'phone'),
                  //           ),
                  //           DataColumn(
                  //               label: Text(lang['actions'] ?? 'إجراءات')),
                  //         ],
                  //         rows: List.generate(filtered.length, (index) {
                  //           final employee = filtered[index];
                  //           return DataRow(cells: [
                  //             DataCell(Text(employee['name'] ?? '')),
                  //             DataCell(Text(employee['phoneNumber'] ?? '')),
                  //             DataCell(Row(
                  //               children: [
                  //                 IconButton(
                  //                   icon: const Icon(Icons.edit,
                  //                       color: Colors.blue),
                  //                   onPressed: () {
                  //                     Navigator.push(
                  //                       context,
                  //                       MaterialPageRoute(
                  //                         builder: (context) =>
                  //                             EmployeeDetailScreen(
                  //                                 employee: employee),
                  //                       ),
                  //                     );
                  //                   },
                  //                 ),
                  //                 IconButton(
                  //                   icon: const Icon(Icons.delete,
                  //                       color: Colors.red),
                  //                   onPressed: () async {
                  //                     final confirmed = await showDialog<bool>(
                  //                       context: context,
                  //                       builder: (ctx) => AlertDialog(
                  //                         title: Text(lang['confirmDelete'] ??
                  //                             'تأكيد الحذف'),
                  //                         content: Text(
                  //                             '${lang['deleteEmployeeMsg'] ?? 'هل أنت متأكد من حذف هذا الموظف؟'}\n${employee['name']}؟'),
                  //                         actions: [
                  //                           TextButton(
                  //                             child: Text(
                  //                                 lang['cancel'] ?? 'إلغاء'),
                  //                             onPressed: () =>
                  //                                 Navigator.pop(ctx, false),
                  //                           ),
                  //                           ElevatedButton(
                  //                             child:
                  //                                 Text(lang['delete'] ?? 'حذف'),
                  //                             onPressed: () =>
                  //                                 Navigator.pop(ctx, true),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     );

                  //                     if (confirmed == true) {
                  //                       try {
                  //                         final deleteEmployee =
                  //                             ref.read(deleteEmployeeProvider);
                  //                         await deleteEmployee(
                  //                             employee['email'], userId);
                  //                         ref.invalidate(
                  //                             employeesProvider(userId));
                  //                         ref.invalidate(
                  //                             employeeCountProvider(userId));
                  //                         ref.invalidate(
                  //                             employeeSalaryProvider(userId));
                  //                       } catch (e) {
                  //                         ScaffoldMessenger.of(context)
                  //                             .showSnackBar(
                  //                           SnackBar(
                  //                               content: Text(
                  //                                   '${lang['deleteFailed'] ?? 'فشل في الحذف'}: $e')),
                  //                         );
                  //                       }
                  //                     }
                  //                   },
                  //                 ),
                  //               ],
                  //             )),
                  //           ]);
                  //         }),
                  //       )

                  final isMobile = ResponsiveHelper.isMobile(context);

                  return isMobile
                      ? ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final employee = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // الاسم الرئيسي
                                      Text(
                                        employee['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // رقم الهاتف
                                      Text(
                                        '${lang['phoneNumber'] ?? 'Phone Number'}: ${employee['phoneNumber'] ?? ''}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      // البريد الإلكتروني
                                      Text(
                                        '${lang['email'] ?? 'Email'}: ${employee['email'] ?? ''}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      // أزرار التحكم
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmployeeDetailScreen(
                                                          employee: employee),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(
                                                      lang['confirmDelete'] ??
                                                          'تأكيد الحذف'),
                                                  content: Text(
                                                      '${lang['deleteEmployeeMsg'] ?? 'هل أنت متأكد من حذف هذا الموظف؟'}\n${employee['name']}؟'),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                          lang['cancel'] ??
                                                              'إلغاء'),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, false),
                                                    ),
                                                    ElevatedButton(
                                                      child: Text(
                                                          lang['delete'] ??
                                                              'حذف'),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, true),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                try {
                                                  final deleteEmployee = ref.read(
                                                      deleteEmployeeProvider);
                                                  await deleteEmployee(
                                                      employee['email'],
                                                      userId);
                                                  ref.invalidate(
                                                      employeesProvider(
                                                          userId));
                                                  ref.invalidate(
                                                      employeeCountProvider(
                                                          userId));
                                                  ref.invalidate(
                                                      employeeSalaryProvider(
                                                          userId));
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            '${lang['deleteFailed'] ?? 'فشل في الحذف'}: $e')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortAscending: _sortAscending,
                            sortColumnIndex: _sortColumnIndex,
                            columns: [
                              DataColumn(label: Text(lang['number'] ?? 'رقم')),
                              DataColumn(
                                label: Text(lang['name'] ?? 'الاسم'),
                                onSort: (i, _) =>
                                    _sortData(filtered, i, 'name'),
                              ),
                              DataColumn(
                                label: Text(lang['email'] ?? 'الإيميل'),
                                onSort: (i, _) =>
                                    _sortData(filtered, i, 'email'),
                              ),
                              DataColumn(
                                label:
                                    Text(lang['phoneNumber'] ?? 'رقم الهاتف'),
                                onSort: (i, _) =>
                                    _sortData(filtered, i, 'phone'),
                              ),
                              DataColumn(
                                label: Text(lang['salary'] ?? 'الراتب'),
                                numeric: true,
                                onSort: (i, _) =>
                                    _sortData(filtered, i, 'salary'),
                              ),
                              DataColumn(
                                  label: Text(lang['actions'] ?? 'إجراءات')),
                            ],
                            rows: List.generate(filtered.length, (index) {
                              final employee = filtered[index];
                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(employee['name'] ?? '')),
                                DataCell(Text(employee['email'] ?? '')),
                                DataCell(Text(employee['phoneNumber'] ?? '')),
                                DataCell(Text(employee['salary'].toString())),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: EmployeeDetailScreen(
                                                employee: employee),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(lang['confirmDelete'] ??
                                                'تأكيد الحذف'),
                                            content: Text(
                                                '${lang['deleteEmployeeMsg'] ?? 'هل أنت متأكد من حذف هذا الموظف؟'}\n${employee['name']}؟'),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                    lang['cancel'] ?? 'إلغاء'),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                              ),
                                              ElevatedButton(
                                                child: Text(
                                                    lang['delete'] ?? 'حذف'),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          try {
                                            final deleteEmployee = ref
                                                .read(deleteEmployeeProvider);
                                            await deleteEmployee(
                                                employee['email'], userId);
                                            ref.invalidate(
                                                employeesProvider(userId));
                                            ref.invalidate(
                                                employeeCountProvider(userId));
                                            ref.invalidate(
                                                employeeSalaryProvider(userId));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      '${lang['deleteFailed'] ?? 'فشل في الحذف'}: $e')),
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
                error: (err, stack) =>
                    Center(child: Text('${lang['error'] ?? 'حدث خطأ'}: $err')),
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
        tooltip: lang['addEmployee'] ?? 'إضافة موظف',
      ),
    );
  }
}
