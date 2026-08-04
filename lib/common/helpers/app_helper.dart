import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/theme/app_colors.dart';

findButton({
  required String title,
  VoidCallback? onPressed,
  Color? backgroundColor,
  Color? textColor,
  Icon? icon,
}) {
  final colorScheme = Get.theme.colorScheme;
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(20),
    ),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed ?? () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon??SizedBox(),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor ?? colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],)
    ),
  );
}