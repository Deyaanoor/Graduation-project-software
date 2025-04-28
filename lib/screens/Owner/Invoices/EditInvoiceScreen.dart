import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> invoice;
  final Function(Map<String, dynamic>) onSave;

  EditInvoiceScreen({required this.invoice, required this.onSave});

  @override
  _EditInvoiceScreenState createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNumberController;
  late TextEditingController _customerController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _customerEmailController;
  late TextEditingController _carModelController;
  late TextEditingController _carPlateController;
  late TextEditingController _carColorController;
  late TextEditingController _carMileageController;
  late TextEditingController _dateController;
  late TextEditingController _dueDateController;
  late TextEditingController _amountController;
  late TextEditingController _taxAmountController;
  late TextEditingController _discountController;
  late TextEditingController _totalAmountController;
  late TextEditingController _paidAmountController;
  late TextEditingController _notesController;
  late TextEditingController _technicianController;
  late String _status;
  late String _paymentMethod;
  final List<Map<String, dynamic>> _services = [];
  final List<Map<String, dynamic>> _parts = [];

  @override
  void initState() {
    super.initState();
    _invoiceNumberController =
        TextEditingController(text: widget.invoice['invoiceNumber'] ?? '');
    _customerController =
        TextEditingController(text: widget.invoice['customer'] ?? '');
    _customerPhoneController =
        TextEditingController(text: widget.invoice['customerPhone'] ?? '');
    _customerEmailController =
        TextEditingController(text: widget.invoice['customerEmail'] ?? '');
    _carModelController =
        TextEditingController(text: widget.invoice['carModel'] ?? '');
    _carPlateController =
        TextEditingController(text: widget.invoice['carPlate'] ?? '');
    _carColorController =
        TextEditingController(text: widget.invoice['carColor'] ?? '');
    _carMileageController = TextEditingController(
        text: widget.invoice['carMileage']?.toString() ?? '');
    _dateController = TextEditingController(
        text: widget.invoice['date'] ??
            DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _dueDateController =
        TextEditingController(text: widget.invoice['dueDate'] ?? '');
    _amountController =
        TextEditingController(text: widget.invoice['amount']?.toString() ?? '');
    _taxAmountController = TextEditingController(
        text: widget.invoice['taxAmount']?.toString() ?? '0.0');
    _discountController = TextEditingController(
        text: widget.invoice['discount']?.toString() ?? '0.0');
    _totalAmountController = TextEditingController(
        text: widget.invoice['totalAmount']?.toString() ?? '');
    _paidAmountController = TextEditingController(
        text: widget.invoice['paidAmount']?.toString() ?? '');
    _notesController =
        TextEditingController(text: widget.invoice['notes'] ?? '');
    _technicianController =
        TextEditingController(text: widget.invoice['technician'] ?? '');
    _status = widget.invoice['status'] ?? 'Pending';
    _paymentMethod = widget.invoice['paymentMethod'] ?? 'Cash';
    _services.addAll(widget.invoice['services'] ?? []);
    _parts.addAll(widget.invoice['parts'] ?? []);

    // حساب المبالغ التلقائية إذا لم تكن محددة
    _calculateTotals();
  }

  void _calculateTotals() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double taxAmount = double.tryParse(_taxAmountController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;

    double total = amount + taxAmount - discount;
    _totalAmountController.text = total.toStringAsFixed(2);

    double paid = double.tryParse(_paidAmountController.text) ?? 0.0;
    widget.invoice['balance'] = total - paid;
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController priceController = TextEditingController();
        TextEditingController descController = TextEditingController();
        TextEditingController techController = TextEditingController();

        return AlertDialog(
          title: Text('إضافة خدمة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'اسم الخدمة')),
                TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'السعر'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: 'الوصف')),
                TextField(
                    controller: techController,
                    decoration: InputDecoration(labelText: 'الفني المسؤول')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _services.add({
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'description': descController.text,
                    'technician': techController.text,
                  });
                  _updateAmountFromServices();
                  Navigator.pop(context);
                });
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _updateAmountFromServices() {
    double servicesTotal =
        _services.fold(0.0, (sum, service) => sum + (service['price'] ?? 0.0));
    _amountController.text = servicesTotal.toStringAsFixed(2);
    _calculateTotals();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedInvoice = {
        ...widget.invoice,
        'invoiceNumber': _invoiceNumberController.text,
        'customer': _customerController.text,
        'customerPhone': _customerPhoneController.text,
        'customerEmail': _customerEmailController.text,
        'carModel': _carModelController.text,
        'carPlate': _carPlateController.text,
        'carColor': _carColorController.text,
        'carMileage': int.tryParse(_carMileageController.text) ?? 0,
        'date': _dateController.text,
        'dueDate': _dueDateController.text,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'taxAmount': double.tryParse(_taxAmountController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'totalAmount': double.tryParse(_totalAmountController.text) ?? 0.0,
        'paidAmount': double.tryParse(_paidAmountController.text) ?? 0.0,
        'balance': double.tryParse(_totalAmountController.text)! -
            (double.tryParse(_paidAmountController.text) ?? 0.0),
        'status': _status,
        'paymentMethod': _paymentMethod,
        'notes': _notesController.text,
        'technician': _technicianController.text,
        'services': List<Map<String, dynamic>>.from(_services),
        'parts': List<Map<String, dynamic>>.from(_parts),
        'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      };

      widget.onSave(updatedInvoice);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الفاتورة'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('معلومات الفاتورة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              TextFormField(
                controller: _invoiceNumberController,
                decoration: InputDecoration(labelText: 'رقم الفاتورة'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'التاريخ',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _dateController),
                  ),
                ),
              ),
              TextFormField(
                controller: _dueDateController,
                decoration: InputDecoration(
                  labelText: 'تاريخ الاستحقاق',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _dueDateController),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('معلومات العميل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              TextFormField(
                controller: _customerController,
                decoration: InputDecoration(labelText: 'اسم العميل'),
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _customerPhoneController,
                decoration: InputDecoration(labelText: 'هاتف العميل'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _customerEmailController,
                decoration: InputDecoration(labelText: 'بريد العميل'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              Text('معلومات السيارة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              TextFormField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: 'موديل السيارة'),
              ),
              TextFormField(
                controller: _carPlateController,
                decoration: InputDecoration(labelText: 'رقم اللوحة'),
              ),
              TextFormField(
                controller: _carColorController,
                decoration: InputDecoration(labelText: 'لون السيارة'),
              ),
              TextFormField(
                controller: _carMileageController,
                decoration: InputDecoration(labelText: 'عدد الكيلومترات'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text('الخدمات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              ..._services
                  .map((service) => ListTile(
                        title: Text(service['name']),
                        subtitle: Text(
                            'السعر: ${service['price']} - الفني: ${service['technician']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _services.remove(service);
                              _updateAmountFromServices();
                            });
                          },
                        ),
                      ))
                  .toList(),
              ElevatedButton(
                onPressed: _addService,
                child: Text('إضافة خدمة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(height: 20),
              Text('المعلومات المالية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'المبلغ الإجمالي'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotals(),
              ),
              TextFormField(
                controller: _taxAmountController,
                decoration: InputDecoration(labelText: 'الضريبة'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotals(),
              ),
              TextFormField(
                controller: _discountController,
                decoration: InputDecoration(labelText: 'الخصم'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotals(),
              ),
              TextFormField(
                controller: _totalAmountController,
                decoration: InputDecoration(labelText: 'المبلغ النهائي'),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              TextFormField(
                controller: _paidAmountController,
                decoration: InputDecoration(labelText: 'المبلغ المدفوع'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateTotals();
                  setState(() {
                    if ((double.tryParse(_paidAmountController.text) ?? 0.0) >=
                        (double.tryParse(_totalAmountController.text) ?? 0.0)) {
                      _status = 'Paid';
                    } else {
                      _status = 'Pending';
                    }
                  });
                },
              ),
              Text(
                  'الرصيد المتبقي: ${widget.invoice['balance']?.toStringAsFixed(2) ?? '0.00'}'),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: ['Cash', 'Credit Card', 'Bank Transfer', 'Check']
                    .map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paymentMethod = value!),
                decoration: InputDecoration(labelText: 'طريقة الدفع'),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Pending', 'Paid', 'Partially Paid', 'Cancelled']
                    .map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
                decoration: InputDecoration(labelText: 'حالة الفاتورة'),
              ),
              SizedBox(height: 20),
              Text('معلومات إضافية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              TextFormField(
                controller: _technicianController,
                decoration: InputDecoration(labelText: 'الفني المسؤول'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'ملاحظات'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    child:
                        Text('حفظ التغييرات', style: TextStyle(fontSize: 18)),
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
