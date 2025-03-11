import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/admin/dashboard_screen.dart';
import 'package:inventory_management_system/screens/admin/manage_screen.dart';
import 'package:inventory_management_system/screens/admin/profile.dart';
import 'package:inventory_management_system/utility/theme.dart';

class CustomNavbar extends StatefulWidget {
  final int selectedIndex;

  const CustomNavbar({super.key, this.selectedIndex = 0});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  late int _currentIndex;

  final List<Widget> _pages = [
    DashboardScreen(),
    ManageScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex; // Use clicked index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // Smooth transition
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: GlobalKey<CurvedNavigationBarState>(),
        index: _currentIndex,
        items: const <Widget>[
          Icon(Icons.dashboard, size: 40, color: Colors.white),
          Icon(Icons.manage_accounts, size: 40, color: Colors.white),
          Icon(Icons.person, size: 40, color: Colors.white),
        ],
        color: AppTheme.primaryColor,
        buttonBackgroundColor: AppTheme.darkPrimaryColor,
        backgroundColor: AppTheme.lightBgColor,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the index dynamically
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
