import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/location/location_controller.dart';
class LocationScreen
    extends StatelessWidget {

  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.find<LocationController>();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Location Tracking',
        ),
      ),

      body: Center(

        child: Obx(
              () =>
              Column(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Text(
                    controller.isTracking.value
                        ? 'Location Tracking ON'
                        : 'Location Tracking OFF',
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      controller
                          .startLocation();
                    },

                    child: const Text(
                      'START',
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      controller
                          .stopLocation();
                    },

                    child: const Text(
                      'STOP',
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}