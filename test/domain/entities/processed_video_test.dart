import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/domain/entities/processed_video.dart';

void main() {
  group('ProcessedVideo', () {
    test('should create instance with required values', () {
      final processedVideo = ProcessedVideo(
        outputPath: '/path/to/output/video.mp4',
        processingTime: const Duration(seconds: 30),
        totalFrames: 900,
        processedFrames: 450,
      );

      expect(processedVideo.outputPath, '/path/to/output/video.mp4');
      expect(processedVideo.processingTime, const Duration(seconds: 30));
      expect(processedVideo.totalFrames, 900);
      expect(processedVideo.processedFrames, 450);
    });

    test('should handle empty output path', () {
      final processedVideo = ProcessedVideo(
        outputPath: '',
        processingTime: Duration.zero,
        totalFrames: 0,
        processedFrames: 0,
      );

      expect(processedVideo.outputPath, '');
    });

    test('should handle zero frames', () {
      final processedVideo = ProcessedVideo(
        outputPath: '/path/to/video.mp4',
        processingTime: const Duration(milliseconds: 100),
        totalFrames: 0,
        processedFrames: 0,
      );

      expect(processedVideo.totalFrames, 0);
      expect(processedVideo.processedFrames, 0);
    });

    test('should handle all frames processed', () {
      final processedVideo = ProcessedVideo(
        outputPath: '/path/to/video.mp4',
        processingTime: const Duration(minutes: 2),
        totalFrames: 1800,
        processedFrames: 1800,
      );

      expect(processedVideo.processedFrames, processedVideo.totalFrames);
    });

    test('should handle long processing time', () {
      final processedVideo = ProcessedVideo(
        outputPath: '/path/to/long_video.mp4',
        processingTime: const Duration(hours: 1, minutes: 30),
        totalFrames: 324000,
        processedFrames: 162000,
      );

      expect(processedVideo.processingTime.inMinutes, 90);
      expect(processedVideo.processingTime.inHours, 1);
    });

    test('should handle various path formats', () {
      final videoWithComplexPath = ProcessedVideo(
        outputPath:
            '/users/test/documents/videos/processed/2024/01/video_final_v2.mp4',
        processingTime: const Duration(seconds: 45),
        totalFrames: 1350,
        processedFrames: 675,
      );

      expect(videoWithComplexPath.outputPath.contains('processed'), true);
      expect(videoWithComplexPath.outputPath.endsWith('.mp4'), true);
    });

    test('should handle large frame counts', () {
      final processedVideo = ProcessedVideo(
        outputPath: '/path/to/4k_video.mp4',
        processingTime: const Duration(hours: 2),
        totalFrames: 1000000,
        processedFrames: 500000,
      );

      expect(processedVideo.totalFrames, 1000000);
      expect(processedVideo.processedFrames, 500000);
    });
  });
}
