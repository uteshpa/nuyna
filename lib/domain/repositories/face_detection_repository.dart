import '../entities/face_detection_result.dart';

/// Abstract repository interface for face detection operations.
///
/// Implementations of this repository should use ML Kit Face Detection
/// to detect faces, extract bounding boxes and landmarks, and calculate
/// confidence scores.
abstract class FaceDetectionRepository {
  /// Detects faces in the given image bytes.
  ///
  /// [imageBytes] - The raw image data as a list of bytes.
  ///
  /// Returns a [FaceDetectionResult] containing detected faces,
  /// confidence scores, and processing time.
  ///
  /// Throws [FaceDetectionFailure] if [imageBytes] is empty or
  /// if face detection fails.
  Future<FaceDetectionResult> detectFaces(List<int> imageBytes);
}
