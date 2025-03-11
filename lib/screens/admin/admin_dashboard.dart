import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/admin/dashboard_screen.dart';
import 'package:inventory_management_system/screens/admin/manage_screen.dart';
import 'package:inventory_management_system/screens/admin/profile.dart';
import 'package:inventory_management_system/widgets/custom_navbar.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    ManageScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavbar(),
    );
  }
}
