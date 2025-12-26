import 'dart:io';

import 'package:nuyna/core/errors/failures.dart';
import 'package:nuyna/data/datasources/ffmpeg_datasource.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';
import 'package:nuyna/domain/entities/face_region.dart';
import 'package:nuyna/domain/entities/processed_video.dart';
import 'package:nuyna/domain/repositories/video_repository.dart';

/// Implementation of [VideoRepository] using FFmpeg Kit.
///
/// Provides video processing capabilities including frame extraction
/// and precision blur application to biometric landmarks.
class VideoRepositoryImpl implements VideoRepository {
  /// The FFmpeg data source for video processing.
  final FFmpegDataSource ffmpegDataSource;

  /// The storage data source for file operations.
  final StorageDataSource storageDataSource;

  /// Creates a new [VideoRepositoryImpl] instance.
  VideoRepositoryImpl({
    required this.ffmpegDataSource,
    required this.storageDataSource,
  });

  @override
  Future<List<List<int>>> extractFrames(String videoPath) async {
    try {
      // Validate input
      if (videoPath.isEmpty) {
        throw StorageFailure('Video path cannot be empty');
      }

      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw StorageFailure('Video file does not exist: $videoPath');
      }

      // Create temporary directory for frames
      final tempDir = await storageDataSource.getTemporaryDirectory();
      final framesDir = '${tempDir.path}/frames_${DateTime.now().millisecondsSinceEpoch}';
      await storageDataSource.createDirectory(framesDir);

      try {
        // Extract frames using FFmpeg
        final framePaths = await ffmpegDataSource.extractFrames(videoPath, framesDir);

        // Read frame bytes
        final frameBytes = <List<int>>[];
        for (final framePath in framePaths) {
          final bytes = await storageDataSource.readFile(framePath);
          frameBytes.add(bytes);
        }

        return frameBytes;
      } finally {
        // Clean up frames directory
        await storageDataSource.deleteDirectory(framesDir);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw FFmpegFailure('Frame extraction failed: $e');
    }
  }

  @override
  Future<String> applyBlur({
    required String videoPath,
    required Map<int, List<FaceRegion>> faceRegions,
    required double blurStrength,
  }) async {
    try {
      // Validate blur strength
      if (blurStrength < 10.0 || blurStrength > 25.0) {
        throw VideoProcessingFailure(
          'Blur strength must be between 10.0 and 25.0, got: $blurStrength',
        );
      }

      // Validate input
      if (videoPath.isEmpty) {
        throw StorageFailure('Video path cannot be empty');
      }

      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw StorageFailure('Video file does not exist: $videoPath');
      }

      // Get video info for frame rate
      final videoInfo = await ffmpegDataSource.getVideoInfo(videoPath);
      final frameRate = videoInfo['frameRate'] ?? 30.0;

      // Generate output path
      final tempDir = await storageDataSource.getTemporaryDirectory();
      final outputPath = '${tempDir.path}/blurred_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Apply precision blur
      await ffmpegDataSource.applyPrecisionBlurFilter(
        videoPath: videoPath,
        outputPath: outputPath,
        frameFaceRegions: faceRegions,
        blurStrength: blurStrength,
        frameRate: frameRate,
      );

      return outputPath;
    } catch (e) {
      if (e is Failure) rethrow;
      throw FFmpegFailure('Blur application failed: $e');
    }
  }

  @override
  Future<ProcessedVideo> processVideo({
    required String videoPath,
    required Map<int, List<FaceRegion>> faceRegions,
    required double blurStrength,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Get video info
      final videoInfo = await ffmpegDataSource.getVideoInfo(videoPath);
      final duration = videoInfo['duration'] ?? 0.0;
      final frameRate = videoInfo['frameRate'] ?? 30.0;
      final totalFrames = (duration * frameRate).round();

      // Apply blur
      final outputPath = await applyBlur(
        videoPath: videoPath,
        faceRegions: faceRegions,
        blurStrength: blurStrength,
      );

      stopwatch.stop();

      return ProcessedVideo(
        outputPath: outputPath,
        processingTime: stopwatch.elapsed,
        totalFrames: totalFrames,
        processedFrames: faceRegions.length,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is Failure) rethrow;
      throw VideoProcessingFailure('Video processing failed: $e');
    }
  }
}
