import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/admin/admin_dashboard.dart';
import 'package:inventory_management_system/screens/pharmacist/pharmacist_dashboard.dart';
import 'package:inventory_management_system/screens/login_screen.dart';

class SplashServices {
  void isLogin(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      // No user logged in, navigate to Login Screen
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return;
    }

    try {
      // Fetch user role from Firestore
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('role')) {
          String role = userData['role'];

          Widget targetScreen = (role == 'admin')
              ? AdminDashboard()
              : PharmacistDashboard(); // Default pharmacist if role is not admin

          Timer(const Duration(seconds: 3), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          });
        } else {
          // If role is missing, log out and navigate to login
          _handleError(auth, context);
        }
      } else {
        // If user document does not exist, log out and navigate to login
        _handleError(auth, context);
      }
    } catch (error) {
      print('Error fetching user role: $error');
      _handleError(auth, context);
    }
  }

  void _handleError(FirebaseAuth auth, BuildContext context) {
    auth.signOut();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }
}
