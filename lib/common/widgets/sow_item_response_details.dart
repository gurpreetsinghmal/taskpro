import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/work_order_model.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class SowItemResponseDetails extends StatelessWidget {
  const SowItemResponseDetails({required this.item, super.key});

  final SowItemModel item;

  @override
  Widget build(BuildContext context) {
    final remarks = item.notes.trim();
    if (remarks.isEmpty && item.attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (remarks.isNotEmpty) ...[
            const Text(
              'Notes',
              style: TextStyle(
                color: Color(0xFF5E6C84),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              remarks,
              style: const TextStyle(
                color: Color(0xFF344563),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
          if (item.attachments.isNotEmpty) ...[
            if (remarks.isNotEmpty) const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final attachment in item.attachments)
                  _EvidenceThumbnail(attachment: attachment),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Keep your existing SowAttachmentModel import.

enum _AttachmentType {
  image,
  pdf,
  word,
  excel,
  powerpoint,
  text,
  archive,
  other,
}

class _EvidenceThumbnail extends StatefulWidget {
  const _EvidenceThumbnail({required this.attachment});

  final SowAttachmentModel attachment;

  @override
  State<_EvidenceThumbnail> createState() => _EvidenceThumbnailState();
}

class _EvidenceThumbnailState extends State<_EvidenceThumbnail> {
  bool _isOpening = false;

  String get _fileName {
    final name = widget.attachment.originalName.trim();
    return name.isEmpty ? 'Attachment' : name;
  }

  String get _mimeType =>
      (widget.attachment.mimeType).toString().trim().toLowerCase();

  String get _path => widget.attachment.filePath.trim();

  bool get _isRemote {
    final uri = Uri.tryParse(_path);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }


  String get _extension {
    final name = _fileName.toLowerCase();
    final dot = name.lastIndexOf('.');

    if (dot >= 0 && dot < name.length - 1) {
      return name.substring(dot + 1);
    }

    final uri = Uri.tryParse(_path);
    final path = uri?.path ?? _path;
    final lastDot = path.lastIndexOf('.');

    if (lastDot >= 0 && lastDot < path.length - 1) {
      return path.substring(lastDot + 1).toLowerCase();
    }

    return '';
  }

  _AttachmentType get _type {
    final mime = _mimeType;
    final ext = _extension;

    if (mime.startsWith('image/') ||
        ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return _AttachmentType.image;
    }

    if (mime == 'application/pdf' || ext == 'pdf') {
      return _AttachmentType.pdf;
    }

    if (mime.contains('word') ||
        mime.contains('wordprocessingml') ||
        ['doc', 'docx', 'rtf'].contains(ext)) {
      return _AttachmentType.word;
    }

    if (mime.contains('excel') ||
        mime.contains('spreadsheetml') ||
        ['xls', 'xlsx', 'csv'].contains(ext)) {
      return _AttachmentType.excel;
    }

    if (mime.contains('powerpoint') ||
        mime.contains('presentationml') ||
        ['ppt', 'pptx'].contains(ext)) {
      return _AttachmentType.powerpoint;
    }

    if (mime.startsWith('text/') ||
        ['txt', 'json', 'xml', 'log'].contains(ext)) {
      return _AttachmentType.text;
    }

    if (mime.contains('zip') || ['zip', 'rar', '7z'].contains(ext)) {
      return _AttachmentType.archive;
    }

    return _AttachmentType.other;
  }

  Color get _color {
    switch (_type) {
      case _AttachmentType.image:
        return const Color(0xFF2563EB);
      case _AttachmentType.pdf:
        return const Color(0xFFDC2626);
      case _AttachmentType.word:
        return const Color(0xFF2563EB);
      case _AttachmentType.excel:
        return const Color(0xFF059669);
      case _AttachmentType.powerpoint:
        return const Color(0xFFEA580C);
      case _AttachmentType.text:
        return const Color(0xFF64748B);
      case _AttachmentType.archive:
        return const Color(0xFF9333EA);
      case _AttachmentType.other:
        return const Color(0xFF0891B2);
    }
  }

  IconData get _icon {

    switch (_type) {
      case _AttachmentType.image:
        return Icons.image_rounded;
      case _AttachmentType.pdf:
        return Icons.picture_as_pdf_rounded;
      case _AttachmentType.word:
        return Icons.description_rounded;
      case _AttachmentType.excel:
        return Icons.table_chart_rounded;
      case _AttachmentType.powerpoint:
        return Icons.slideshow_rounded;
      case _AttachmentType.text:
        return Icons.article_rounded;
      case _AttachmentType.archive:
        return Icons.folder_zip_rounded;
      case _AttachmentType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  String get _typeLabel {
    switch (_type) {
      case _AttachmentType.image:
        return 'IMAGE';
      case _AttachmentType.pdf:
        return 'PDF';
      case _AttachmentType.word:
        return 'WORD';
      case _AttachmentType.excel:
        return 'EXCEL';
      case _AttachmentType.powerpoint:
        return 'PPT';
      case _AttachmentType.text:
        return 'TEXT';
      case _AttachmentType.archive:
        return 'ZIP';
      case _AttachmentType.other:
        return _extension.isEmpty ? 'FILE' : _extension.toUpperCase();
    }
  }


  String get _effectiveMimeType {
    final ext = _extension.toLowerCase();

    const mimeMap = {
      'pdf': 'application/pdf',

      'xls': 'application/vnd.ms-excel',
      'xlsx':
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'csv': 'text/csv',

      'doc': 'application/msword',
      'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',

      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',

      'txt': 'text/plain',
      'zip': 'application/zip',
    };

    // Prefer a known file extension over generic API MIME types.
    if (mimeMap.containsKey(ext)) {
      return mimeMap[ext]!;
    }

    if (_mimeType.isNotEmpty &&
        _mimeType != 'application/octet-stream') {
      return _mimeType;
    }

    return 'application/octet-stream';
  }


  String get _sizeLabel {
    final bytes = widget.attachment.fileSize;

    if (bytes <= 0) return 'Unknown size';

    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }


  Uint8List? _decodeBase64(String value) {
    try {
      String encoded = value.trim();

      if (encoded.isEmpty) return null;

      // Remove data URI prefix.
      // Example: data:application/pdf;base64,JVBERi0...
      if (encoded.toLowerCase().startsWith('data:')) {
        final commaIndex = encoded.indexOf(',');

        if (commaIndex == -1) {
          throw const FormatException('Invalid data URI');
        }

        final header =
        encoded.substring(0, commaIndex).toLowerCase();

        if (!header.contains(';base64')) {
          throw const FormatException(
            'Data URI does not contain Base64 data',
          );
        }

        encoded = encoded.substring(commaIndex + 1);
      }

      // Remove whitespace and line breaks.
      encoded = encoded.replaceAll(RegExp(r'\s+'), '');

      // Support URL-safe Base64.
      encoded = encoded.replaceAll('-', '+').replaceAll('_', '/');

      // Normalize padding and decode.
      return base64Decode(base64.normalize(encoded));
    } catch (e) {
      debugPrint('Base64 decode failed: $e');
      return null;
    }
  }

  ImageProvider? _imageProvider() {
    if (_type != _AttachmentType.image) return null;

    if (_isRemote) {
      return NetworkImage(_path);
    }

    if (_path.startsWith('file://')) {
      final uri = Uri.tryParse(_path);
      if (uri != null) {
        return FileImage(File.fromUri(uri));
      }
    }

    if (File(_path).existsSync()) {
      return FileImage(File(_path));
    }

    final bytes = _decodeBase64(_path);
    return bytes == null ? null : MemoryImage(bytes);
  }



  String _extensionFromMime() {
    switch (_type) {
      case _AttachmentType.image:
        if (_mimeType.contains('png')) return 'png';
        if (_mimeType.contains('webp')) return 'webp';
        return 'jpg';
      case _AttachmentType.pdf:
        return 'pdf';
      case _AttachmentType.word:
        return 'docx';
      case _AttachmentType.excel:
        return 'xlsx';
      case _AttachmentType.powerpoint:
        return 'pptx';
      case _AttachmentType.text:
        return 'txt';
      case _AttachmentType.archive:
        return 'zip';
      case _AttachmentType.other:
        return 'bin';
    }
  }


  Future<File> _prepareFile() async {
    if (_path.isEmpty) {
      throw Exception('Attachment data is empty.');
    }

    // 1. Existing local file
    if (!_isRemote) {
      try {
        final localFile = _path.startsWith('file://')
            ? File.fromUri(Uri.parse(_path))
            : File(_path);

        if (await localFile.exists()) {
          return localFile;
        }
      } catch (_) {
        // Not a valid local file path; try Base64.
      }
    }

    // 2. Prepare application temporary directory
    final tempDir = await getTemporaryDirectory();

    final directory = Directory(
      '${tempDir.path}${Platform.pathSeparator}'
          'taskpro_attachments',
    );

    await directory.create(recursive: true);

    // 3. Determine correct extension
    final extension = _extension.isNotEmpty
        ? _extension
        : _extensionFromMime();

    final safeExtension = extension.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

    final fileName =
        'attachment_${DateTime.now().microsecondsSinceEpoch}'
        '.${safeExtension.isEmpty ? 'bin' : safeExtension}';

    final file = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );

    // 4. Download or decode
    if (_isRemote) {
      await Dio().download(
        _path,
        file.path,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
    } else {
      final bytes = _decodeBase64(_path);

      if (bytes == null || bytes.isEmpty) {
        throw const FormatException(
          'Unable to decode attachment Base64 data.',
        );
      }

      // PDF signature: %PDF-
      if (_type == _AttachmentType.pdf) {
        final validPdf = bytes.length >= 5 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46 &&
            bytes[4] == 0x2D;

        if (!validPdf) {
          throw const FormatException(
            'Decoded data is not a valid PDF header.',
          );
        }
      }

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      debugPrint('Attachment decoded successfully');
      debugPrint('File: ${file.path}');
      debugPrint('Bytes: ${bytes.length}');
      debugPrint('MIME: $_effectiveMimeType');
    }

    if (!await file.exists()) {
      throw Exception('Attachment file was not created.');
    }

    final fileLength = await file.length();

    if (fileLength == 0) {
      throw Exception('Attachment file is empty.');
    }

    debugPrint('Saved attachment: ${file.path}');
    debugPrint('Saved size: $fileLength bytes');

    return file;
  }


  Future<void> _openAttachment() async {
    if (_isOpening) return;

    if (_type == _AttachmentType.image) {
      final provider = _imageProvider();

      if (provider == null) {
        _showError('Unable to load this image.');
        return;
      }

      _showImagePreview(provider);
      return;
    }

    setState(() => _isOpening = true);

    try {
      final file = await _prepareFile();

      debugPrint('Opening file: ${file.path}');
      debugPrint('MIME type: $_effectiveMimeType');

      final result = await OpenFilex.open(
        file.path,
        type: _effectiveMimeType,
      );

      debugPrint('OpenFilex result: ${result.type}');
      debugPrint('OpenFilex message: ${result.message}');

      if (result.type != ResultType.done) {
        throw Exception(
          result.message.isEmpty
              ? 'No compatible application could open this file.'
              : result.message,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Attachment open error: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showError(
        'Could not open $_fileName. $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isOpening = false);
      }
    }
  }


  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImagePreview(ImageProvider provider) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .92),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: const Color(0xFF101827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.sizeOf(dialogContext).height * .72,
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 5,
                  child: Center(
                    child: Image(
                      image: provider,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 50,
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(50),
                  child: IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),

              Positioned(
                left: 14,
                bottom: 14,
                right: 14,
                child: Text(
                  _fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThumbnail() {
    final provider = _imageProvider();

    if (_type == _AttachmentType.image && provider != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image(
          image: provider,
          width: 150,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) {
            return _buildFileIcon();
          },
        ),
      );
    }

    return _buildFileIcon();
  }

  Widget _buildFileIcon() {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _color.withValues(alpha: .15)),
      ),
      child: Icon(_icon, size: 29, color: _color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isOpening ? null : _openAttachment,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _color.withValues(alpha: .15)),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: .06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildThumbnail(),

                  if (_isOpening)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 7),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  _typeLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _color,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF26344A),
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _sizeLabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF8290A3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

