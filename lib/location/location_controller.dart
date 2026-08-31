import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'location_service.dart';

class LocationController extends GetxController {

  final isTracking = false.obs;

  Future<void> startLocation() async {

    // Check GPS
    final serviceEnabled =
    await Geolocator
        .isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator
          .openLocationSettings();

      return;
    }

    // Permission
    var permission =
    await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
      await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {

      Get.snackbar(
        'Location',
        'Location permission required',
      );

      return;
    }

    // Start background service
    await LocationService.start();

    isTracking.value = true;
  }

  Future<void> stopLocation() async {

    await LocationService.stop();

    isTracking.value = false;
  }
}