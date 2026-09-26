import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/theme/app_colors.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required bool isDestructive, // true for Reject (Red), false for Accept (Green/Primary)
  IconData? icon,
}) async
{
  final theme = Theme.of(context);
  final primaryColor = isDestructive ? Colors.red : Colors.green;

  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Icon Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isDestructive ? Icons.close_rounded : Icons.check_rounded),
                color: primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.colorScheme.onSurface.let(
                    (color) => TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Message Body
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel / Go Back Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm / Accept / Reject Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
extension _LetColor<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

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
      borderRadius: BorderRadius.circular(30),
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
                backgroundColor: Colors.transparent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],)
    ),
  );
}