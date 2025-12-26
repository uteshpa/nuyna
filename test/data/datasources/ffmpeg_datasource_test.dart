import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/data/datasources/ffmpeg_datasource.dart';
import 'package:nuyna/domain/entities/face_region.dart';

void main() {
  late FFmpegDataSource dataSource;

  setUp(() {
    dataSource = FFmpegDataSource();
  });

  group('FFmpegDataSource', () {
    group('generateLandmarkBlurFilter', () {
      test('should return empty string when no face regions provided', () {
        final filter = dataSource.generateLandmarkBlurFilter({}, 15.0, 30.0);
        expect(filter, isEmpty);
      });

      test('should generate filter for single landmark', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [const Offset(150, 150)],
              confidence: 0.9,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0,
        );

        expect(filter, contains('boxblur'));
        expect(filter, contains('150'));
        expect(filter, contains('enable='));
      });

      test('should generate multiple filters for multiple landmarks', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [
                const Offset(120, 130), // Left eye
                const Offset(180, 130), // Right eye
                const Offset(150, 160), // Nose
              ],
              confidence: 0.9,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0,
        );

        // Should have 3 boxblur filters chained
        final boxblurCount = 'boxblur'.allMatches(filter).length;
        expect(boxblurCount, equals(3));
      });

      test('should include frame timing in enable condition', () {
        final faceRegions = {
          5: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [const Offset(150, 150)],
              confidence: 0.9,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0, // 30 fps means frame 5 is at ~0.167s
        );

        expect(filter, contains('between(t,'));
      });

      test('should handle multiple frames with different face regions', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [const Offset(150, 150)],
              confidence: 0.9,
            ),
          ],
          10: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(200, 200, 300, 300),
              landmarks: [const Offset(250, 250)],
              confidence: 0.85,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0,
        );

        // Should have 2 boxblur filters (one per landmark)
        final boxblurCount = 'boxblur'.allMatches(filter).length;
        expect(boxblurCount, equals(2));

        // Should contain both coordinates
        expect(filter, contains('150'));
        expect(filter, contains('250'));
      });

      test('should use blur strength for boxblur radius', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [const Offset(150, 150)],
              confidence: 0.9,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          20.0, // Blur strength of 20
          30.0,
        );

        expect(filter, contains('boxblur=20:20'));
      });

      test('should calculate appropriate radius for precision blurring', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [const Offset(150, 150)],
              confidence: 0.9,
            ),
          ],
        };

        // With blur strength 15, radius should be 15 * 0.8 = 12
        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0,
        );

        expect(filter, contains('12)'));
      });

      test('should handle empty landmarks list', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [],
              confidence: 0.9,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0,
        );

        expect(filter, isEmpty);
      });

      test('should chain filters with commas', () {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [
                const Offset(120, 130),
                const Offset(180, 130),
              ],
              confidence: 0.9,
            ),
          ],
        };

        final filter = dataSource.generateLandmarkBlurFilter(
          faceRegions,
          15.0,
          30.0,
        );

        expect(filter, contains(','));
      });
    });
  });
}
