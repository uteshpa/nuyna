import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/data/datasources/mediapipe_datasource.dart';

void main() {
  group('MediaPipeDataSource', () {
    late MediaPipeDataSource dataSource;

    setUp(() {
      dataSource = MediaPipeDataSource();
    });

    tearDown(() {
      dataSource.close();
    });

    test('should initialize successfully', () async {
      await dataSource.initialize();
      // No exception means success
    });

    test('detectHandsFromImagePath should return empty list (placeholder)', () async {
      final result = await dataSource.detectHandsFromImagePath('/test/image.png');

      expect(result, isEmpty);
    });

    test('detectHandsFromBytes should return empty list (placeholder)', () async {
      final result = await dataSource.detectHandsFromBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        100,
        100,
      );

      expect(result, isEmpty);
    });

    test('convertToFaceRegions should convert hand results to FaceRegions', () {
      final hands = [
        HandDetectionResult(
          boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
          landmarks: [
            const HandLandmark(
              position: Offset(10, 10),
              type: HandLandmarkType.thumbTip,
              confidence: 0.9,
            ),
            const HandLandmark(
              position: Offset(20, 20),
              type: HandLandmarkType.indexFingerTip,
              confidence: 0.9,
            ),
            const HandLandmark(
              position: Offset(30, 30),
              type: HandLandmarkType.middleFingerTip,
              confidence: 0.9,
            ),
            const HandLandmark(
              position: Offset(40, 40),
              type: HandLandmarkType.ringFingerTip,
              confidence: 0.9,
            ),
            const HandLandmark(
              position: Offset(50, 50),
              type: HandLandmarkType.pinkyTip,
              confidence: 0.9,
            ),
          ],
          confidence: 0.95,
          handType: HandType.right,
        ),
      ];

      final regions = dataSource.convertToFaceRegions(hands);

      expect(regions, hasLength(1));
      expect(regions.first.landmarks, hasLength(5));
      expect(regions.first.confidence, 0.95);
    });

    test('convertToFaceRegions should handle empty hands list', () {
      final regions = dataSource.convertToFaceRegions([]);

      expect(regions, isEmpty);
    });

    test('close should work without error', () {
      dataSource.close();
      // No exception means success
    });
  });

  group('HandDetectionResult', () {
    test('getFingertipLandmarks should return only fingertip positions', () {
      final hand = HandDetectionResult(
        boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        landmarks: [
          const HandLandmark(
            position: Offset(0, 0),
            type: HandLandmarkType.wrist,
            confidence: 0.9,
          ),
          const HandLandmark(
            position: Offset(10, 10),
            type: HandLandmarkType.thumbTip,
            confidence: 0.9,
          ),
          const HandLandmark(
            position: Offset(5, 5),
            type: HandLandmarkType.thumbMcp,
            confidence: 0.9,
          ),
          const HandLandmark(
            position: Offset(20, 20),
            type: HandLandmarkType.indexFingerTip,
            confidence: 0.9,
          ),
        ],
        confidence: 0.95,
        handType: HandType.left,
      );

      final fingertips = hand.getFingertipLandmarks();

      expect(fingertips, hasLength(2)); // thumbTip and indexFingerTip
      expect(fingertips, contains(const Offset(10, 10)));
      expect(fingertips, contains(const Offset(20, 20)));
    });

    test('getFingertipLandmarks should return empty list when no fingertips', () {
      final hand = HandDetectionResult(
        boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        landmarks: [
          const HandLandmark(
            position: Offset(0, 0),
            type: HandLandmarkType.wrist,
            confidence: 0.9,
          ),
        ],
        confidence: 0.95,
        handType: HandType.left,
      );

      final fingertips = hand.getFingertipLandmarks();

      expect(fingertips, isEmpty);
    });
  });

  group('HandLandmark', () {
    test('should store position, type, and confidence', () {
      const landmark = HandLandmark(
        position: Offset(10, 20),
        type: HandLandmarkType.indexFingerTip,
        confidence: 0.85,
      );

      expect(landmark.position, const Offset(10, 20));
      expect(landmark.type, HandLandmarkType.indexFingerTip);
      expect(landmark.confidence, 0.85);
    });
  });

  group('HandLandmarkType', () {
    test('should have 21 landmark types', () {
      expect(HandLandmarkType.values.length, 21);
    });

    test('should contain all fingertip types', () {
      expect(HandLandmarkType.values.contains(HandLandmarkType.thumbTip), true);
      expect(HandLandmarkType.values.contains(HandLandmarkType.indexFingerTip), true);
      expect(HandLandmarkType.values.contains(HandLandmarkType.middleFingerTip), true);
      expect(HandLandmarkType.values.contains(HandLandmarkType.ringFingerTip), true);
      expect(HandLandmarkType.values.contains(HandLandmarkType.pinkyTip), true);
    });
  });

  group('HandType', () {
    test('should have left and right types', () {
      expect(HandType.values.contains(HandType.left), true);
      expect(HandType.values.contains(HandType.right), true);
      expect(HandType.values.length, 2);
    });
  });
}
