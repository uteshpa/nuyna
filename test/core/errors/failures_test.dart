import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/core/errors/failures.dart';

void main() {
  group('Failures', () {
    group('VideoProcessingFailure', () {
      test('should create with message', () {
        const message = 'Video processing failed';
        final failure = VideoProcessingFailure(message);

        expect(failure.message, message);
      });

      test('should extend Failure', () {
        final failure = VideoProcessingFailure('error');

        expect(failure, isA<Failure>());
      });

      test('should handle empty message', () {
        final failure = VideoProcessingFailure('');

        expect(failure.message, '');
      });
    });

    group('FaceDetectionFailure', () {
      test('should create with message', () {
        const message = 'Face detection failed';
        final failure = FaceDetectionFailure(message);

        expect(failure.message, message);
      });

      test('should extend Failure', () {
        final failure = FaceDetectionFailure('error');

        expect(failure, isA<Failure>());
      });
    });

    group('StorageFailure', () {
      test('should create with message', () {
        const message = 'Storage operation failed';
        final failure = StorageFailure(message);

        expect(failure.message, message);
      });

      test('should extend Failure', () {
        final failure = StorageFailure('error');

        expect(failure, isA<Failure>());
      });
    });

    group('FFmpegFailure', () {
      test('should create with message', () {
        const message = 'FFmpeg operation failed';
        final failure = FFmpegFailure(message);

        expect(failure.message, message);
      });

      test('should extend Failure', () {
        final failure = FFmpegFailure('error');

        expect(failure, isA<Failure>());
      });
    });

    group('UnknownFailure', () {
      test('should create with message', () {
        const message = 'Unknown error occurred';
        final failure = UnknownFailure(message);

        expect(failure.message, message);
      });

      test('should extend Failure', () {
        final failure = UnknownFailure('error');

        expect(failure, isA<Failure>());
      });
    });

    test('different failure types should be distinguishable', () {
      final videoFailure = VideoProcessingFailure('video error');
      final faceFailure = FaceDetectionFailure('face error');
      final storageFailure = StorageFailure('storage error');
      final ffmpegFailure = FFmpegFailure('ffmpeg error');
      final unknownFailure = UnknownFailure('unknown error');

      expect(videoFailure, isA<VideoProcessingFailure>());
      expect(videoFailure, isNot(isA<FaceDetectionFailure>()));

      expect(faceFailure, isA<FaceDetectionFailure>());
      expect(faceFailure, isNot(isA<StorageFailure>()));

      expect(storageFailure, isA<StorageFailure>());
      expect(storageFailure, isNot(isA<FFmpegFailure>()));

      expect(ffmpegFailure, isA<FFmpegFailure>());
      expect(ffmpegFailure, isNot(isA<UnknownFailure>()));

      expect(unknownFailure, isA<UnknownFailure>());
      expect(unknownFailure, isNot(isA<VideoProcessingFailure>()));
    });
  });
}
