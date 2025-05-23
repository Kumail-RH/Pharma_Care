import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';

class ManageMedicinesScreen extends StatefulWidget {
  const ManageMedicinesScreen({super.key});

  @override
  _ManageMedicinesScreenState createState() => _ManageMedicinesScreenState();
}

class _ManageMedicinesScreenState extends State<ManageMedicinesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();

  // Function to show add medicine dialog
// Function to pick an expiry date
  Future<void> _pickExpiryDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Function to show add medicine dialog
  void _showAddMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Medicine"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: _quantityController, decoration: InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
              TextField(controller: _priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: "Expiry Date",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _pickExpiryDate(context),
                  ),
                ),
                readOnly: true,
              ),
              TextField(controller: _manufacturerController, decoration: InputDecoration(labelText: "Manufacturer")),
              TextField(controller: _batchNumberController, decoration: InputDecoration(labelText: "Batch Number")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: _addMedicine,
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
  // Function to add a medicine
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
        'expiryDate': _expiryDateController.text.trim(),
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

      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _expiryDateController.clear();
      _manufacturerController.clear();
      _batchNumberController.clear();
      Navigator.pop(context);
    }
  }

  // Function to update a medicine
  void _updateMedicine(String id, String name, int quantity, double price, String expiryDate, String manufacturer, String batchNumber) async {
    _nameController.text = name;
    _quantityController.text = quantity.toString();
    _priceController.text = price.toString();
    _expiryDateController.text = expiryDate;
    _manufacturerController.text = manufacturer;
    _batchNumberController.text = batchNumber;

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
              CustomInputField(controller: _quantityController, labelText: 'Quantity', keyboardType: TextInputType.number),
              CustomInputField(controller: _priceController, labelText: 'Price', keyboardType: TextInputType.number),
              CustomInputField(controller: _expiryDateController, labelText: 'Expiry Date'),
              CustomInputField(controller: _manufacturerController, labelText: 'Manufacturer'),
              CustomInputField(controller: _batchNumberController, labelText: 'Batch Number'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                int newQuantity = int.parse(_quantityController.text.trim());
                await _firestore.collection('medicines').doc(id).update({
                  'name': _nameController.text.trim(),
                  'quantity': newQuantity,
                  'price': double.parse(_priceController.text.trim()),
                  'expiryDate': _expiryDateController.text.trim(),
                  'manufacturer': _manufacturerController.text.trim(),
                  'batchNumber': _batchNumberController.text.trim(),
                });

                if (newQuantity < 5) {
                  await _firestore.collection('stock_requests').add({
                    'medicine_name': _nameController.text.trim(),
                    'requested_by': 'admin',
                    'status': 'Pending',
                    'createdAt': Timestamp.now(),
                  });
                }

                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a medicine
  void _deleteMedicine(String id) async {
    await _firestore.collection('medicines').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Medicines",
          style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),
        ),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('medicines').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No medicines found"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text("Quantity: ${doc['quantity']}\nPrice: ${doc['price']}\nExpiry: ${doc['expiryDate']}\nManufacturer: ${doc['manufacturer']}\nBatch: ${doc['batchNumber']}"),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _updateMedicine(doc.id, doc['name'], doc['quantity'], doc['price'], doc['expiryDate'], doc['manufacturer'], doc['batchNumber']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteMedicine(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicineDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
