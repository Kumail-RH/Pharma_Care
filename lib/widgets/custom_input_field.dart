import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';


class CustomInputField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final Icon? suffixIcon;
  final VoidCallback? onTap;
  const CustomInputField(
      {super.key,
      this.controller,
      this.isPassword = false,
      this.keyboardType = TextInputType.text,
      this.validator,
      required this.labelText, this.readOnly, this.suffixIcon, this.onTap});

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.wp(330),
      height: AppSizes.hp(69),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword,
        validator: widget.validator,
        onTap: widget.onTap,
        style: TextStyle(
          color: AppTheme.lightTextColorDark, // Ensure text is the right color
          fontSize: AppSizes.sp(16),
        ),
        decoration: InputDecoration(
          hintText: widget.labelText,
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
      ),
    );
  }
}
