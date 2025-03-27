import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/pharmacist/invoices/Invoices.dart';
import 'package:inventory_management_system/screens/pharmacist/customer_POS/customer.dart';
import 'package:inventory_management_system/screens/pharmacist/manage_medicine/manage_medicines.dart';
import 'package:inventory_management_system/screens/pharmacist/process_order/process_order.dart';
import 'package:inventory_management_system/screens/pharmacist/profile.dart';
import 'package:inventory_management_system/screens/pharmacist/stock_alerts/stock_alert.dart';
import 'package:inventory_management_system/utility/icon_assets.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';

class PharmacistDashboard extends StatefulWidget {
  const PharmacistDashboard({super.key});

  @override
  State<PharmacistDashboard> createState() => _PharmacistDashboardState();
}

class _PharmacistDashboardState extends State<PharmacistDashboard> {
  Stream<int> getAlertStockCountStream() {
    return FirebaseFirestore.instance.collection('medicines').snapshots().map((
      snapshot,
    ) {
      int lowStockCount = 0;
      int nearExpiryCount = 0;
      DateTime expiryThreshold = DateTime.now().add(const Duration(days: 3));

      for (var doc in snapshot.docs) {
        var data = doc.data();
        int quantity = data['quantity'] ?? 0;
        DateTime? expiryDate;
        if (data['expiryDate'] is Timestamp) {
          expiryDate = (data['expiryDate'] as Timestamp).toDate();
        }

        if (quantity < 7) lowStockCount++;
        if (expiryDate != null && expiryDate.isBefore(expiryThreshold))
          nearExpiryCount++;
      }

      return lowStockCount + nearExpiryCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(
                text: "Pharmacist Dashboard",
                icon: IconAssets.dashboard,
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: StreamBuilder<int>(
                    stream: getAlertStockCountStream(),
                    builder: (context, snapshot) {
                      int stockAlertCount = snapshot.data ?? 0;

                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _buildActionCard(
                            "Customer\nPOS",
                            Icons.person,
                            Colors.green,
                            context,
                            CustomerBillingScreen(),
                          ),
                          _buildActionCard(
                            "Process\nOrders",
                            Icons.shopping_cart,
                            Colors.orange,
                            context,
                            ProcessOrdersScreen(),
                          ),
                          _buildActionCard(
                            "Stock\nAlerts",
                            Icons.warning,
                            Colors.red,
                            context,
                            StockAlertScreen(),
                            stockAlertCount: stockAlertCount,
                          ),
                          _buildActionCard(
                            "Manage\nMedicines",
                            Icons.medical_services,
                            Colors.green,
                            context,
                            ManageMedicinesScreen(),
                          ),
                          _buildActionCard(
                            "Invoices & \nBills",
                            Icons.receipt,
                            Colors.blue,
                            context,
                            InvoicesScreen(),
                          ),
                          _buildActionCard(
                            "Profile & \nSettings",
                            Icons.person,
                            Colors.purple,
                            context,
                            ProfileScreen(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    BuildContext context,
    Widget screen, {
    int stockAlertCount = 0,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        color: AppTheme.lightBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppTheme.darkBgColor, width: 1),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: color),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (stockAlertCount > 0 && title == "Stock\nAlerts")
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    stockAlertCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
