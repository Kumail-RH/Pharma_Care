import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Register a New User
  // Future<String?> registerUser(String name, String email, String password, String role) async {
  //   try {
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     String uid = userCredential.user!.uid;

  //     // Store user details in Firestore
  //     await _firestore.collection('Users').doc(uid).set({
  //       'name': name,
  //       'email': email,
  //       'role': role,  // 'Admin' or 'Pharmacist'
  //       'userId': uid,
  //       'createdAt': FieldValue.serverTimestamp(), // ✅ Add timestamp
  //     });

  //     return "User Registered Successfully";
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       return "This email is already registered.";
  //     } else if (e.code == 'weak-password') {
  //       return "Password should be at least 6 characters.";
  //     } else {
  //       return "Registration failed: ${e.message}";
  //     }
  //   } catch (e) {
  //     print("Registration Error: $e");
  //     return "An unexpected error occurred. Please try again.";
  //   }
  // }
 Future<String?> registerUser(String name, String email, String password, String role) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      // Ensure Firestore entry is created
      await _firestore.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "role": role, // Ensure role is stored
        "createdAt": FieldValue.serverTimestamp(),
      });

      return "User Registered Successfully";
    }
    return "User creation failed";
  } on FirebaseAuthException catch (e) {
    return e.message ?? "Registration Failed";
  }
}



  // 🔹 Login User
  // Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
  //   try {
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     String uid = userCredential.user!.uid;

  //     // Fetch user role from Firestore
  //     DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();

  //     if (userDoc.exists && userDoc.data() != null && userDoc['role'] != null) {
  //       return {
  //         'role': userDoc['role'],
  //         'userId': uid,
  //       };
  //     } else {
  //       throw Exception("User role not found in Firestore.");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       return {'error': 'No user found with this email.'};
  //     } else if (e.code == 'wrong-password') {
  //       return {'error': 'Incorrect password. Try again.'};
  //     } else {
  //       return {'error': e.message};
  //     }
  //   } catch (e) {
  //     print("Login Error: $e");
  //     return {'error': "An unexpected error occurred."};
  //   }
  // }
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc['role'] ?? "Unknown"; // Retrieve role from Firestore
          return {"role": role, "uid": user.uid};
        } else {
          return {"error": "User data not found in Firestore"};
        }
      } else {
        return {"error": "User authentication failed"};
      }
    } on FirebaseAuthException catch (e) {
      return {"error": e.message ?? "Login failed"};
    }
  }

  // 🔹 Logout User
  Future<void> logout() async {
    await _auth.signOut();
  }
}
