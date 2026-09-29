import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/theme/app_colors.dart';
class ConfirmationResult {
  final bool confirmed;
  final String? remarks;

  const ConfirmationResult({
    required this.confirmed,
    this.remarks,
  });
}
Future<ConfirmationResult?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required bool isDestructive,
  IconData? icon,
  bool requireRemarks = false,
}) async {
  final theme = Theme.of(context);

  final primaryColor =
  isDestructive ? AppColors.error : AppColors.success;

  final remarksController = TextEditingController();

  final result = await showDialog<ConfirmationResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.50),
    builder: (BuildContext dialogContext) {
      bool hasError = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            backgroundColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.fromLTRB(
              22,
              20,
              22,
              22,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ------------------------------------------------
                  // ICON
                  // ------------------------------------------------

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: .11),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ??
                          (isDestructive
                              ? Icons.close_rounded
                              : Icons.check_rounded),
                      color: primaryColor,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 17),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ------------------------------------------------
                  // MESSAGE
                  // ------------------------------------------------

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color:
                      theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  // ------------------------------------------------
                  // REMARKS
                  // ------------------------------------------------

                  if (requireRemarks) ...[
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 17,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            "Rejection Remarks",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: remarksController,
                      maxLines: 4,
                      minLines: 3,
                      textCapitalization:
                      TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                        "Enter reason for rejecting this work order...",
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F8FC),
                        contentPadding:
                        const EdgeInsets.all(13),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: hasError
                                ? primaryColor
                                : Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                        errorText: hasError
                            ? "Rejection remarks are required"
                            : null,
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // BUTTONS
                  // ------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext)
                                .pop(null);
                          },
                          style: OutlinedButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color:
                              theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final remarks =
                            remarksController.text.trim();

                            if (requireRemarks &&
                                remarks.isEmpty) {
                              setState(() {
                                hasError = true;
                              });
                              return;
                            }

                            Navigator.of(dialogContext).pop(
                              ConfirmationResult(
                                confirmed: true,
                                remarks:
                                remarks.isEmpty
                                    ? null
                                    : remarks,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                isDestructive
                                    ? Icons.block_rounded
                                    : Icons.check_rounded,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                confirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );


  return result;
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