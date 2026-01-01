import 'dart:typed_data';
import 'package:nuyna/domain/entities/face_region.dart';
import 'package:nuyna/data/datasources/facial_obfuscator_service.dart';

/// Use case for applying advanced facial obfuscation.
///
/// This use case implements a multi-layered defense mechanism:
/// - Layer 1: Inject subtle adversarial noise into facial region
/// - Layer 2: Apply minute geometric displacements to facial landmarks
/// - Layer 3: Remove high-frequency components via smoothing
class ObfuscateFaceUseCase {
  final FacialObfuscatorService _obfuscatorService;

  /// Creates a new [ObfuscateFaceUseCase] instance.
  ObfuscateFaceUseCase(this._obfuscatorService);

  /// Executes advanced facial obfuscation on an image.
  ///
  /// [imageBytes] - The raw image data.
  /// [width] - Image width in pixels.
  /// [height] - Image height in pixels.
  /// [faceRegions] - List of detected face regions to obfuscate.
  ///
  /// Returns the processed image bytes with faces obfuscated.
  Future<Uint8List> execute({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required List<FaceRegion> faceRegions,
  }) async {
    // If no faces detected, return original image
    if (faceRegions.isEmpty) {
      return imageBytes;
    }

    Uint8List processedBytes = imageBytes;

    for (final face in faceRegions) {
      // Convert FaceRegion bounds to pixel coordinates
      final faceRect = FaceRect(
        left: (face.boundingBox.left * width).toInt(),
        top: (face.boundingBox.top * height).toInt(),
        width: (face.boundingBox.width * width).toInt(),
        height: (face.boundingBox.height * height).toInt(),
      );

      // Layer 1: Apply adversarial noise
      processedBytes = await _obfuscatorService.applyAdversarialNoise(
        imageBytes: processedBytes,
        width: width,
        height: height,
        faceRect: faceRect,
        noiseIntensity: 0.03, // Subtle noise (3%)
      );

      // Layer 2: Apply landmark displacement
      processedBytes = await _obfuscatorService.applyLandmarkDisplacement(
        imageBytes: processedBytes,
        width: width,
        height: height,
        faceRect: faceRect,
        displacementStrength: 0.02, // 2% displacement
      );

      // Layer 3: Apply smoothing to remove high-frequency details
      processedBytes = await _obfuscatorService.applySmoothing(
        imageBytes: processedBytes,
        width: width,
        height: height,
        faceRect: faceRect,
        smoothingRadius: 3,
      );
    }

    return processedBytes;
  }
}

/// Represents a face rectangle in pixel coordinates.
class FaceRect {
  final int left;
  final int top;
  final int width;
  final int height;

  FaceRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  int get right => left + width;
  int get bottom => top + height;
}
