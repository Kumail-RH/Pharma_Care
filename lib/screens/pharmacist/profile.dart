import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_management_system/screens/login_screen.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_button.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _nameController.text = userData['name'] ?? "";
      });
    }
  }

  Future<void> _updateName() async {
    setState(() => _isLoading = true);
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'name': _nameController.text});
    }
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Name updated successfully"), backgroundColor: Colors.green),
    );
  }

  Future<void> _resetPassword() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _auth.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent"), backgroundColor: Colors.blue),
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text("Profile & Settings", style: TextStyle(color: AppTheme.lightTextColorLight, fontSize: AppSizes.sp(18)),),
      backgroundColor: AppTheme.primaryColor,
      automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // const Text("Update Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text("Name", style: TextStyle(color: AppTheme.primaryColor, fontSize:  AppSizes.sp(16), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            CustomInputField(
              controller: _nameController, 
              labelText: 'Full Name', 
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                  width: AppSizes.wp(220),
                  text: "Update Name", onPressed: _updateName),
                // : ElevatedButton(
                //     onPressed: _updateName,
                //     child: const Text("Update Name"),
                //   ),
            // const Divider(),
            const SizedBox(height: 10),
            CustomButton(
              width: AppSizes.wp(220),
              onPressed: _resetPassword,
              text: ("Change Password"),
            ),
            const SizedBox(height: 10),
            CustomButton(
              width: AppSizes.wp(220),
              text: "Logout",
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
