import 'package:flutter/material.dart';
import 'package:inventory_management_system/services/auth_service.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:inventory_management_system/screens/admin/admin_dashboard.dart';
import 'package:inventory_management_system/screens/pharmacist/pharmacist_dashboard.dart';
import 'package:inventory_management_system/screens/register_screen.dart';
import 'package:inventory_management_system/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final authService = context.read<AuthService>();
    var result = await authService.signInWithEmail(email, password);

    setState(() => _isLoading = false);

    if (result != null && !result.containsKey('error')) {
      String role = result['role'];

      if (role == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else if (role == 'Pharmacist') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PharmacistDashboard()),
        );
      } else {
        _showError("Unauthorized Access!");
      }
    } else {
      _showError(result?['error'] ?? "Login Failed! Check credentials.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double logoWidth = screenWidth * (202 / screenWidth);
    double logoHeight = screenHeight * (202 / screenHeight);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                    "assets/images/logo.png",
                      width: logoWidth,
                      height: logoHeight,
                    ),
                  const SizedBox(height: 10),
                    Text(
                    "Login",
                    style: TextStyle(
                      fontSize: AppSizes.sp(24),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTextColorDark,
                    ),
                  ),
                    const SizedBox(height: 50),
                      
                    CustomInputField(
                    labelText: "Enter your Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                    const SizedBox(height: 20),
                  CustomInputField(
                    labelText: "Enter your Password",
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your password'
                        : null,
                  ),
                      
                    const SizedBox(height: 20),
                      
                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            text: "Login",
                            onPressed: _login,
                          ),
                      
                    const SizedBox(height: 60),
                      
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                            fontSize: AppSizes.sp(14),
                            color: AppTheme.lightTextColorDark,
                            fontWeight: FontWeight.w200),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                                fontSize: AppSizes.sp(16),
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
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
