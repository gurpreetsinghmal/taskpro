import 'package:url_launcher/url_launcher.dart';

class MapService {
  static Future<void> openUrl(String address) async {
    final uri = Uri.parse(address);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openCoordinates(double latitude, double longitude) =>
      openUrl(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
}
