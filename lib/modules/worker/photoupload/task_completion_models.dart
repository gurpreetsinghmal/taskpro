class UploadedPhotoModel {
  final String id;
  final String imageUrl;
  final String timestamp;
  final String gpsLocation;
  final String caption;

  UploadedPhotoModel({
    required this.id,
    required this.imageUrl,
    required this.timestamp,
    required this.gpsLocation,
    this.caption = '',
  });
}

class VerificationCheckItem {
  final String title;
  bool isChecked;

  VerificationCheckItem({
    required this.title,
    this.isChecked = false,
  });
}
