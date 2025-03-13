import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:inventory_management_system/services/auth_service.dart';

import 'package:inventory_management_system/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = "Pharmacist"; // Default role
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final authService = context.read<AuthService>();

    String? result = await authService.registerUser(name, email, password, _selectedRole);

    setState(() => _isLoading = false);

    if (result == "User Registered Successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? "Registration Successful"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back to Login Screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? "Registration Failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // appBar: AppBar(title: const Text("Register New User")),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                        "assets/images/logo.png",
                        width: AppSizes.wp(150),
                        height: AppSizes.hp(150),
                      ),
                      // const SizedBox(height: 10),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: AppSizes.sp(24),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTextColorDark,
                        ),
                      ),
                      const SizedBox(height: 40),
                    CustomInputField(
                      controller: _nameController,
                      labelText: "Full Name",
                      validator: (value) => value!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 15),
                                                   
                    CustomInputField(
                      controller: _emailController,
                      labelText: "Email",
                      validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
                    ),
                    
                    const SizedBox(height: 15),
                    
                    CustomInputField(
                      controller: _passwordController,
                      labelText: "Password",
                      // obscureText: true,
                      validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    
                    const SizedBox(height: 15),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        hintText: "Select Role",
                        hintStyle: TextStyle(
                          fontSize: AppSizes.sp(14),
                          color: AppTheme.lightTextColorDark.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: AppTheme.lightFieldsBgColor,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 24,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 3,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 3,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      items: ["Admin", "Pharmacist"].map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                          width: AppSizes.wp(160),
                            text: "Register",
                            onPressed: _register,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
