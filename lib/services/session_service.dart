import '../location/location_service.dart';
import 'secure_storage_service.dart';

class SessionService {
  Future<void> clearSession() async {
    await LocationService.stop();
    await SecureStorageService.instance.deleteAll();
  }
}
