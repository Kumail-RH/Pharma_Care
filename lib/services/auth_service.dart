import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new user
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

  // Login user with email and password
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

  //  Logout User
  Future<void> logout() async {
    await _auth.signOut();
  }
}
