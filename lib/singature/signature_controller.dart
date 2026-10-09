import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SignatureController extends GetxController {
  final GlobalKey<SfSignaturePadState> signatureKey =
      GlobalKey<SfSignaturePadState>();

  final isSaving = false.obs;

  Future<void> saveSignature() async {
    try {
      isSaving.value = true;

      final image = await signatureKey.currentState?.toImage();

      if (image == null) {
        _showError('Please provide a signature first.');
        return;
      }

      // Convert Flutter Image to PNG bytes.
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        _showError('Unable to generate signature image.');
        return;
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Convert PNG bytes to Base64.
      final String base64Signature = base64Encode(imageBytes);

      image.dispose();
      if (isClosed) return;
      // Return Base64 to previous screen.
      Get.back(result: base64Signature);
    } catch (e) {
      debugPrint('Signature conversion error: $e');

      _showError('Unable to save signature. Please try again.');
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  void clearSignature() {
    signatureKey.currentState?.clear();
  }

  void _showError(String message) {
    Get.snackbar(
      'Signature Required',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
