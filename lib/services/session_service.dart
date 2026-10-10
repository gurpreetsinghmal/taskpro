import 'dart:io';

import '../location/location_service.dart';
import '../common/models/sow_item_response_model.dart';
import 'secure_storage_service.dart';
import 'package:path_provider/path_provider.dart';

class SessionService {
  Future<void> clearSession() async {
    await LocationService.stop();
    final appDirectory = await getApplicationDocumentsDirectory();
    final evidenceDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}'
      '${SowItemResponseModel.evidenceDirectoryName}',
    );
    if (await evidenceDirectory.exists()) {
      await evidenceDirectory.delete(recursive: true);
    }
    await SecureStorageService.instance.deleteAll();
  }
}
