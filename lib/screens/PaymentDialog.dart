import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final Function(Map<String, String>) onPaymentConfirmed;

  const PaymentDialog({required this.onPaymentConfirmed, super.key});

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Payment Details"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Card Number"),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 16) {
                    return 'Enter valid card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: expiryDateController,
                decoration: InputDecoration(labelText: "Expiry Date (MM/YY)"),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                    return 'Enter valid expiry date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "CVV"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Enter valid CVV';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text("Confirm Payment"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final paymentData = {
                'cardNumber': cardNumberController.text,
                'expiryDate': expiryDateController.text,
                'cvv': cvvController.text,
              };
              widget.onPaymentConfirmed(paymentData);
            }
          },
        ),
      ],
    );
  }
}
