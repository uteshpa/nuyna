import 'face_region.dart';

/// Face detection result entity.
///
/// This entity represents the result of a face detection operation,
/// containing detected faces, overall confidence, and processing time.
class FaceDetectionResult {
  /// List of detected face regions.
  final List<FaceRegion> faces;

  /// Overall detection confidence score.
  final double confidence;

  /// Time taken to process the detection.
  final Duration processingTime;

  /// Creates a new [FaceDetectionResult] instance.
  ///
  /// All parameters are required:
  /// - [faces]: List of detected face regions
  /// - [confidence]: Overall detection confidence
  /// - [processingTime]: Duration of the detection process
  FaceDetectionResult({
    required this.faces,
    required this.confidence,
    required this.processingTime,
  });
}
