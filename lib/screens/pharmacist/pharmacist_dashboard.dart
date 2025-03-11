import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/pharmacist/manage_medicines.dart';
import 'package:inventory_management_system/screens/pharmacist/process_order.dart';
import 'package:inventory_management_system/screens/pharmacist/profile.dart';
import 'package:inventory_management_system/screens/pharmacist/stock_alert.dart';
import 'package:inventory_management_system/utility/icon_assets.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';
// import 'package:inventory_management_system/screens/pharmacist/profile.dart';

class PharmacistDashboard extends StatelessWidget {
  const PharmacistDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(title: const Text("Pharmacist Dashboard")),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(
                  text: "Pharmacist Dashboard",
                  icon: IconAssets.dashboard,
                ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     _buildStatCard("Total Medicines", "120", Colors.blue),
              //     _buildStatCard("Pending Orders", "8", Colors.orange),
              //     _buildStatCard("Low Stock", "5", Colors.red),
              //   ],
              // ),
              const SizedBox(height: 60),
              // const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildActionCard("Manage Medicines", Icons.medical_services, Colors.green, context, ManageMedicinesScreen()),
                      _buildActionCard("Process\nOrders", Icons.shopping_cart, Colors.orange, context, ProcessOrdersScreen()),
                      _buildActionCard("Stock Alerts", Icons.warning, Colors.red, context,StockAlertScreen()),
                      _buildActionCard("Profile & Settings", Icons.person, Colors.blue, context, ProfileScreen()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildStatCard(String title, String value, Color color) {
  //   return Expanded(
  //     child: Card(
  //       color: color,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 10),
  //             Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionCard(String title, IconData icon, Color color, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        color: AppTheme.lightBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: AppTheme.darkBgColor, width: 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
