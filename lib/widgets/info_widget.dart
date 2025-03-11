import 'package:flutter/material.dart';

import '../utility/theme.dart';

class InfoWidget extends StatelessWidget {
  final String text;
  final String? hintText;
  final String icon;
  final String? hintText1;
  final String? hintText2;
  final TextEditingController? controller;
  final TextEditingController? controller1;
  final TextEditingController? controller2;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const InfoWidget(
      {super.key,
      required this.text,
      required this.icon,
      this.controller,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.hintText,
      this.hintText1,
      this.hintText2,
      this.controller1,
      this.controller2});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerWidth = screenWidth * (310 / screenWidth);
    double containerHeight = screenHeight * (158 / screenHeight);
    double sizedBoxHeight = screenHeight * (182 / screenHeight);
    return SizedBox(
      width: containerWidth,
      height: sizedBoxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 7.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTextColorDark,
              ),
            ),
          ),
          const SizedBox(
            height: 1,
          ),
          Container(
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.lightFieldsBgColor,
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2.5,
              ),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    color: AppTheme
                        .lightTextColorDark, // Ensure text is the right color
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: AppTheme.lightTextColorDark.withOpacity(0.7),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 18,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                          right: 17.0), // Adjust padding as needed
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          icon,
                          fit: BoxFit
                              .contain, // Ensures the image scales properly
                        ),
                      ),
                    ),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: controller1,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    color: AppTheme
                        .lightTextColorDark, // Ensure text is the right color
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText1,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: AppTheme.lightTextColorDark.withOpacity(0.7),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 18,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                          right: 17.0), // Adjust padding as needed
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          icon,
                          fit: BoxFit
                              .contain, // Ensures the image scales properly
                        ),
                      ),
                    ),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: controller2,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    color: AppTheme
                        .lightTextColorDark, // Ensure text is the right color
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText2,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: AppTheme.lightTextColorDark.withOpacity(0.7),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 18,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                        right: 17.0,
                      ), // Adjust padding as needed
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          icon,
                          fit: BoxFit
                              .contain, // Ensures the image scales properly
                        ),
                      ),
                    ),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
