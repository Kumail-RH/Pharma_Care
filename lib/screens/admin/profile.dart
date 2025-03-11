import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_management_system/screens/login_screen.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: Container(
            color: AppTheme.primaryColor,
            height: 20.0,
          ),
        ),
        title: Padding(
        padding: const EdgeInsets.only(top: 30.0,),
        child: Text("Profile", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),),
      ),
      backgroundColor: AppTheme.primaryColor,
      automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.blue),
            SizedBox(height: 10),
            Text(user?.email ?? "Admin", style: TextStyle(fontSize: 18)),
            SizedBox(height: 50),
            CustomButton(
              width: AppSizes.wp(150),
              onPressed: () => _logout(context),
              text: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
