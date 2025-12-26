import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/domain/entities/face_region.dart';

void main() {
  group('FaceRegion', () {
    test('should create instance with required values', () {
      final boundingBox = const Rect.fromLTWH(10, 20, 100, 120);
      final landmarks = [
        const Offset(50, 60),
        const Offset(70, 60),
        const Offset(60, 80),
      ];
      const confidence = 0.95;

      final faceRegion = FaceRegion(
        boundingBox: boundingBox,
        landmarks: landmarks,
        confidence: confidence,
      );

      expect(faceRegion.boundingBox, boundingBox);
      expect(faceRegion.landmarks, landmarks);
      expect(faceRegion.confidence, confidence);
    });

    test('should handle empty landmarks list', () {
      final boundingBox = const Rect.fromLTWH(0, 0, 50, 50);
      final landmarks = <Offset>[];
      const confidence = 0.5;

      final faceRegion = FaceRegion(
        boundingBox: boundingBox,
        landmarks: landmarks,
        confidence: confidence,
      );

      expect(faceRegion.landmarks, isEmpty);
      expect(faceRegion.confidence, confidence);
    });

    test('should handle minimum confidence value', () {
      final faceRegion = FaceRegion(
        boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        landmarks: [],
        confidence: 0.0,
      );

      expect(faceRegion.confidence, 0.0);
    });

    test('should handle maximum confidence value', () {
      final faceRegion = FaceRegion(
        boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        landmarks: [],
        confidence: 1.0,
      );

      expect(faceRegion.confidence, 1.0);
    });

    test('should handle bounding box with zero dimensions', () {
      final faceRegion = FaceRegion(
        boundingBox: const Rect.fromLTWH(10, 10, 0, 0),
        landmarks: [],
        confidence: 0.5,
      );

      expect(faceRegion.boundingBox.width, 0);
      expect(faceRegion.boundingBox.height, 0);
    });

    test('should store multiple landmarks correctly', () {
      final landmarks = List.generate(
        68,
        (index) => Offset(index.toDouble(), index.toDouble() * 2),
      );

      final faceRegion = FaceRegion(
        boundingBox: const Rect.fromLTWH(0, 0, 200, 200),
        landmarks: landmarks,
        confidence: 0.99,
      );

      expect(faceRegion.landmarks.length, 68);
      expect(faceRegion.landmarks[0], const Offset(0, 0));
      expect(faceRegion.landmarks[67], const Offset(67, 134));
    });
  });
}
