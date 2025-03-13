import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';

class StockAlertScreen extends StatelessWidget {
  const StockAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime expiryThreshold = now.add(const Duration(days: 3));

    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Alert"),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Low Stock Medicines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildMedicineList(
                      query: FirebaseFirestore.instance
                          .collection('medicines')
                          .where('quantity', isLessThan: 7),
                      noDataMessage: "No low-stock medicines.",
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 2, color: Colors.black),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Near Expiry Medicines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildMedicineList(
                      query: FirebaseFirestore.instance
                          .collection('medicines')
                          .where('expiryDate',
                          isLessThanOrEqualTo:
                          Timestamp.fromDate(expiryThreshold)),
                      noDataMessage: "No near-expiry medicines.",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineList({
    required Query query,
    required String noDataMessage,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(noDataMessage));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;

            DateTime? expiryDate;
            if (data['expiryDate'] is Timestamp) {
              expiryDate = (data['expiryDate'] as Timestamp).toDate();
            } else if (data['expiryDate'] is String) {
              expiryDate = DateTime.tryParse(data['expiryDate']);
            }

            return StockAlertTile(
              medicineId: doc.id,
              medicineName: data['name'],
              quantity: data['quantity'],
              expiryDate: expiryDate,
            );
          }).toList(),
        );
      },
    );
  }
}

class StockAlertTile extends StatelessWidget {
  final String medicineId;
  final String medicineName;
  final int quantity;
  final DateTime? expiryDate;

  const StockAlertTile({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    this.expiryDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        tileColor: AppTheme.lightBgColor,
        title: Text(medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stock Left: $quantity"),
            if (expiryDate != null)
              Text(
                "Expiry Date: ${expiryDate!.toLocal()}",
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: const Icon(Icons.warning, color: Colors.red),
        onTap: () {
          _showStockRequestDialog(context);
        },
      ),
    );
  }

  void _showStockRequestDialog(BuildContext context) {
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Request New Stock"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Medicine: $medicineName"),
              CustomInputField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  labelText: "Enter New Stock Quantity"),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                int? newQuantity = int.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity > 0) {
                  await _sendStockRequest(context, newQuantity);
                }
              },
              child: const Text("Request"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendStockRequest(BuildContext context, int requestedQuantity) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String pharmacistName = userDoc.exists ? userDoc['name'] : "Unknown";

    DocumentReference requestRef = await FirebaseFirestore.instance.collection('stock_requests').add({
      'medicineId': medicineId,
      'medicineName': medicineName,
      'requestedQuantity': requestedQuantity,
      'pharmacistId': user.uid,
      'pharmacistName': pharmacistName,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance.collection('notifications').add({
      'to': 'admin',
      'message': 'New stock request for $medicineName by $pharmacistName',
      'requestId': requestRef.id,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Stock request sent successfully!"),
      backgroundColor: Colors.green,
    ));
  }
}