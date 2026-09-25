import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:taskpro/location/location_service.dart';
import 'package:taskpro/modules/login/login_screen.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../common/models/work_order_model.dart';

class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(),
  );



  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<void> loggedOut()async{
    _storage.deleteAll();
    Get.snackbar(
      "Logged Out",
      "Successfully logged out.",
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    await LocationService.stop();
    Get.offAll(() => LoginScreen());
  }

  Future<bool> isLoggedIn() async {
    final token = await read(StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }
  Future<String?> getAccessToken() async{
    final token = await read(StorageKeys.accessToken);
    return token;
  }

  Future<List<WorkOrderModel>?> getWorkOrderList() async {
    final workOrderList = await read(StorageKeys.workOrderList);
    if (workOrderList == null) {
      return null;
    }
    final List<WorkOrderModel> list = (jsonDecode(workOrderList) as List)
        .map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return list;
  }




  Future<void> updateWorkOrderData(WorkOrderModel updatedWorkOrder) async {
    final workOrderList = await read(StorageKeys.workOrderList);

    if (workOrderList == null) {
      return;
    }

    final List<WorkOrderModel> list = (jsonDecode(workOrderList) as List)
        .map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final index = list.indexWhere(
          (item) => item.id == updatedWorkOrder.id,
    );

    if (index == -1) {
      return;
    }

    list[index] = updatedWorkOrder;

    await write(StorageKeys.workOrderList, jsonEncode(
      list.map((item) => item.toJson())
          .toList(),
    ));
  }

}

