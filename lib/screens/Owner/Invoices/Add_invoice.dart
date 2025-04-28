import 'package:flutter/material.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  AddInvoiceScreen({required this.onAdd});

  @override
  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  String _status = 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة فاتورة جديدة'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _customerController,
                decoration: InputDecoration(labelText: 'العميل'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم العميل';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'التاريخ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال التاريخ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'المبلغ'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                value: _status,
                items: ['Pending', 'Paid'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value.toString();
                  });
                },
                decoration: InputDecoration(labelText: 'الحالة'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newInvoice = {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'customer': _customerController.text,
                      'date': _dateController.text,
                      'amount': double.parse(_amountController.text),
                      'status': _status,
                    };
                    widget.onAdd(newInvoice);
                    Navigator.pop(context);
                  }
                },
                child: Text('إضافة فاتورة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
