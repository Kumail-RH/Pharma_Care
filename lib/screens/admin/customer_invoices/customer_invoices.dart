import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import '../../../utility/constants.dart';
import '../../../utility/theme.dart';

class AdminInvoicesScreen extends StatelessWidget {
  const AdminInvoicesScreen({super.key});

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
                  return Text("- ${med['medicine']} (x${med['quantity']}) - ${med['price']}");
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text("Total Price: ${billData['totalPrice']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Future<void> generateAndDownloadPDF(Map<String, dynamic> billData) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Customer Billing Receipt", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Customer Name: ${billData['customerName']}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}", style: pw.TextStyle(fontSize: 18)),
              pw.Divider(),

              pw.Text("Medicines:", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

              pw.Column(
                children: (billData['medicines'] as List).map((med) {
                  return pw.Text("- ${med['medicine']} (x${med['quantity']}) - ${med['price']}");
                }).toList(),
              ),

              pw.Divider(),
              pw.Text("Total Price: ${billData['totalPrice']}", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );

      // Get the temporary directory to store the file
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/${billData['customerName']}_invoice.pdf';
      final File file = File(filePath);

      // Write PDF to file
      await file.writeAsBytes(await pdf.save());

      // Open/download the file
      await OpenFile.open(filePath);

      print("PDF saved at: $filePath");
    } catch (e) {
      print("Error generating PDF: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invoices", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18))),
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
                  subtitle: Text("Total Price: ${billData['totalPrice']}"),
                  onTap: () => showBillDetails(context, billData),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () => generateAndDownloadPDF(billData),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
