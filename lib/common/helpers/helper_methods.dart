import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskpro/common/models/work_order_status.dart';
import 'package:taskpro/theme/app_colors.dart';
import 'package:intl/intl.dart';

class Common {
  static String formatToLocalUS(String? utcString) {
    if (utcString == null || utcString.trim().isEmpty) return '-';

    try {
      DateTime localTime = DateTime.parse(utcString).toLocal();
      return DateFormat('MM/dd/yyyy hh:mm a').format(localTime);
    } catch (e) {
      return '-';
    }
  }
  static String getStatusText(int? id, List<WorkOrderStatusModel> statusList) {
    if (id == null) return "-";
    for (var element in statusList) {
      if (element.id == id) {
        return element.name ?? "-";
      }
    }
    return "-";
  }

  static String getStatusColorName(
    int? id,
    List<WorkOrderStatusModel> statusList,
  ) {
    if (id == null) return "Blue";
    for (var element in statusList) {
      if (element.id == id) {
        return element.colour;
      }
    }
    return "Blue";
  }

  static Color getStatusColor(String colorName) {
    switch (colorName) {
      case "LightBlue":
        return AppColors.info;
      case "#ff8000":
        return AppColors.chartOrange;
      case "Red":
        return AppColors.error;
      case "Green":
        return AppColors.success;
      case "Orange":
        return AppColors.chartOrange;
      case "Blue":
        return AppColors.inProgress;
      case "Yellow":
        return AppColors.warning;
      case "Purple":
        return AppColors.chartPurple;
      default:
        return AppColors.textHint;
    }
  }

  static Color getStatusColorById(
    int? id,
    List<WorkOrderStatusModel> statusList,
  ) {
    String colorName = getStatusColorName(id, statusList);
    return getStatusColor(colorName);
  }

  static IconData getStatusIcon(String statusName) {
    switch (statusName) {
      case "New":
        return Icons.fiber_new;
      case "Accepted":
        return Icons.check;
      case "Assigned":
        return Icons.assignment_ind;
      case "In Progress":
        return Icons.timelapse;
      case "On Hold":
        return Icons.pause_circle;
      case "Completed":
        return Icons.check_circle;
      case "Cancelled":
        return Icons.cancel;
      case "Submitted":
        return Icons.send;
      default:
        return Icons.schedule;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
      case "urgent":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.green;
    }
  }
  static Future<void> printAllSecureStorage() async {
    const storage = FlutterSecureStorage();

    // Read all key-value pairs from secure storage
    Map<String, String> allValues = await storage.readAll();

    // Loop through the map to see each key and value
    allValues.forEach((key, value) {
      // if(key=="workOrderStatusesList")
      //   log(value);
      print('Key: $key');
    });
  }
}
