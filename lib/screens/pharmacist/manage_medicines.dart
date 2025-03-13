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

//   void _showAddMedicineDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: AppTheme.lightBgColor,
//           title: Text("Add Medicine"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CustomInputField(controller: _nameController, labelText: 'Name'),
//               CustomInputField(controller: _quantityController, labelText: 'Quantity', keyboardType: TextInputType.number),
//               CustomInputField(controller: _priceController, labelText: 'Price', keyboardType: TextInputType.number),
//               CustomInputField(controller: _expiryDateController, labelText: 'Expiry Date'),
//               CustomInputField(controller: _manufacturerController, labelText: 'Manufacturer'),
//               CustomInputField(controller: _batchNumberController, labelText: 'Batch Number'),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//             ElevatedButton(onPressed: _addMedicine, child: Text("Add")),
//           ],
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/semantics.dart';
// import 'package:inventory_management_system/utility/constants.dart';
// import 'package:inventory_management_system/utility/theme.dart';
// import 'package:inventory_management_system/widgets/custom_input_field.dart';
//
// class ManageMedicinesScreen extends StatefulWidget {
//   const ManageMedicinesScreen({super.key});
//
//   @override
//   _ManageMedicinesScreenState createState() => _ManageMedicinesScreenState();
// }
//
// class _ManageMedicinesScreenState extends State<ManageMedicinesScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _expiryDateController = TextEditingController();
//
//   // Function to add a medicine
//   void _addMedicine() async {
//     if (_nameController.text.isNotEmpty &&
//         _quantityController.text.isNotEmpty &&
//         _priceController.text.isNotEmpty &&
//         _expiryDateController.text.isNotEmpty) {
//       int quantity = int.parse(_quantityController.text.trim());
//
//       await _firestore.collection('medicines').add({
//         'name': _nameController.text.trim(),
//         'quantity': quantity,
//         'price': double.parse(_priceController.text.trim()),
//         'expiryDate': _expiryDateController.text.trim(),
//         'createdAt': Timestamp.now(),
//       });
//
//       // Check stock level and send request if below threshold
//       if (quantity < 5) {
//         await _firestore.collection('stock_requests').add({
//           'medicine_name': _nameController.text.trim(),
//           'requested_by': 'admin', // Adjust as needed
//           'status': 'Pending',
//           'createdAt': Timestamp.now(),
//         });
//       }
//
//       _nameController.clear();
//       _quantityController.clear();
//       _priceController.clear();
//       _expiryDateController.clear();
//       Navigator.pop(context);
//     }
//   }
//
//   // Function to update a medicine
//   void _updateMedicine(String id, String name, int quantity, double price, String expiryDate) async {
//     _nameController.text = name;
//     _quantityController.text = quantity.toString();
//     _priceController.text = price.toString();
//     _expiryDateController.text = expiryDate;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Update Medicine"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
//               TextField(controller: _quantityController, decoration: InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
//               TextField(controller: _priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
//               TextField(controller: _expiryDateController, decoration: InputDecoration(labelText: "Expiry Date")),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//             ElevatedButton(
//               onPressed: () async {
//                 int newQuantity = int.parse(_quantityController.text.trim());
//                 await _firestore.collection('medicines').doc(id).update({
//                   'name': _nameController.text.trim(),
//                   'quantity': newQuantity,
//                   'price': double.parse(_priceController.text.trim()),
//                   'expiryDate': _expiryDateController.text.trim(),
//                 });
//
//                 // Check stock level after update
//                 if (newQuantity < 5) {
//                   await _firestore.collection('stock_requests').add({
//                     'medicine_name': _nameController.text.trim(),
//                     'requested_by': 'admin',
//                     'status': 'Pending',
//                     'createdAt': Timestamp.now(),
//                   });
//                 }
//
//                 Navigator.pop(context);
//               },
//               child: Text("Update"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Function to delete a medicine
//   void _deleteMedicine(String id) async {
//     await _firestore.collection('medicines').doc(id).delete();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Manage Medicines", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),),
//       backgroundColor: AppTheme.primaryColor,
//       automaticallyImplyLeading: false,
//       ),
//
//       body: StreamBuilder(
//         stream: _firestore.collection('medicines').orderBy('createdAt', descending: true).snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No medicines found"));
//           }
//
//           return Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: ListView(
//               children: snapshot.data!.docs.map((doc) {
//                 bool isLowStock = doc['quantity'] < 5;
//                 return Card(
//                   color: isLowStock ? Colors.red.shade100 : null,
//                   child: Container(
//                     width: AppSizes.wp(350),
//                 height: AppSizes.hp(110),
//                 decoration: BoxDecoration(
//               color:
//                   AppTheme.lightBgColor, // Transparent fill (customize if needed)
//               borderRadius: BorderRadius.circular(20), // Rounded corners
//               border: Border.all(
//                 color: AppTheme.primaryColor, // Stroke color
//                 width: 2, // Stroke width
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppTheme.blackColor.withOpacity(0.5), // Shadow color
//                   offset: const Offset(0, 4), // X: 0, Y: 4
//                   blurRadius: 4, // Blur radius
//                   spreadRadius: 0, // No spread
//                 ),
//               ],
//                       ),
//                     child: ListTile(
//                       leading: Icon(Icons.medical_services, color: isLowStock ? Colors.red : Colors.green),
//                       title: Text(doc['name']),
//                       subtitle: Text("Quantity: ${doc['quantity']}\nPrice: \$${doc['price']}\nExpiry: ${doc['expiryDate']}"),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (isLowStock) Icon(Icons.warning, color: Colors.red), // Alert Icon
//                           IconButton(
//                             icon: Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => _updateMedicine(doc.id, doc['name'], doc['quantity'], doc['price'], doc['expiryDate']),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _deleteMedicine(doc.id),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppTheme.primaryColor,
//         onPressed: _showAddMedicineDialog,
//         child: Icon(Icons.add, color: AppTheme.lightBgColor,),
//       ),
//     );
//   }
//
//   // Dialog to add medicine
//   void _showAddMedicineDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: AppTheme.lightBgColor,
//           title: Text("Add Medicine"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CustomInputField(controller: _nameController, labelText: 'Name', ),
//               CustomInputField(controller: _quantityController, labelText: 'Quantity', keyboardType: TextInputType.number),
//               CustomInputField(controller: _priceController, labelText: 'Price', keyboardType: TextInputType.number),
//               CustomInputField(controller: _expiryDateController, labelText: 'Expiry Date'),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: AppTheme.darkBgColor),)),
//             ElevatedButton(onPressed: _addMedicine, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: Text("Add", style: TextStyle(color: AppTheme.lightBgColor),),),
//           ],
//         );
//       },
//     );
//   }
// }
