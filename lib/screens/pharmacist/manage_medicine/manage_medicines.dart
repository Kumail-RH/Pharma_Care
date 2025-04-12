import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';

class ManageMedicinesScreen extends StatefulWidget {
  const ManageMedicinesScreen({super.key});

  @override
  _ManageMedicinesScreenState createState() => _ManageMedicinesScreenState();
}

class _ManageMedicinesScreenState extends State<ManageMedicinesScreen> {
  DateTime? _selectedExpiryDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();

  void _addMedicine() async {
    if (_nameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _manufacturerController.text.isNotEmpty &&
        _batchNumberController.text.isNotEmpty) {
      int quantity = int.parse(_quantityController.text.trim());

      await _firestore.collection('medicines').add({
        'name': _nameController.text.trim(),
        'quantity': quantity,
        'price': double.parse(_priceController.text.trim()),
        'expiryDate': Timestamp.fromDate(_selectedExpiryDate!),
        'manufacturer': _manufacturerController.text.trim(),
        'batchNumber': _batchNumberController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      if (quantity < 5) {
        await _firestore.collection('stock_requests').add({
          'medicine_name': _nameController.text.trim(),
          'requested_by': 'admin',
          'status': 'Pending',
          'createdAt': Timestamp.now(),
        });
      }

      _clearFields();
      Navigator.pop(context);
    }
  }

  void _clearFields() {
    _nameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _expiryDateController.clear();
    _manufacturerController.clear();
    _batchNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Medicines"),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('medicines').orderBy(
            'createdAt', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No medicines found"));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['name']),
                  subtitle: Text(
                      "Quantity: ${doc['quantity']}\nPrice: ${doc['price']}\nExpiry: ${doc['expiryDate']}\nManufacturer: ${doc['manufacturer']}\nBatch: ${doc['batchNumber']}"),

                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: _showAddMedicineDialog,
        child: Icon(Icons.add, color: AppTheme.lightBgColor),
      ),
    );
  }

  void _showAddMedicineDialog() {

    Future<void> _pickDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedExpiryDate = pickedDate;
          _expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightBgColor,
          title: Text("Add Medicine"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInputField(controller: _nameController, labelText: 'Name'),
              CustomInputField(controller: _quantityController,
                  labelText: 'Quantity',
                  keyboardType: TextInputType.number),
              CustomInputField(controller: _priceController,
                  labelText: 'Price',
                  keyboardType: TextInputType.number),

              // Expiry Date Picker
              CustomInputField(
                controller: _expiryDateController,
                readOnly: true,
                labelText: 'Expiry Date',
                suffixIcon: Icon(Icons.calendar_today),
                onTap: _pickDate,
                ),

              CustomInputField(controller: _manufacturerController,
                  labelText: 'Manufacturer'),
              CustomInputField(controller: _batchNumberController,
                  labelText: 'Batch Number'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(onPressed: _addMedicine, child: Text("Add")),
          ],
        );
      },
    );
  }
}
