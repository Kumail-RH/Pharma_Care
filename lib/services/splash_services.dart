// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management_system/screens/admin/admin_dashboard.dart';
// import 'package:inventory_management_system/screens/pharmacist/pharmacist_dashboard.dart';
// import 'package:inventory_management_system/screens/login_screen.dart';

// class SplashServices {
//   void isLogin(BuildContext context) {
//     final auth = FirebaseAuth.instance;
//     final user = auth.currentUser;

//     if (user == null) {
//       // If no user is logged in, navigate to Login Screen
//       Timer(const Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       });
//       return;
//     }

//     // Fetch user role from Firestore
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get()
//         .then((DocumentSnapshot userDoc) {
//       if (userDoc.exists && userDoc.data() != null) {
//         Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//         String role = userData['role'] ?? '';

//         Widget targetScreen;
//         if (role == 'admin') {
//           targetScreen = AdminDashboard();
//         } else if (role == 'pharmacist') {
//           targetScreen = PharmacistDashboard();
//         } else {
//           targetScreen = const LoginScreen(); // Default to login if role is invalid
//         }

//         Timer(const Duration(seconds: 3), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => targetScreen),
//           );
//         });
//       } else {
//         // If no user document found, log out and redirect to login screen
//         auth.signOut();
//         Timer(const Duration(seconds: 3), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginScreen()),
//           );
//         });
//       }
//     }).catchError((error) {
//       print('Error fetching user role: $error');
//       auth.signOut();
//       Timer(const Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       });
//     });
//   }
// }
