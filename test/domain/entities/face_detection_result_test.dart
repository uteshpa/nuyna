import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/domain/entities/face_detection_result.dart';
import 'package:nuyna/domain/entities/face_region.dart';

void main() {
  group('FaceDetectionResult', () {
    late List<FaceRegion> testFaces;

    setUp(() {
      testFaces = [
        FaceRegion(
          boundingBox: const Rect.fromLTWH(10, 20, 100, 120),
          landmarks: [const Offset(50, 60)],
          confidence: 0.95,
        ),
        FaceRegion(
          boundingBox: const Rect.fromLTWH(200, 50, 80, 100),
          landmarks: [const Offset(240, 100)],
          confidence: 0.88,
        ),
      ];
    });

    test('should create instance with required values', () {
      final result = FaceDetectionResult(
        faces: testFaces,
        confidence: 0.91,
        processingTime: const Duration(milliseconds: 150),
      );

      expect(result.faces, testFaces);
      expect(result.faces.length, 2);
      expect(result.confidence, 0.91);
      expect(result.processingTime, const Duration(milliseconds: 150));
    });

    test('should handle empty faces list', () {
      final result = FaceDetectionResult(
        faces: [],
        confidence: 0.0,
        processingTime: const Duration(milliseconds: 50),
      );

      expect(result.faces, isEmpty);
      expect(result.confidence, 0.0);
    });

    test('should handle zero processing time', () {
      final result = FaceDetectionResult(
        faces: testFaces,
        confidence: 0.9,
        processingTime: Duration.zero,
      );

      expect(result.processingTime, Duration.zero);
    });

    test('should handle long processing time', () {
      final result = FaceDetectionResult(
        faces: testFaces,
        confidence: 0.9,
        processingTime: const Duration(minutes: 5),
      );

      expect(result.processingTime.inMinutes, 5);
    });

    test('should access individual faces correctly', () {
      final result = FaceDetectionResult(
        faces: testFaces,
        confidence: 0.9,
        processingTime: const Duration(milliseconds: 100),
      );

      expect(result.faces[0].confidence, 0.95);
      expect(result.faces[1].confidence, 0.88);
    });

    test('should handle single face', () {
      final singleFace = [testFaces[0]];

      final result = FaceDetectionResult(
        faces: singleFace,
        confidence: 0.95,
        processingTime: const Duration(milliseconds: 80),
      );

      expect(result.faces.length, 1);
      expect(result.faces[0].boundingBox.left, 10);
    });
  });
}
