import 'package:flutter/material.dart';
import 'package:inventory_management_system/utility/constants.dart';
import 'package:inventory_management_system/utility/icon_assets.dart';
import 'package:inventory_management_system/utility/theme.dart';

class CustomAppbar extends StatelessWidget {
  final String text;
  final String? icon;
  const CustomAppbar({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                icon: Image.asset(
                  IconAssets.homeIcon,
                  width: AppSizes.wp(44),
                  height: AppSizes.wp(44),
                ),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => StaffManagement(),
                  //   ),
                  // );
                },
              ),
            ),
            Image.asset(
              IconAssets.logo,
              width: AppSizes.wp(159),
              height: AppSizes.wp(159),
            ),
          ],
        ),
        icon != null
            ? RichText(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTextColorDark,
            ),
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset(
                    icon!,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ],
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTextColorDark,
          ),
        ),
      ],
    );
  }
}
