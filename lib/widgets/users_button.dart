import 'package:flutter/material.dart';

import '../utility/theme.dart';

class UsersButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const UsersButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double buttonWidth = screenWidth * (219 / screenWidth);
    double buttonHeight = screenHeight * (69 / screenHeight);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme
              .lightFieldsBgColor, // Transparent fill (customize if needed)
          borderRadius: BorderRadius.circular(20), // Rounded corners
          border: Border.all(
            color: AppTheme.primaryColor, // Stroke color
            width: 2, // Stroke width
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.lightTextColorDark, // Text color
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
