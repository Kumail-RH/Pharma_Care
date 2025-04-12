import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/admin/customer_invoices/customer_invoices.dart';
import 'package:inventory_management_system/screens/admin/manage_medicines/manage_medicines.dart';
import 'package:inventory_management_system/screens/admin/manage_orders/manage_orders.dart';
import 'package:inventory_management_system/screens/admin/manage_pharmacists/manage_pharmacists.dart';
import 'package:inventory_management_system/screens/admin/suppliers/supplier.dart';
import 'package:inventory_management_system/utility/icon_assets.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';
import 'package:inventory_management_system/widgets/dashboard_button.dart';

class ManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Manage")),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 80),
        child: Column(
          children: [
            CustomAppbar(text: "Manage", icon: IconAssets.manageIcon),
            const SizedBox(height: 50),
            DashboardButton(
              prefixIcon: IconAssets.userIcon,
              text: 'Pharmacists',
              suffixIcon: IconAssets.arrowForward,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManagePharmacistsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            DashboardButton(
              prefixIcon: IconAssets.medIcon,
              text: 'Medicines',
              suffixIcon: IconAssets.arrowForward,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageMedicinesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              prefixIcon: IconAssets.cartIcon,
              text: 'Manage Orders',
              suffixIcon: IconAssets.arrowForward,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageOrdersScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              prefixIcon: IconAssets.supplierIcon,
              text: 'Manage Supplier',
              suffixIcon: IconAssets.arrowForward,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupplierScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              prefixIcon: IconAssets.invoices,
              text: 'Customer Bills',
              suffixIcon: IconAssets.arrowForward,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminInvoicesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _manageTile(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          ),
    );
  }
}
