import 'dart:ui';

/// Face region information entity.
///
/// This entity represents a detected face region with its bounding box,
/// facial landmarks, and detection confidence.
class FaceRegion {
  /// The bounding box of the detected face.
  final Rect boundingBox;

  /// List of facial landmarks as offset points.
  final List<Offset> landmarks;

  /// Detection confidence score.
  /// Valid range: 0.0 - 1.0
  final double confidence;

  /// Creates a new [FaceRegion] instance.
  ///
  /// All parameters are required:
  /// - [boundingBox]: The bounding rectangle of the face
  /// - [landmarks]: List of facial landmark points
  /// - [confidence]: Detection confidence (0.0 - 1.0)
  FaceRegion({
    required this.boundingBox,
    required this.landmarks,
    required this.confidence,
  });
}
