import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/theme.dart';

class StockAlertScreen extends StatelessWidget {
  const StockAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get today's date and calculate expiry threshold (3 days from now)
    DateTime now = DateTime.now();
    DateTime expiryThreshold = now.add(const Duration(days: 3));

    return Scaffold(
      // appBar: AppBar(title: const Text("Stock Alerts")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Low Stock Medicines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
        
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medicines')
                    .where('quantity', isLessThan: 5) // Low stock condition
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No low stock medicines."));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;

                      // Proper handling of expiryDate format
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
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Near Expiry Medicines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medicines')
                    .where('expiryDate', isLessThan: Timestamp.fromDate(expiryThreshold))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No medicines expiring soon."));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;

                      // Proper handling of expiryDate format
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
              ),
            ),
          ],
        ),
      ),
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
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter New Stock Quantity"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int? newQuantity = int.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity > 0) {
                  _sendStockRequest(context, newQuantity);
                }
              },
              child: const Text("Request"),
            ),
          ],
        );
      },
    );
  }

  void _sendStockRequest(BuildContext context, int requestedQuantity) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("User not logged in"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Send request to Firestore
    DocumentReference requestRef = await FirebaseFirestore.instance.collection('stock_requests').add({
      'medicineId': medicineId,
      'medicineName': medicineName,
      'requestedQuantity': requestedQuantity,
      'pharmacistId': user.uid,
      'pharmacistName': user.displayName ?? "Unknown",
      'status': 'Pending', // Admin will update it later
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify Admin about the new stock request
    FirebaseFirestore.instance.collection('notifications').add({
      'to': 'admin',
      'message': 'New stock request for $medicineName',
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
