// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final String? icon;
  final VoidCallback onPressed;
  double? width;

  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {

    width = width ?? 130;

    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSizes.wp(width!),
        height: AppSizes.hp(59),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              AppTheme.primaryColor, // Transparent fill (customize if needed)
          borderRadius: BorderRadius.circular(20), // Rounded corners
          border: Border.all(
            color: AppTheme.whiteColor, // Stroke color
            width: 2, // Stroke width
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.blackColor.withOpacity(0.5), // Shadow color
              offset: const Offset(0, 4), // X: 0, Y: 4
              blurRadius: 4, // Blur radius
              spreadRadius: 0, // No spread
            ),
          ],
        ),
        child: icon != null
            ? Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      icon!,
                      width: 34,
                      height: 34,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: AppTheme.lightTextColorLight, // Text color
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  color: AppTheme.lightTextColorLight, // Text color
                  fontSize: AppSizes.sp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
