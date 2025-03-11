import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/icon_assets.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(text: "Admin Dashboard", icon: IconAssets.dashboard,),
            
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1, child: _dashboardCard("Pharmacists", "pharmacists")),
                  Expanded(flex: 1, child: _dashboardCard("Medicines", "medicines")),
                  Expanded(flex: 1, child: _dashboardCard("Orders", "orders")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(String title, String collection) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection(collection).get(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Card(
          color: AppTheme.lightBgColor,
          shadowColor: AppTheme.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              children: [
                Text(title,
                 style: TextStyle(
                  fontSize: AppSizes.sp(10),
                   fontWeight: FontWeight.bold)
                   ),
                SizedBox(height: 15),
                Text(count.toString(), style: TextStyle(fontSize: AppSizes.sp(16))),
              ],
            ),
          ),
        );
      },
    );
  }
}
