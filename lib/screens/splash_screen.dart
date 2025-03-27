import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system/screens/admin/admin_dashboard.dart';
import 'package:inventory_management_system/screens/auth/login_screen.dart';
import 'package:inventory_management_system/screens/pharmacist/pharmacist_dashboard.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  //  SplashServices splashScreen = SplashServices();

  @override
  void initState() {
    super.initState();

    // splashScreen.isLogin(context);

    // Animation Controller
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Slide from left
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _checkUserRole();
    });
  }
  Future<void> _checkUserRole() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // Navigate to login screen if no user is found
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    return;
  }

  try {
    // Fetch user role asynchronously
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      String role = userDoc.get('role') ?? '';

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else if (role == 'pharmacist') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PharmacistDashboard()),
        );
      } else {
        // Logout and redirect if role is invalid
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // Logout and redirect if user document doesn't exist
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  } catch (e) {
    print('Error fetching user role: $e');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/logo.png',
              
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
