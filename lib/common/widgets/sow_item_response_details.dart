import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/work_order_model.dart';

class SowItemResponseDetails extends StatelessWidget {
  const SowItemResponseDetails({required this.item, super.key});

  final SowItemModel item;

  @override
  Widget build(BuildContext context) {
    final remarks = item.remarks.trim();
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
              'Remarks',
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
            const Text(
              'Evidence',
              style: TextStyle(
                color: Color(0xFF5E6C84),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 7,
              runSpacing: 7,
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

class _EvidenceThumbnail extends StatelessWidget {
  const _EvidenceThumbnail({required this.attachment});

  final SowAttachmentModel attachment;

  ImageProvider<Object>? get _imageProvider {
    final path = attachment.filePath;
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(path);
    }

    final dataSeparator = path.startsWith('data:') ? path.indexOf(',') : -1;
    final encoded = dataSeparator >= 0
        ? path.substring(dataSeparator + 1)
        : path;
    try {
      return MemoryImage(base64Decode(encoded));
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageProvider;
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: imageProvider == null
                ? null
                : () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => Dialog(
                      backgroundColor: Colors.black,
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const SizedBox(
                                height: 280,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: imageProvider == null
                  ? const SizedBox(
                      width: 72,
                      height: 58,
                      child: ColoredBox(
                        color: Color(0xFFE8EDF4),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF7A869A),
                          size: 20,
                        ),
                      ),
                    )
                  : Image(
                      image: imageProvider,
                      width: 72,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 72,
                        height: 58,
                        child: ColoredBox(
                          color: Color(0xFFE8EDF4),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF7A869A),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          if (attachment.originalName.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              attachment.originalName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF7A869A), fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }
}
