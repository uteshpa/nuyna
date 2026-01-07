import 'package:shared_preferences/shared_preferences.dart';

/// Data source for persisting user settings.
///
/// This data source uses SharedPreferences to store and retrieve
/// the state of privacy protection switches.
class SettingsDataSource {
  static const String _keyEnableFingerGuard = 'enable_finger_guard';
  static const String _keyEnableAdvancedFaceObfuscation = 'enable_advanced_face_obfuscation';
  static const String _keyEnableMetadataStrip = 'enable_metadata_strip';
  static const String _keyEnableFaceBlur = 'enable_face_blur';

  SharedPreferences? _prefs;

  /// Initialize the settings data source
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the Fingerprint Guard setting
  bool getEnableFingerGuard() {
    return _prefs?.getBool(_keyEnableFingerGuard) ?? false;
  }

  /// Set the Fingerprint Guard setting
  Future<void> setEnableFingerGuard(bool value) async {
    await _prefs?.setBool(_keyEnableFingerGuard, value);
  }

  /// Get the Advanced Face Obfuscation setting
  bool getEnableAdvancedFaceObfuscation() {
    return _prefs?.getBool(_keyEnableAdvancedFaceObfuscation) ?? false;
  }

  /// Set the Advanced Face Obfuscation setting
  Future<void> setEnableAdvancedFaceObfuscation(bool value) async {
    await _prefs?.setBool(_keyEnableAdvancedFaceObfuscation, value);
  }

  /// Get the Metadata Strip setting
  bool getEnableMetadataStrip() {
    return _prefs?.getBool(_keyEnableMetadataStrip) ?? true; // Default true
  }

  /// Set the Metadata Strip setting
  Future<void> setEnableMetadataStrip(bool value) async {
    await _prefs?.setBool(_keyEnableMetadataStrip, value);
  }

  /// Get the Face Blur setting
  bool getEnableFaceBlur() {
    return _prefs?.getBool(_keyEnableFaceBlur) ?? false;
  }

  /// Set the Face Blur setting
  Future<void> setEnableFaceBlur(bool value) async {
    await _prefs?.setBool(_keyEnableFaceBlur, value);
  }

  /// Load all settings into a map
  Map<String, bool> loadAllSettings() {
    return {
      'enableFingerGuard': getEnableFingerGuard(),
      'enableAdvancedFaceObfuscation': getEnableAdvancedFaceObfuscation(),
      'enableMetadataStrip': getEnableMetadataStrip(),
      'enableFaceBlur': getEnableFaceBlur(),
    };
  }
}
