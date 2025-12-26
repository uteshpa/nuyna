/// Application-wide constants.
///
/// This class contains all constant values used throughout the application,
/// including app metadata, face detection parameters, and processing settings.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  /// The application name.
  static const String appName = 'nuyna';

  /// The application version.
  static const String appVersion = '1.0.0';

  /// Minimum face size ratio for detection.
  static const double minFaceSize = 0.15;

  /// Default sensitivity for face detection.
  static const double defaultDetectionSensitivity = 0.7;

  /// Minimum blur strength value.
  static const double minBlurStrength = 10.0;

  /// Default blur strength value.
  static const double defaultBlurStrength = 15.0;

  /// Maximum blur strength value.
  static const double maxBlurStrength = 25.0;

  /// Maximum number of concurrent frames to process.
  static const int maxConcurrentFrames = 4;

  /// Timeout duration for processing operations.
  static const Duration processingTimeout = Duration(minutes: 10);
}
