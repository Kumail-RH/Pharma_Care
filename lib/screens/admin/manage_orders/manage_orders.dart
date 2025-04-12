import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Manage Orders")),
        body: const Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Orders",
          style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),
        ),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stock_requests')
                    .where('status', isEqualTo: 'Pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No pending stock requests."));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.shopping_cart, color: Colors.orange),
                          title: Text("Medicine: ${data['medicineName']}"),
                          subtitle: Text("Requested: ${data['requestedQuantity']} units\nBy: ${data['pharmacistName'] ?? 'Fetching...'}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () async {
                                  _showOrderDialog(context, doc.id, data);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () async {
                                  await _updateStockRequest(doc.id, "Rejected", data['pharmacistId']);
                                },
                              ),
                            ],
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

  Future<void> _showOrderDialog(BuildContext context, String requestId, Map<String, dynamic> data) async {
    String selectedSupplier = '';
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Supplier & Quantity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var suppliers = snapshot.data!.docs.map((doc) => doc['name'].toString()).toList();
                if (suppliers.isEmpty) {
                  return Text("No Suppliers Found");
                }
                return DropdownButton<String>(
                  value: selectedSupplier.isNotEmpty ? selectedSupplier : suppliers[0],
                  onChanged: (value) {
                    selectedSupplier = value!;
                  },
                  items: suppliers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                );
              },
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Quantity"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _placeOrder(requestId, selectedSupplier, quantityController.text, data);
              Navigator.pop(context);
            },
            child: Text("Order"),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(String requestId, String supplier, String quantity, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('orders').add({
      'medicineName': data['medicineName'],
      'quantity': quantity,
      'supplier': supplier,
      'status': 'Ordered',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _updateStockRequest(requestId, "Approved", data['pharmacistId']);
  }

  Future<void> _updateStockRequest(String requestId, String status, String? pharmacistId) async {
    if (pharmacistId == null) return;
    await FirebaseFirestore.instance.collection('stock_requests').doc(requestId).update({'status': status});
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'Stock Request $status',
      'message': 'Your stock request has been $status.',
      'recipientId': pharmacistId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

