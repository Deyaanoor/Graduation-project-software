import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';
import 'package:flutter_provider/screens/Client/add_client_screen.dart';
import 'package:flutter_provider/screens/Client/client_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isInitialized = false;

  String get userId {
    final userIdValue = ref.watch(userIdProvider).value;
    return userIdValue ?? '';
  }

  void _sortData(
      List<Map<String, dynamic>> clients, int columnIndex, String key) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = !_sortAscending;
      clients.sort((a, b) {
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
      ref.invalidate(clientsProvider(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
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
              child: clientsAsync.when(
                data: (clients) {
                  final filtered = clients.where((e) {
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
                        const DataColumn(label: Text('إجراءات')),
                      ],
                      rows: List.generate(filtered.length, (index) {
                        final client = filtered[index];
                        return DataRow(cells: [
                          if (!isMobile) DataCell(Text('${index + 1}')),
                          DataCell(Text(client['name'] ?? '')),
                          if (!isMobile) DataCell(Text(client['email'] ?? '')),
                          DataCell(Text(client['phoneNumber'] ?? '')),
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
                                            ClientDetailScreen(client: client),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child:
                                            ClientDetailScreen(client: client),
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
                                      title: const Text('delete client'),
                                      content: Text(
                                          'Are you sure you want to delete ${client['name']}?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('exit'),
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                        ),
                                        ElevatedButton(
                                          child: const Text('Delete'),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    try {
                                      final deleteClient =
                                          ref.read(deleteClientProvider);
                                      await deleteClient(client['email'],
                                          userId); // Pass userId here
                                      ref.invalidate(clientsProvider(userId));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'An error occurred while deleting the client. Please try again.')),
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
                error: (err, stack) => Center(child: Text('error: $err')),
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
                    child: AddClientScreen(),
                  ),
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddClientScreen(),
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
