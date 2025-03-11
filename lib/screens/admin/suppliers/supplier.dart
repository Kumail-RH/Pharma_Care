import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/data_input_field.dart';
class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  void addSupplier() async {
    if (nameController.text.isEmpty ||
        contactController.text.isEmpty ||
        companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('suppliers').add({
      'name': nameController.text,
      'contact': contactController.text,
      'company': companyController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Supplier added successfully!")),
    );

    nameController.clear();
    contactController.clear();
    companyController.clear();
  }

  Stream<QuerySnapshot> fetchSuppliers() {
    return FirebaseFirestore.instance.collection('suppliers').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(text: "Supplier Management"),
              SizedBox(height: 20),
              DataInputField(labelText: "Supplier Name", controller: nameController),
              SizedBox(height: 10),
              DataInputField(labelText: "Contact Number", controller: contactController),
              SizedBox(height: 10),
              DataInputField(labelText: "Company Name", controller: companyController),
              SizedBox(height: 20),
              CustomButton(text: "Add Supplier", onPressed: addSupplier),
              SizedBox(height: 30),
              Text("Supplier List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: fetchSuppliers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var suppliers = snapshot.data!.docs;
                    if (suppliers.isEmpty) {
                      return Center(child: Text("No suppliers added yet."));
                    }
                    return ListView.builder(
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        var supplier = suppliers[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(supplier['name']),
                            subtitle: Text("${supplier['company']} - ${supplier['contact']}"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
