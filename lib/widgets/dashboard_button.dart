import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/theme.dart';


class DashboardButton extends StatelessWidget {
  final String text;
  final String prefixIcon;
  final String suffixIcon;
  final VoidCallback onPressed;
  const DashboardButton(
      {super.key,
      required this.text,
      required this.prefixIcon,
      required this.suffixIcon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.wp(300),
      height: AppSizes.hp(50),
      // padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppTheme.lightFieldsBgColor,
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(
              prefixIcon,
              width: 34,
              height: 34,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              text,
              style: TextStyle(
                  color: AppTheme.lightTextColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: onPressed,
              child: Image.asset(
                suffixIcon,
                width: 34,
                height: 34,
              ),
            ),
          )
        ],
      ),
    );
  }
}
