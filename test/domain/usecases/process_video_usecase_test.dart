import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/domain/entities/face_detection_result.dart';
import 'package:nuyna/domain/entities/face_region.dart';
import 'package:nuyna/domain/entities/processed_video.dart';
import 'package:nuyna/domain/entities/video_processing_options.dart';
import 'package:nuyna/domain/repositories/face_detection_repository.dart';
import 'package:nuyna/domain/repositories/video_repository.dart';
import 'package:nuyna/domain/usecases/process_video_usecase.dart';

/// Mock implementation of FaceDetectionRepository for testing.
class MockFaceDetectionRepository implements FaceDetectionRepository {
  final List<FaceDetectionResult> results;
  int callCount = 0;

  MockFaceDetectionRepository({required this.results});

  @override
  Future<FaceDetectionResult> detectFaces(List<int> imageBytes) async {
    final result = results[callCount % results.length];
    callCount++;
    return result;
  }
}

/// Mock implementation of VideoRepository for testing.
class MockVideoRepository implements VideoRepository {
  final List<List<int>> frames;
  final String outputPath;
  int extractFramesCalled = 0;
  int applyBlurCalled = 0;
  int processVideoCalled = 0;
  Map<int, List<FaceRegion>>? lastFaceRegions;
  double? lastBlurStrength;

  MockVideoRepository({
    required this.frames,
    required this.outputPath,
  });

  @override
  Future<List<List<int>>> extractFrames(String videoPath) async {
    extractFramesCalled++;
    return frames;
  }

  @override
  Future<String> applyBlur({
    required String videoPath,
    required Map<int, List<FaceRegion>> faceRegions,
    required double blurStrength,
  }) async {
    applyBlurCalled++;
    lastFaceRegions = faceRegions;
    lastBlurStrength = blurStrength;
    return outputPath;
  }

  @override
  Future<ProcessedVideo> processVideo({
    required String videoPath,
    required Map<int, List<FaceRegion>> faceRegions,
    required double blurStrength,
  }) async {
    processVideoCalled++;
    return ProcessedVideo(
      outputPath: outputPath,
      processingTime: const Duration(seconds: 10),
      totalFrames: frames.length,
      processedFrames: faceRegions.length,
    );
  }
}

void main() {
  group('ProcessVideoUseCase', () {
    late MockVideoRepository mockVideoRepository;
    late MockFaceDetectionRepository mockFaceDetectionRepository;
    late ProcessVideoUseCase useCase;

    final testFaceRegion = FaceRegion(
      boundingBox: const Rect.fromLTWH(10, 20, 100, 120),
      landmarks: [const Offset(50, 60)],
      confidence: 0.9,
    );

    final testDetectionResult = FaceDetectionResult(
      faces: [testFaceRegion],
      confidence: 0.9,
      processingTime: const Duration(milliseconds: 50),
    );

    setUp(() {
      mockVideoRepository = MockVideoRepository(
        frames: [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ],
        outputPath: '/output/processed_video.mp4',
      );

      mockFaceDetectionRepository = MockFaceDetectionRepository(
        results: [testDetectionResult],
      );

      useCase = ProcessVideoUseCase(
        mockVideoRepository,
        mockFaceDetectionRepository,
      );
    });

    test('should return original video when enableFaceBlur is false', () async {
      final options = VideoProcessingOptions(enableFaceBlur: false);
      const videoPath = '/input/video.mp4';

      final result = await useCase.execute(
        videoPath: videoPath,
        options: options,
      );

      expect(result.outputPath, videoPath);
      expect(result.totalFrames, 0);
      expect(result.processedFrames, 0);
      expect(mockVideoRepository.extractFramesCalled, 0);
      expect(mockFaceDetectionRepository.callCount, 0);
    });

    test('should process video when enableFaceBlur is true', () async {
      final options = VideoProcessingOptions(enableFaceBlur: true);
      const videoPath = '/input/video.mp4';

      final result = await useCase.execute(
        videoPath: videoPath,
        options: options,
      );

      expect(result.outputPath, '/output/processed_video.mp4');
      expect(mockVideoRepository.extractFramesCalled, 1);
      expect(mockFaceDetectionRepository.callCount, 3);
      expect(mockVideoRepository.applyBlurCalled, 1);
    });

    test('should use blur strength from options', () async {
      final options = VideoProcessingOptions(
        enableFaceBlur: true,
        blurStrength: 20.0,
      );
      const videoPath = '/input/video.mp4';

      await useCase.execute(
        videoPath: videoPath,
        options: options,
      );

      expect(mockVideoRepository.lastBlurStrength, 20.0);
    });

    test('should filter faces by detection sensitivity', () async {
      final lowConfidenceFace = FaceRegion(
        boundingBox: const Rect.fromLTWH(10, 20, 100, 120),
        landmarks: [],
        confidence: 0.5, // Below default sensitivity of 0.7
      );

      final lowConfidenceResult = FaceDetectionResult(
        faces: [lowConfidenceFace],
        confidence: 0.5,
        processingTime: const Duration(milliseconds: 50),
      );

      mockFaceDetectionRepository = MockFaceDetectionRepository(
        results: [lowConfidenceResult],
      );

      useCase = ProcessVideoUseCase(
        mockVideoRepository,
        mockFaceDetectionRepository,
      );

      final options = VideoProcessingOptions(
        enableFaceBlur: true,
        detectionSensitivity: 0.7,
      );

      await useCase.execute(
        videoPath: '/input/video.mp4',
        options: options,
      );

      // All faces should be filtered out due to low confidence
      expect(mockVideoRepository.lastFaceRegions!.isEmpty, true);
    });

    test('should include faces above detection sensitivity', () async {
      final highConfidenceFace = FaceRegion(
        boundingBox: const Rect.fromLTWH(10, 20, 100, 120),
        landmarks: [],
        confidence: 0.8, // Above sensitivity of 0.7
      );

      final highConfidenceResult = FaceDetectionResult(
        faces: [highConfidenceFace],
        confidence: 0.8,
        processingTime: const Duration(milliseconds: 50),
      );

      mockFaceDetectionRepository = MockFaceDetectionRepository(
        results: [highConfidenceResult],
      );

      useCase = ProcessVideoUseCase(
        mockVideoRepository,
        mockFaceDetectionRepository,
      );

      final options = VideoProcessingOptions(
        enableFaceBlur: true,
        detectionSensitivity: 0.7,
      );

      await useCase.execute(
        videoPath: '/input/video.mp4',
        options: options,
      );

      // All 3 frames should have detected faces
      expect(mockVideoRepository.lastFaceRegions!.length, 3);
    });

    test('should return correct frame counts', () async {
      final options = VideoProcessingOptions(enableFaceBlur: true);

      final result = await useCase.execute(
        videoPath: '/input/video.mp4',
        options: options,
      );

      expect(result.totalFrames, 3);
    });

    test('should measure processing time', () async {
      final options = VideoProcessingOptions(enableFaceBlur: true);

      final result = await useCase.execute(
        videoPath: '/input/video.mp4',
        options: options,
      );

      expect(result.processingTime.inMicroseconds, greaterThan(0));
    });

    test('should handle empty frames list', () async {
      mockVideoRepository = MockVideoRepository(
        frames: [],
        outputPath: '/output/processed_video.mp4',
      );

      useCase = ProcessVideoUseCase(
        mockVideoRepository,
        mockFaceDetectionRepository,
      );

      final options = VideoProcessingOptions(enableFaceBlur: true);

      final result = await useCase.execute(
        videoPath: '/input/video.mp4',
        options: options,
      );

      expect(result.totalFrames, 0);
      expect(mockFaceDetectionRepository.callCount, 0);
    });

    test('should use default options correctly', () async {
      final options = VideoProcessingOptions();

      await useCase.execute(
        videoPath: '/input/video.mp4',
        options: options,
      );

      expect(mockVideoRepository.lastBlurStrength, 15.0);
      expect(mockVideoRepository.applyBlurCalled, 1);
    });
  });
}
