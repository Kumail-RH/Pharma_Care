import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utility/constants.dart';
import '../../utility/theme.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  // Fetch bills from Firestore
  Stream<QuerySnapshot> fetchBills() {
    return FirebaseFirestore.instance.collection('bills').snapshots();
  }

  // Function to show bill details in a popup
  void showBillDetails(BuildContext context, Map<String, dynamic> billData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Bill Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Customer: ${billData['customerName']}", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Medicines:", style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (billData['medicines'] as List).map((med) {
                  return Text("- ${med['medicine']} (x${med['quantity']}) - \$${med['price']}");
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text("Total Price: \$${billData['totalPrice']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Invoices", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchBills(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var bills = snapshot.data!.docs;
          if (bills.isEmpty) {
            return Center(child: Text("No invoices available."));
          }

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              var billData = bills[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(billData['customerName']),
                  onTap: () => showBillDetails(context, billData),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
