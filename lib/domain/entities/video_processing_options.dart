/// Video processing settings entity.
///
/// This entity holds configuration options for video processing,
/// including face blur, iris block, finger guard, and metadata stripping.
class VideoProcessingOptions {
  /// Enable face blur processing.
  final bool enableFaceBlur;

  /// Enable iris block processing.
  final bool enableIrisBlock;

  /// Enable finger guard processing.
  final bool enableFingerGuard;

  /// Enable metadata stripping.
  final bool enableMetadataStrip;

  /// Blur strength value.
  /// Valid range: 10.0 - 25.0
  final double blurStrength;

  /// Detection sensitivity value.
  /// Valid range: 0.5 - 0.9
  final double detectionSensitivity;

  /// Creates a new [VideoProcessingOptions] instance.
  ///
  /// All parameters have default values:
  /// - [enableFaceBlur]: true
  /// - [enableIrisBlock]: false
  /// - [enableFingerGuard]: false
  /// - [enableMetadataStrip]: true
  /// - [blurStrength]: 15.0
  /// - [detectionSensitivity]: 0.7
  VideoProcessingOptions({
    this.enableFaceBlur = true,
    this.enableIrisBlock = false,
    this.enableFingerGuard = false,
    this.enableMetadataStrip = true,
    this.blurStrength = 15.0,
    this.detectionSensitivity = 0.7,
  });

  /// Creates a copy of this [VideoProcessingOptions] with the given fields
  /// replaced with new values.
  VideoProcessingOptions copyWith({
    bool? enableFaceBlur,
    bool? enableIrisBlock,
    bool? enableFingerGuard,
    bool? enableMetadataStrip,
    double? blurStrength,
    double? detectionSensitivity,
  }) {
    return VideoProcessingOptions(
      enableFaceBlur: enableFaceBlur ?? this.enableFaceBlur,
      enableIrisBlock: enableIrisBlock ?? this.enableIrisBlock,
      enableFingerGuard: enableFingerGuard ?? this.enableFingerGuard,
      enableMetadataStrip: enableMetadataStrip ?? this.enableMetadataStrip,
      blurStrength: blurStrength ?? this.blurStrength,
      detectionSensitivity: detectionSensitivity ?? this.detectionSensitivity,
    );
  }
}
