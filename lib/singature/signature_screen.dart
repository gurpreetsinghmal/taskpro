import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:taskpro/theme/app_colors.dart';

import 'dart:ui' as ui;


class SignatureScreen extends StatefulWidget {
  const SignatureScreen({
    super.key,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SfSignaturePadState> _signatureKey =
  GlobalKey<SfSignaturePadState>();

  bool _isSaving = false;

  Future<void> _saveSignature() async {
    try {
      setState(() {
        _isSaving = true;
      });

      final image = await _signatureKey.currentState?.toImage();

      if (image == null) {
        _showError(
          'Please provide a signature first.',
        );
        return;
      }

      // Convert Flutter Image to PNG bytes.
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        _showError(
          'Unable to generate signature image.',
        );
        return;
      }

      final Uint8List imageBytes =
      byteData.buffer.asUint8List();

      // Convert PNG bytes to Base64.
      final String base64Signature =
      base64Encode(imageBytes);

      // Return Base64 to previous screen.
      Get.back(
        result: base64Signature,
      );
    } catch (e) {
      debugPrint(
        'Signature conversion error: $e',
      );

      _showError(
        'Unable to save signature. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  void _clearSignature() {
    _signatureKey.currentState?.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Signature Pad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
                Row(
                  children: [
                    Text(
                      'Technician Signature',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Spacer(),
                    TextButton.icon(
                      onPressed: _isSaving
                          ? null
                          : _clearSignature,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text('Clear',style: TextStyle(color: Colors.red),),
                    ),
                  ],
                ),


              const SizedBox(height: 6),

              const Text(
                'Please sign inside the box below using your finger.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 20),

              AspectRatio(
                aspectRatio: 1.7,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SfSignaturePad(
                      key: _signatureKey,
                      backgroundColor:AppColors.textWhite,
                      strokeColor: AppColors.primary,
                      minimumStrokeWidth: 3,
                      maximumStrokeWidth: 5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),


              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed:
                  _isSaving
                      ? null
                      : _saveSignature,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF2563EB),
                    foregroundColor:
                    Colors.white,
                    disabledBackgroundColor:
                    Colors.blue.shade200,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.check_rounded,
                  ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : 'Save Signature',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
