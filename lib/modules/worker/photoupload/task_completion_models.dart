class UploadedPhotoModel {
  final String id;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final String source;
  final String timestamp;
  final String caption;

  const UploadedPhotoModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.source,
    required this.timestamp,
    this.caption = '',
  });

  String get readableFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    }

    final kilobytes = fileSizeBytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(1)} KB';
    }

    final megabytes = kilobytes / 1024;
    return '${megabytes.toStringAsFixed(1)} MB';
  }
}

class VerificationCheckItem {
  final String title;
  bool isChecked;

  VerificationCheckItem({
    required this.title,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isChecked': isChecked,
    };
  }
}

