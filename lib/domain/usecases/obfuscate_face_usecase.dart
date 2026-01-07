import 'dart:typed_data';
import 'package:nuyna/domain/entities/face_region.dart';
import 'package:nuyna/data/datasources/facial_obfuscator_service.dart';
import 'package:nuyna/data/datasources/ml_kit_datasource.dart';
import 'dart:ui' as ui;

/// Use case for applying advanced facial obfuscation.
///
/// This use case implements a multi-layered defense mechanism:
/// - Layer 1: Inject subtle adversarial noise into facial region
/// - Layer 2: Apply minute geometric displacements to facial landmarks
/// - Layer 3: Remove high-frequency components via smoothing
class ObfuscateFaceUseCase {
  final FacialObfuscatorService _obfuscatorService;
  final MlKitDataSource _mlKitDataSource;

  /// Creates a new [ObfuscateFaceUseCase] instance.
  ObfuscateFaceUseCase(this._obfuscatorService, this._mlKitDataSource);

  /// Executes advanced facial obfuscation on an image with internal face detection.
  ///
  /// [imageBytes] - The raw image data.
  /// [width] - Image width in pixels.
  /// [height] - Image height in pixels.
  ///
  /// Returns the processed image bytes with faces obfuscated.
  Future<Uint8List> executeWithDetection({
    required Uint8List imageBytes,
    required int width,
    required int height,
  }) async {
    // Detect faces using ML Kit
    final faces = await _mlKitDataSource.detectFacesFromBytes(
      imageBytes,
      width,
      height,
    );

    // If no faces detected, return original image
    if (faces.isEmpty) {
      return imageBytes;
    }

    // Convert ML Kit faces to FaceRegion
    final faceRegions = faces.map((face) {
      final boundingBox = face.boundingBox;
      return FaceRegion(
        boundingBox: ui.Rect.fromLTWH(
          boundingBox.left / width,
          boundingBox.top / height,
          boundingBox.width / width,
          boundingBox.height / height,
        ),
        landmarks: _extractLandmarks(face, width, height),
        confidence: 0.9, // ML Kit doesn't provide confidence, assume high
      );
    }).toList();

    // Process with detected faces
    return execute(
      imageBytes: imageBytes,
      width: width,
      height: height,
      faceRegions: faceRegions,
    );
  }

  /// Extracts landmark offsets from ML Kit Face
  List<ui.Offset> _extractLandmarks(dynamic face, int width, int height) {
    final landmarks = <ui.Offset>[];
    
    // Try to extract key landmarks (eyes, nose, mouth)
    try {
      final leftEye = face.getLandmark(0); // FaceLandmarkType.leftEye
      final rightEye = face.getLandmark(1); // FaceLandmarkType.rightEye
      final nose = face.getLandmark(2); // FaceLandmarkType.noseBase
      
      if (leftEye != null) {
        landmarks.add(ui.Offset(
          leftEye.position.x / width,
          leftEye.position.y / height,
        ));
      }
      if (rightEye != null) {
        landmarks.add(ui.Offset(
          rightEye.position.x / width,
          rightEye.position.y / height,
        ));
      }
      if (nose != null) {
        landmarks.add(ui.Offset(
          nose.position.x / width,
          nose.position.y / height,
        ));
      }
    } catch (e) {
      // If landmark extraction fails, return empty list
    }
    
    return landmarks;
  }

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
