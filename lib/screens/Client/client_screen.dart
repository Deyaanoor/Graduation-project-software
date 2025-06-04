import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
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
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang['clients'] ?? 'Clients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: lang['searchByName'] ?? 'Search by name',
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
              child: clientsAsync.when(
                data: (clients) {
                  final filtered = clients.where((e) {
                    final name = (e['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  final isMobile = ResponsiveHelper.isMobile(context);

                  return isMobile
                      ? ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final client = filtered[index];
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
                                        client['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // رقم الهاتف
                                      Text(
                                        '${lang['phoneNumber'] ?? 'Phone Number'}: ${client['phoneNumber'] ?? ''}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      // البريد الإلكتروني
                                      Text(
                                        '${lang['email'] ?? 'Email'}: ${client['email'] ?? ''}',
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
                                                      ClientDetailScreen(
                                                          client: client),
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
                                                      lang['deleteClient'] ??
                                                          'Delete client'),
                                                  content: Text(
                                                    (lang['deleteClientMsg'] ??
                                                            'Are you sure you want to delete {name}?')
                                                        .replaceAll(
                                                            '{name}',
                                                            client['name'] ??
                                                                ''),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                          lang['exit'] ??
                                                              'Exit'),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, false),
                                                    ),
                                                    ElevatedButton(
                                                      child: Text(
                                                          lang['delete'] ??
                                                              'Delete'),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, true),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                try {
                                                  final deleteClient = ref.read(
                                                      deleteClientProvider);
                                                  await deleteClient(
                                                      client['email'], userId);
                                                  ref.invalidate(
                                                      clientsProvider(userId));
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(lang[
                                                              'error'] ??
                                                          'An error occurred while deleting the client. Please try again.'),
                                                    ),
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
                              if (!isMobile)
                                DataColumn(
                                    label: Text(lang['number'] ?? 'No.')),
                              DataColumn(
                                label: Text(lang['name'] ?? 'Name'),
                                onSort: (i, _) =>
                                    _sortData(filtered, i, 'name'),
                              ),
                              if (!isMobile)
                                DataColumn(
                                  label: Text(lang['email'] ?? 'Email'),
                                  onSort: (i, _) =>
                                      _sortData(filtered, i, 'email'),
                                ),
                              DataColumn(
                                label: Text(lang['phone'] ?? 'Phone Number'),
                                onSort: (i, _) =>
                                    _sortData(filtered, i, 'phone'),
                              ),
                              DataColumn(
                                  label: Text(lang['actions'] ?? 'Actions')),
                            ],
                            rows: List.generate(filtered.length, (index) {
                              final client = filtered[index];
                              return DataRow(cells: [
                                if (!isMobile) DataCell(Text('${index + 1}')),
                                DataCell(Text(client['name'] ?? '')),
                                if (!isMobile)
                                  DataCell(Text(client['email'] ?? '')),
                                DataCell(Text(client['phoneNumber'] ?? '')),
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
                                            child: ClientDetailScreen(
                                                client: client),
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
                                            title: Text(lang['deleteClient'] ??
                                                'Delete client'),
                                            content: Text(
                                              (lang['deleteClientMsg'] ??
                                                      'Are you sure you want to delete {name}?')
                                                  .replaceAll('{name}',
                                                      client['name'] ?? ''),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                    lang['exit'] ?? 'Exit'),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                              ),
                                              ElevatedButton(
                                                child: Text(
                                                    lang['delete'] ?? 'Delete'),
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
                                            await deleteClient(
                                                client['email'], userId);
                                            ref.invalidate(
                                                clientsProvider(userId));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(lang['error'] ??
                                                    'An error occurred while deleting the client. Please try again.'),
                                              ),
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
                    Center(child: Text('${lang['error'] ?? 'error'}: $err')),
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
        tooltip: lang['addClient'] ?? 'Add Client',
      ),
    );
  }
}
