import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/network/api_service.dart';

class LocationService {
  static const String notificationChannelId = 'taskpro_location_channel';

  static const int notificationId = 888;

  // Send location every 10 minutes.
  static const Duration locationInterval = Duration(minutes: 10);

  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZE
  // ============================================================

  /// Call this ONCE from main()
  static Future<void> initialize() async {
    // ------------------------------------------------------------
    // Notification initialization
    // ------------------------------------------------------------

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await notifications.initialize(settings: initializationSettings);

    // ------------------------------------------------------------
    // Notification channel
    // ------------------------------------------------------------

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'TaskPro Location',
      description: 'Used for background location tracking',
      importance: Importance.low,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // ------------------------------------------------------------
    // Background service
    // ------------------------------------------------------------

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,

        // IMPORTANT:
        // Run as Android foreground service.
        isForegroundMode: true,

        // Do not start automatically when configure() is called.
        autoStart: false,

        // Restart service after Android device reboot.
        autoStartOnBoot: true,

        notificationChannelId: notificationChannelId,

        initialNotificationTitle: 'TaskPro Location',

        initialNotificationContent: 'Location tracking is active',

        foregroundServiceNotificationId: notificationId,
      ),

      iosConfiguration: IosConfiguration(
        autoStart: false,

        onForeground: onStart,

        onBackground: onIosBackground,
      ),
    );
  }

  // ============================================================
  // START SERVICE
  // ============================================================

  static Future<void> start() async {
    final service = FlutterBackgroundService();

    try {
      final running = await service.isRunning();

      if (running) {
        print('Location service already running');
        return;
      }

      // ----------------------------------------------------------
      // Check GPS
      // ----------------------------------------------------------

      final gpsEnabled = await Geolocator.isLocationServiceEnabled();

      if (!gpsEnabled) {
        print('GPS is OFF');

        await Geolocator.openLocationSettings();

        return;
      }

      // ----------------------------------------------------------
      // Check permission
      // ----------------------------------------------------------

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied');
        return;
      }

      // ----------------------------------------------------------
      // Android background location permission
      // ----------------------------------------------------------

      if (permission == LocationPermission.whileInUse) {
        print('WARNING: Background location permission is not granted.');

        // The user should select:
        // "Allow all the time"
        //
        // Do not automatically open settings here because
        // this can create a poor user experience.
      }

      // ----------------------------------------------------------
      // Start foreground service
      // ----------------------------------------------------------

      await service.startService();

      print('Location service started');
    } catch (e, stackTrace) {
      print('Unable to start location service: $e');
      print(stackTrace);
    }
  }

  // ============================================================
  // STOP SERVICE
  // ============================================================

  static Future<void> stop() async {
    final service = FlutterBackgroundService();

    try {
      final running = await service.isRunning();

      if (!running) {
        print('Location service is already stopped');
        return;
      }

      service.invoke('stopService');

      print('Location service stop requested');
    } catch (e) {
      print('Unable to stop location service: $e');
    }
  }

  // ============================================================
  // SERVICE STATUS
  // ============================================================

  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();

    return await service.isRunning();
  }
}

// =================================================================
// BACKGROUND SERVICE
// =================================================================

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // IMPORTANT:
  // Required when using plugins from a background isolate.
  DartPluginRegistrant.ensureInitialized();

  print('========================================');
  print('TaskPro Location Service Started');
  print('========================================');

  // ---------------------------------------------------------------
  // Android foreground service
  // ---------------------------------------------------------------

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    service.setForegroundNotificationInfo(
      title: 'TaskPro Location',
      content: 'Location tracking is active',
    );
  }

  // ---------------------------------------------------------------
  // Stop command
  // ---------------------------------------------------------------

  service.on('stopService').listen((event) {
    print('Stopping TaskPro Location Service');

    service.stopSelf();
  });

  // ---------------------------------------------------------------
  // Send location immediately
  // ---------------------------------------------------------------

  await sendLocation();

  // ---------------------------------------------------------------
  // Periodic location
  // ---------------------------------------------------------------

  Timer.periodic(LocationService.locationInterval, (timer) async {
    try {
      // Make sure service has not been stopped.
      if (service is AndroidServiceInstance) {
        final isForeground = await service.isForegroundService();

        if (!isForeground) {
          print(
            'Service is no longer foreground. '
            'Skipping location update.',
          );

          return;
        }
      }

      await sendLocation();
    } catch (e) {
      print('Periodic location error: $e');
    }
  });
}

// =================================================================
// GET LOCATION + API
// =================================================================

@pragma('vm:entry-point')
Future<void> sendLocation() async {
  try {
    // -------------------------------------------------------------
    // Check GPS
    // -------------------------------------------------------------

    final gpsEnabled = await Geolocator.isLocationServiceEnabled();

    if (!gpsEnabled) {
      print('GPS is OFF');
      return;
    }

    // -------------------------------------------------------------
    // Check permission
    // -------------------------------------------------------------

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Location permission is not available');
      return;
    }

    // -------------------------------------------------------------
    // Get current location
    // -------------------------------------------------------------

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final latitude = position.latitude;
    final longitude = position.longitude;

    final now = DateTime.now().toUtc().toIso8601String();

    print('----------------------------------------');
    print('TaskPro Location');
    print('Latitude  : $latitude');
    print('Longitude : $longitude');
    print('Global DateTime  : $now');
    print(
      'Local time  : ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.parse(now).toLocal())}',
    );
    print('----------------------------------------');

    // -------------------------------------------------------------
    // API
    // -------------------------------------------------------------

    final apiService = ApiService();

    final response = await apiService.post(
      ApiRoutes.locationMonitoring,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'datetime': DateTime.now().toUtc().toIso8601String(),
      },
    );

    print('Location API response: ${response.statusCode}');
  } catch (e, stackTrace) {
    print('Location error: $e');
    print(stackTrace);
  }
}

// =================================================================
// iOS
// =================================================================

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  return true;
}
