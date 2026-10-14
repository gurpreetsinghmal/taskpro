enum SowImageStage {
  queued,
  reading,
  compressing,
  previewing,
  ready,
  skipped,
  failed,
}

class SowImageProgress {
  const SowImageProgress({
    required this.fileName,
    this.stage = SowImageStage.queued,
    this.message,
  });

  final String fileName;
  final SowImageStage stage;
  final String? message;

  bool get isFinished => switch (stage) {
    SowImageStage.ready ||
    SowImageStage.skipped ||
    SowImageStage.failed => true,
    _ => false,
  };

  // Progress counts completed preparation steps, not elapsed time or bytes sent.
  double get progress => switch (stage) {
    SowImageStage.queued || SowImageStage.reading => 0,
    SowImageStage.compressing => 1 / 3,
    SowImageStage.previewing => 2 / 3,
    SowImageStage.ready => 1,
    SowImageStage.skipped || SowImageStage.failed => 0,
  };

  String get label => switch (stage) {
    SowImageStage.queued => 'Waiting',
    SowImageStage.reading => 'Reading image',
    SowImageStage.compressing => 'Compressing',
    SowImageStage.previewing => 'Preparing preview',
    SowImageStage.ready => 'Ready',
    SowImageStage.skipped => message ?? 'Skipped',
    SowImageStage.failed => message ?? 'Unable to process image',
  };
}

class UploadedPhotoModel {
  final String id;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final String source;
  final String timestamp;
  final String caption;
  final String? image;

  const UploadedPhotoModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.source,
    required this.timestamp,
    this.caption = '',
    this.image,
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

  factory UploadedPhotoModel.fromJson(Map<String, dynamic> json) {
    return UploadedPhotoModel(
      id: json['id']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileSizeBytes: int.tryParse(json['file_size_bytes']?.toString() ?? '') ??
          0,
      source: json['source']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_path': filePath,
    'file_name': fileName,
    'file_size_bytes': fileSizeBytes,
    'source': source,
    'timestamp': timestamp,
    'caption': caption,
    'image': image,
  };
}

class VerificationCheckItem {
  final String title;
  bool isChecked;
  int quantity;
  int markFromTechnician;

  VerificationCheckItem({
    required this.title,
    this.isChecked = false,
    this.quantity = 1,
    this.markFromTechnician = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isChecked': isChecked,
      'quantity': quantity,
      'markFromTechnician': markFromTechnician,
    };
  }

  VerificationCheckItem copyWith({
    String? title,
    bool? isChecked,
    int? quantity,
    int? markFromTechnician,
  }) {
    return VerificationCheckItem(
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      quantity: quantity ?? this.quantity,
      markFromTechnician: markFromTechnician ?? this.markFromTechnician,
    );
  }
}
