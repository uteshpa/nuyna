import 'dart:typed_data';
import 'package:nuyna/data/datasources/mediapipe_datasource.dart';
import 'package:nuyna/data/datasources/fingerprint_scrubber_service.dart';

/// Use case for detecting and obfuscating fingerprints in media.
///
/// This use case orchestrates the fingerprint protection workflow:
/// 1. Detect hand and finger landmarks using MediaPipe
/// 2. Isolate fingertip regions based on landmarks
/// 3. Apply selective smoothing to obscure ridge patterns
class ScrubFingerprintsUseCase {
  final MediaPipeDataSource _mediaPipeDataSource;
  final FingerprintScrubberService _scrubberService;

  /// Creates a new [ScrubFingerprintsUseCase] instance.
  ScrubFingerprintsUseCase(
    this._mediaPipeDataSource,
    this._scrubberService,
  );

  /// Executes fingerprint scrubbing on an image.
  ///
  /// [imageBytes] - The raw image data.
  /// [width] - Image width in pixels.
  /// [height] - Image height in pixels.
  ///
  /// Returns the processed image bytes with fingerprints obfuscated.
  Future<Uint8List> execute({
    required Uint8List imageBytes,
    required int width,
    required int height,
  }) async {
    // Step 1: Detect hand landmarks using MediaPipe
    final handLandmarks = await _mediaPipeDataSource.detectHandLandmarks(
      imageBytes,
      width,
      height,
    );

    // If no hands detected, return original image
    if (handLandmarks.isEmpty) {
      return imageBytes;
    }

    // Step 2: Extract fingertip regions from landmarks
    // MediaPipe hand landmarks: 4, 8, 12, 16, 20 are fingertip indices
    final fingertipIndices = [4, 8, 12, 16, 20];
    final fingertipRegions = <FingertipRegion>[];

    for (final hand in handLandmarks) {
      for (final tipIndex in fingertipIndices) {
        if (tipIndex < hand.landmarks.length) {
          final landmark = hand.landmarks[tipIndex];
          // Create a region around the fingertip
          // Radius is proportional to hand size
          final region = FingertipRegion(
            centerX: (landmark.x * width).toInt(),
            centerY: (landmark.y * height).toInt(),
            radius: (hand.handSize * 0.05 * width).toInt().clamp(10, 50),
          );
          fingertipRegions.add(region);
        }
      }
    }

    // If no fingertips found, return original
    if (fingertipRegions.isEmpty) {
      return imageBytes;
    }

    // Step 3: Apply smoothing to fingertip regions
    final processedBytes = await _scrubberService.applySmoothing(
      imageBytes: imageBytes,
      width: width,
      height: height,
      regions: fingertipRegions,
      smoothingStrength: 0.8,
    );

    return processedBytes;
  }
}

/// Represents a fingertip region to be processed.
class FingertipRegion {
  final int centerX;
  final int centerY;
  final int radius;

  FingertipRegion({
    required this.centerX,
    required this.centerY,
    required this.radius,
  });
}
