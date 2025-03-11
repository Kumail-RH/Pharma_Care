import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/theme.dart';


class DataInputField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final String? icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const DataInputField(
      {super.key,
      required this.labelText,
      this.hintText,
      this.controller,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.icon});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerWidth = screenWidth * (310 / screenWidth);
    double containerHeight = screenHeight * (75 / screenHeight);
    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 7.0),
            child: Text(
              labelText,
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
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color:
                  AppTheme.lightTextColorDark, // Ensure text is the right color
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
              fillColor: AppTheme.lightFieldsBgColor,
              suffixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 17.0,
                      ), // Adjust padding as needed
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          icon!,
                          fit: BoxFit
                              .contain, // Ensures the image scales properly
                        ),
                      ),
                    )
                  : null,
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 3,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
