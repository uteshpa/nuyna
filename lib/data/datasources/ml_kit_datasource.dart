import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Data source for ML Kit Face Detection operations.
///
/// This class provides access to Google's ML Kit Face Detection API
/// to detect faces and extract facial landmarks from images.
class MlKitDataSource {
  /// Face detector instance with accurate mode and landmarks enabled.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableContours: true,
    ),
  );

  /// Detects faces from an image file path.
  ///
  /// [imagePath] - The path to the image file.
  ///
  /// Returns a list of detected [Face] objects with landmark data.
  ///
  /// Throws an exception if the image cannot be processed.
  Future<List<Face>> detectFacesFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return await _faceDetector.processImage(inputImage);
  }

  /// Detects faces from image bytes.
  ///
  /// [imageBytes] - The raw image data as bytes.
  /// [width] - The width of the image.
  /// [height] - The height of the image.
  ///
  /// Returns a list of detected [Face] objects with landmark data.
  Future<List<Face>> detectFacesFromBytes(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    final inputImage = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: width * 4,
      ),
    );
    return await _faceDetector.processImage(inputImage);
  }

  /// Disposes of the face detector resources.
  ///
  /// Should be called when the data source is no longer needed.
  void dispose() {
    _faceDetector.close();
  }
}
