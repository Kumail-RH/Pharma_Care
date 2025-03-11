import 'package:flutter/material.dart';

class AppSizes {
  // Average reference dimensions (calculated from common small, medium, large devices)
  static const double _referenceWidth = 370; // Average of 320, 375, 414
  static const double _referenceHeight = 730; // Average of 480, 812, 896

  static late double _screenWidth;
  static late double _screenHeight;

  // Initialize with context
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
  }

  // Get responsive width for pixel value from mockup
  static double wp(double pixels) {
    return (pixels / _referenceWidth) * _screenWidth;
  }

  // Get responsive height for pixel value from mockup
  static double hp(double pixels) {
    return (pixels / _referenceHeight) * _screenHeight;
  }

  // Optional: Get responsive font size
  static double sp(double pixels) => wp(pixels);
}