import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared secure storage configuration to ensure consistency
/// across all services that use FlutterSecureStorage
class SecureStorageConfig {
  static const FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
}
