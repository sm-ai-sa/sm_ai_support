import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_helper.dart';

/// Manages device ID generation, storage, and retrieval for anonymous user tracking.
///
/// This singleton class ensures a unique device ID is generated once per app installation
/// and persists across app launches. The device ID is included in all API requests and
/// Socket.IO connections for user tracking purposes.
///
/// Storage Strategy:
/// - Primary: Flutter Secure Storage (iOS Keychain / Android Keystore)
/// - Fallback: SharedPreferences (if secure storage fails)
///
/// The device ID is only generated once and persists for the lifetime of the app installation.
class DeviceIdManager {
  // Singleton pattern
  static final DeviceIdManager _instance = DeviceIdManager._internal();
  factory DeviceIdManager() => _instance;
  static DeviceIdManager get instance => _instance;
  DeviceIdManager._internal();

  // Storage keys
  static const String _secureStorageKey = 'sm_support_device_id';
  static const String _sharedPrefsKey = 'sm_support_device_id_fallback';
  static const String _storageTypeKey = 'sm_support_device_id_storage_type';

  // Internal state
  String? _deviceId;
  bool _initialized = false;
  bool _usingSecureStorage = true;

  /// UUID generator instance
  final Uuid _uuid = const Uuid();

  /// Initializes the DeviceIdManager and loads/generates the device ID.
  ///
  /// This method should be called once during app startup, before any API calls.
  /// It will:
  /// 1. Try to load existing device ID from secure storage
  /// 2. If not found, try fallback storage (SharedPreferences)
  /// 3. If still not found, generate a new UUID v4 and store it
  ///
  /// Returns the device ID after initialization.
  Future<String> initialize() async {
    if (_initialized && _deviceId != null) {
      return _deviceId!;
    }

    try {
      // Try to load from secure storage first
      _deviceId = await _loadFromSecureStorage();

      if (_deviceId != null && _deviceId!.isNotEmpty) {
        _usingSecureStorage = true;
        _initialized = true;
        return _deviceId!;
      }

      // Fallback to SharedPreferences
      _deviceId = await _loadFromSharedPreferences();

      if (_deviceId != null && _deviceId!.isNotEmpty) {
        _usingSecureStorage = false;
        _initialized = true;

        // Try to migrate to secure storage
        await _migrateToSecureStorage(_deviceId!);
        return _deviceId!;
      }

      // No existing device ID found - generate new one
      _deviceId = await _generateAndStore();
      _initialized = true;
      return _deviceId!;
    } catch (e) {
      // Last resort - generate device ID without persistence
      _deviceId = _uuid.v4();
      _initialized = true;
      return _deviceId!;
    }
  }

  /// Loads device ID from secure storage.
  Future<String?> _loadFromSecureStorage() async {
    try {
      final deviceId = await SecureStorageHelper.getSecureValue(_secureStorageKey);
      if (deviceId != null && deviceId.isNotEmpty) {
        return deviceId;
      }
    } catch (e) {
      // Secure storage failed, will try SharedPreferences
    }
    return null;
  }

  /// Loads device ID from SharedPreferences (fallback).
  Future<String?> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(_sharedPrefsKey);
      if (deviceId != null && deviceId.isNotEmpty) {
        return deviceId;
      }
    } catch (e) {
      // SharedPreferences failed
    }
    return null;
  }

  /// Generates a new UUID v4 and stores it in both secure storage and SharedPreferences.
  Future<String> _generateAndStore() async {
    final deviceId = _uuid.v4();

    // Try to store in secure storage first
    bool secureStorageSuccess = false;
    try {
      await SecureStorageHelper.setSecureValue(_secureStorageKey, deviceId);
      secureStorageSuccess = true;
      _usingSecureStorage = true;
    } catch (e) {
      // Secure storage failed, will use SharedPreferences
      _usingSecureStorage = false;
    }

    // Always store in SharedPreferences as backup
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sharedPrefsKey, deviceId);
      await prefs.setString(_storageTypeKey, secureStorageSuccess ? 'secure' : 'shared_prefs');
    } catch (e) {
      // Even SharedPreferences failed - not ideal but device ID is still in memory
    }

    return deviceId;
  }

  /// Migrates device ID from SharedPreferences to secure storage.
  Future<void> _migrateToSecureStorage(String deviceId) async {
    try {
      await SecureStorageHelper.setSecureValue(_secureStorageKey, deviceId);
      _usingSecureStorage = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageTypeKey, 'secure');
    } catch (e) {
      // Migration failed - will keep using SharedPreferences
    }
  }

  /// Returns the device ID asynchronously.
  ///
  /// If the manager is not initialized, it will initialize first.
  /// This ensures device ID is always available.
  Future<String> getDeviceId() async {
    if (!_initialized || _deviceId == null) {
      return await initialize();
    }
    return _deviceId!;
  }

  /// Returns the device ID synchronously.
  ///
  /// Returns null if the manager hasn't been initialized yet.
  /// Use this for scenarios where you need immediate access and have already
  /// called initialize() during app startup.
  String? getDeviceIdSync() {
    return _deviceId;
  }

  /// Checks if the DeviceIdManager has been initialized.
  bool isInitialized() {
    return _initialized;
  }

  /// Checks if secure storage is being used (vs SharedPreferences fallback).
  ///
  /// Returns true if device ID is stored in Flutter Secure Storage,
  /// false if using SharedPreferences fallback.
  Future<bool> isUsingSecureStorage() async {
    if (!_initialized) {
      await initialize();
    }
    return _usingSecureStorage;
  }

  /// Clears the device ID from storage and memory.
  ///
  /// ⚠️ FOR TESTING ONLY ⚠️
  /// This will delete the device ID from all storage locations.
  /// Next API call will generate a new device ID.
  Future<void> clear() async {
    try {
      await SecureStorageHelper.deleteSecureValue(_secureStorageKey);
    } catch (e) {
      // Ignore
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sharedPrefsKey);
      await prefs.remove(_storageTypeKey);
    } catch (e) {
      // Ignore
    }

    _deviceId = null;
    _initialized = false;
    _usingSecureStorage = true;
  }

  /// Regenerates the device ID and stores it.
  ///
  /// ⚠️ FOR TESTING ONLY ⚠️
  /// This will generate a new UUID v4 and replace the existing device ID.
  /// Use this only for testing purposes.
  ///
  /// Returns the new device ID.
  Future<String> regenerate() async {
    await clear();
    return await initialize();
  }

  /// Gets storage type information for debugging.
  ///
  /// Returns a map with storage details:
  /// - initialized: bool
  /// - hasDeviceId: bool
  /// - usingSecureStorage: bool
  /// - deviceIdLength: int (for verification without exposing full ID)
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _initialized,
      'hasDeviceId': _deviceId != null,
      'usingSecureStorage': _usingSecureStorage,
      'deviceIdLength': _deviceId?.length ?? 0,
      'deviceIdPrefix': _deviceId != null && _deviceId!.length >= 8 ? _deviceId!.substring(0, 8) : null,
    };
  }
}
