import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/core/errors/failures.dart';
import 'package:nuyna/data/datasources/ffmpeg_datasource.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';
import 'package:nuyna/data/repositories/video_repository_impl.dart';
import 'package:nuyna/domain/entities/face_region.dart';
import 'package:nuyna/domain/repositories/video_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoRepositoryImpl', () {
    late VideoRepositoryImpl repository;
    late FFmpegDataSource ffmpegDataSource;
    late StorageDataSource storageDataSource;

    setUp(() {
      ffmpegDataSource = FFmpegDataSource();
      storageDataSource = StorageDataSource();
      repository = VideoRepositoryImpl(
        ffmpegDataSource: ffmpegDataSource,
        storageDataSource: storageDataSource,
      );
    });

    test('should be instantiable', () {
      expect(repository, isNotNull);
    });

    test('should implement VideoRepository', () {
      expect(repository, isA<VideoRepository>());
    });

    test('should have extractFrames method', () {
      expect(repository.extractFrames, isA<Function>());
    });

    test('should have applyBlur method', () {
      expect(repository.applyBlur, isA<Function>());
    });

    test('should have processVideo method', () {
      expect(repository.processVideo, isA<Function>());
    });

    group('extractFrames', () {
      test('should throw StorageFailure on empty video path', () async {
        expect(
          () => repository.extractFrames(''),
          throwsA(isA<StorageFailure>()),
        );
      });

      test('should throw StorageFailure on non-existent file', () async {
        expect(
          () => repository.extractFrames('/non/existent/video.mp4'),
          throwsA(isA<StorageFailure>()),
        );
      });
    });

    group('applyBlur', () {
      test('should throw VideoProcessingFailure on blur strength below 10', () async {
        expect(
          () => repository.applyBlur(
            videoPath: '/some/video.mp4',
            faceRegions: {},
            blurStrength: 5.0,
          ),
          throwsA(isA<VideoProcessingFailure>()),
        );
      });

      test('should throw VideoProcessingFailure on blur strength above 25', () async {
        expect(
          () => repository.applyBlur(
            videoPath: '/some/video.mp4',
            faceRegions: {},
            blurStrength: 30.0,
          ),
          throwsA(isA<VideoProcessingFailure>()),
        );
      });

      test('should throw StorageFailure on empty video path', () async {
        expect(
          () => repository.applyBlur(
            videoPath: '',
            faceRegions: {},
            blurStrength: 15.0,
          ),
          throwsA(isA<StorageFailure>()),
        );
      });

      test('should accept blur strength of 10.0', () async {
        // Should pass validation but fail on file not found
        expect(
          () => repository.applyBlur(
            videoPath: '/non/existent/video.mp4',
            faceRegions: {},
            blurStrength: 10.0,
          ),
          throwsA(isA<StorageFailure>()),
        );
      });

      test('should accept blur strength of 25.0', () async {
        // Should pass validation but fail on file not found
        expect(
          () => repository.applyBlur(
            videoPath: '/non/existent/video.mp4',
            faceRegions: {},
            blurStrength: 25.0,
          ),
          throwsA(isA<StorageFailure>()),
        );
      });
    });

    group('processVideo', () {
      test('should throw on invalid blur strength', () async {
        expect(
          () => repository.processVideo(
            videoPath: '/some/video.mp4',
            faceRegions: {},
            blurStrength: 5.0,
          ),
          throwsA(isA<VideoProcessingFailure>()),
        );
      });

      test('should accept valid face regions map', () async {
        final faceRegions = {
          0: [
            FaceRegion(
              boundingBox: const Rect.fromLTRB(100, 100, 200, 200),
              landmarks: [const Offset(150, 150)],
              confidence: 0.9,
            ),
          ],
        };

        // Should pass validation but fail on file not found
        expect(
          () => repository.processVideo(
            videoPath: '/non/existent/video.mp4',
            faceRegions: faceRegions,
            blurStrength: 15.0,
          ),
          throwsA(isA<Failure>()),
        );
      });
    });
  });
}
