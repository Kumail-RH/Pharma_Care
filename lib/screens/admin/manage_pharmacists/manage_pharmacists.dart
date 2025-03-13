import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';

class ManagePharmacistsScreen extends StatefulWidget {
  @override
  _ManagePharmacistsScreenState createState() => _ManagePharmacistsScreenState();
}

class _ManagePharmacistsScreenState extends State<ManagePharmacistsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a pharmacist
  void _addPharmacist() async {
    if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
      await _firestore.collection('pharmacists').add({
        'name': _nameController.text,
        'email': _emailController.text,
        'createdAt': Timestamp.now(),
      });

      _nameController.clear();
      _emailController.clear();
      Navigator.pop(context);
    }
  }

  // Function to delete a pharmacist
  void _deletePharmacist(String id) async {
    await _firestore.collection('pharmacists').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Pharmacists", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),),
      backgroundColor: AppTheme.primaryColor,
      automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('pharmacists').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No pharmacists found"));
          }

          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView(
              children: snapshot.data!.docs.map((doc) {
                return Container(
                  width: AppSizes.wp(350),
              height: AppSizes.hp(70),
              decoration: BoxDecoration(
            color:
                AppTheme.lightBgColor, // Transparent fill (customize if needed)
            borderRadius: BorderRadius.circular(20), // Rounded corners
            border: Border.all(
              color: AppTheme.primaryColor, // Stroke color
              width: 2, // Stroke width
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.blackColor.withOpacity(0.5), // Shadow color
                offset: const Offset(0, 4), // X: 0, Y: 4
                blurRadius: 4, // Blur radius
                spreadRadius: 0, // No spread
              ),
            ],
                    ),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(doc['name']),
                    subtitle: Text(doc['email']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePharmacist(doc.id),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showAddPharmacistDialog(),
        child: Icon(Icons.add, color: AppTheme.lightBgColor,),
      ),
    );
  }

  // Dialog to add a pharmacist
  void _showAddPharmacistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightBgColor,
          title: Text("Add Pharmacist"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInputField(controller: _nameController, labelText: 'Name', ),
              CustomInputField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),

            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: AppTheme.darkBgColor),)),
            ElevatedButton(onPressed: _addPharmacist, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: Text("Add", style: TextStyle(color: AppTheme.lightBgColor),),),
          ],
        );
      },
    );
  }
}
