import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';

class ProcessOrdersScreen extends StatelessWidget {
  const ProcessOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Process Orders")),
        body: const Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Process Orders", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),),
      backgroundColor: AppTheme.primaryColor,
      automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stock_requests')
                    .where('pharmacistId', isEqualTo: user.uid) // Filter by pharmacist ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No stock requests available."));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String status = data['status'] ?? 'Pending';

                      return Card(
                        child: Container(
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
                            leading: const Icon(Icons.shopping_cart, color: Colors.orange),
                            title: Text("Medicine: ${data['medicineName']}"),
                            subtitle: Text("Requested: ${data['requestedQuantity']} units"),
                            trailing: _getStatusIcon(status),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case "Approved":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "Rejected":
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange); // Pending status
    }
  }
}
