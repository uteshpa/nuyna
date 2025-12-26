import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:nuyna/core/errors/failures.dart';
import 'package:nuyna/data/datasources/ml_kit_datasource.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';
import 'package:nuyna/domain/entities/face_detection_result.dart';
import 'package:nuyna/domain/entities/face_region.dart';
import 'package:nuyna/domain/repositories/face_detection_repository.dart';

/// Implementation of [FaceDetectionRepository] using ML Kit.
///
/// Converts ML Kit [Face] objects to domain [FaceRegion] entities,
/// extracting biometric landmarks for precision blurring.
class FaceDetectionRepositoryImpl implements FaceDetectionRepository {
  /// The ML Kit data source for face detection.
  final MlKitDataSource mlKitDataSource;

  /// The storage data source for temporary file operations.
  final StorageDataSource storageDataSource;

  /// Creates a new [FaceDetectionRepositoryImpl] instance.
  FaceDetectionRepositoryImpl({
    required this.mlKitDataSource,
    required this.storageDataSource,
  });

  @override
  Future<FaceDetectionResult> detectFaces(List<int> imageBytes) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Save bytes to a temporary file for ML Kit processing
      final tempDir = await storageDataSource.getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp_frame_${DateTime.now().millisecondsSinceEpoch}.png';
      await storageDataSource.saveFile(tempPath, imageBytes);

      try {
        // Detect faces using ML Kit
        final faces = await mlKitDataSource.detectFacesFromImage(tempPath);

        // Convert ML Kit faces to domain entities
        final faceRegions = faces.map(_convertToFaceRegion).toList();

        // Calculate overall confidence
        final overallConfidence = faceRegions.isEmpty
            ? 0.0
            : faceRegions.map((r) => r.confidence).reduce((a, b) => a + b) /
                  faceRegions.length;

        stopwatch.stop();

        return FaceDetectionResult(
          faces: faceRegions,
          confidence: overallConfidence,
          processingTime: stopwatch.elapsed,
        );
      } finally {
        // Clean up temporary file
        await storageDataSource.deleteFile(tempPath);
      }
    } catch (e) {
      stopwatch.stop();
      throw FaceDetectionFailure('Face detection failed: $e');
    }
  }

  /// Converts an ML Kit [Face] to a domain [FaceRegion].
  ///
  /// Extracts biometric landmarks (eyes, nose, mouth) for precision blurring.
  FaceRegion _convertToFaceRegion(Face face) {
    final landmarks = <Offset>[];

    // Extract biometric landmarks for precision blurring
    // Eyes
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.leftEye]);
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.rightEye]);

    // Nose
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.noseBase]);

    // Mouth
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.leftMouth]);
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.rightMouth]);
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.bottomMouth]);

    // Ears (optional for additional coverage)
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.leftEar]);
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.rightEar]);

    // Cheeks (optional for additional coverage)
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.leftCheek]);
    _addLandmark(landmarks, face.landmarks[FaceLandmarkType.rightCheek]);

    // Convert bounding box
    final boundingBox = Rect.fromLTRB(
      face.boundingBox.left.toDouble(),
      face.boundingBox.top.toDouble(),
      face.boundingBox.right.toDouble(),
      face.boundingBox.bottom.toDouble(),
    );

    // Use tracking ID confidence or default to high confidence
    final confidence = face.trackingId != null ? 0.95 : 0.85;

    return FaceRegion(
      boundingBox: boundingBox,
      landmarks: landmarks,
      confidence: confidence,
    );
  }

  /// Adds a landmark point to the list if it exists.
  void _addLandmark(List<Offset> landmarks, FaceLandmark? landmark) {
    if (landmark != null) {
      landmarks.add(Offset(
        landmark.position.x.toDouble(),
        landmark.position.y.toDouble(),
      ));
    }
  }

  /// Disposes of resources.
  void dispose() {
    mlKitDataSource.dispose();
  }
}
