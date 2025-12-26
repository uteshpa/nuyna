import 'dart:io';

import 'package:ffmpeg_kit_flutter_minimal/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_minimal/return_code.dart';
import 'package:nuyna/domain/entities/face_region.dart';

/// Data source for FFmpeg video processing operations.
///
/// This class provides access to FFmpeg Kit for extracting frames
/// from videos and applying precision blur filters to biometric data.
class FFmpegDataSource {
  /// Extracts frames from a video file.
  ///
  /// [videoPath] - The path to the input video file.
  /// [outputDir] - The directory to save extracted frames.
  /// [fps] - Frames per second to extract (default: 1).
  ///
  /// Returns a list of paths to the extracted frame images.
  Future<List<String>> extractFrames(
    String videoPath,
    String outputDir, {
    int fps = 1,
  }) async {
    final outputPattern = '$outputDir/frame_%04d.png';
    final command = '-i "$videoPath" -vf fps=$fps "$outputPattern"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg frame extraction failed: $logs');
    }

    // List extracted frames
    final dir = Directory(outputDir);
    final files = await dir.list().toList();
    return files
        .where((f) => f.path.endsWith('.png'))
        .map((f) => f.path)
        .toList()
      ..sort();
  }

  /// Applies precision blur filter to specific facial landmarks.
  ///
  /// [videoPath] - The path to the input video file.
  /// [outputPath] - The path for the output video file.
  /// [frameFaceRegions] - Map of frame indices to face regions.
  /// [blurStrength] - The strength of the blur effect (10-25).
  /// [frameRate] - The frame rate of the video.
  ///
  /// This method generates a complex filter graph that applies
  /// circular blur only to biometric landmarks (eyes, nose, mouth).
  Future<String> applyPrecisionBlurFilter({
    required String videoPath,
    required String outputPath,
    required Map<int, List<FaceRegion>> frameFaceRegions,
    required double blurStrength,
    required double frameRate,
  }) async {
    final filterString = generateLandmarkBlurFilter(
      frameFaceRegions,
      blurStrength,
      frameRate,
    );

    String command;
    if (filterString.isEmpty) {
      // No faces detected, just copy the video
      command = '-i "$videoPath" -c copy "$outputPath"';
    } else {
      command = '-i "$videoPath" -vf "$filterString" -c:a copy "$outputPath"';
    }

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg blur application failed: $logs');
    }

    return outputPath;
  }

  /// Generates FFmpeg filter string for precision landmark blurring.
  ///
  /// Creates boxblur filters that only affect small circular areas
  /// around biometric landmarks (eyes, nose, mouth), not the entire face.
  ///
  /// [frameFaceRegions] - Map of frame indices to face regions.
  /// [blurStrength] - The blur intensity.
  /// [frameRate] - Video frame rate for timing calculations.
  ///
  /// Returns the FFmpeg filter string.
  String generateLandmarkBlurFilter(
    Map<int, List<FaceRegion>> frameFaceRegions,
    double blurStrength,
    double frameRate,
  ) {
    if (frameFaceRegions.isEmpty) {
      return '';
    }

    final filterParts = <String>[];
    final blurRadius = blurStrength.round();

    frameFaceRegions.forEach((frameIndex, faceRegions) {
      final frameStartTime = frameIndex / frameRate;
      final frameEndTime = (frameIndex + 1) / frameRate;

      for (final region in faceRegions) {
        // Apply precision blur to each landmark point
        for (final landmark in region.landmarks) {
          final x = landmark.dx.round();
          final y = landmark.dy.round();
          // Small radius for precision blurring (8-12 pixels based on blur strength)
          final radius = (blurStrength * 0.8).round().clamp(5, 15);

          // Generate enable condition for this specific landmark at this frame time
          final enableCondition =
              "between(t,$frameStartTime,$frameEndTime)*lt(hypot(X-$x\\,Y-$y)\\,$radius)";

          filterParts.add(
            'boxblur=$blurRadius:$blurRadius:enable=\'$enableCondition\'',
          );
        }
      }
    });

    if (filterParts.isEmpty) {
      return '';
    }

    // Chain all blur filters together
    return filterParts.join(',');
  }

  /// Gets video information including duration and frame count.
  ///
  /// [videoPath] - The path to the video file.
  ///
  /// Returns a map with 'duration' and 'frameRate' keys.
  Future<Map<String, double>> getVideoInfo(String videoPath) async {
    final session = await FFmpegKit.execute(
      '-i "$videoPath" -hide_banner',
    );
    final output = await session.getAllLogsAsString() ?? '';

    // Parse duration from FFmpeg output
    final durationMatch = RegExp(r'Duration: (\d+):(\d+):(\d+)\.(\d+)').firstMatch(output);
    double duration = 0;
    if (durationMatch != null) {
      final hours = int.parse(durationMatch.group(1)!);
      final minutes = int.parse(durationMatch.group(2)!);
      final seconds = int.parse(durationMatch.group(3)!);
      final centiseconds = int.parse(durationMatch.group(4)!);
      duration = hours * 3600 + minutes * 60 + seconds + centiseconds / 100;
    }

    // Parse frame rate from FFmpeg output
    final fpsMatch = RegExp(r'(\d+(?:\.\d+)?)\s*fps').firstMatch(output);
    double frameRate = 30.0; // Default
    if (fpsMatch != null) {
      frameRate = double.parse(fpsMatch.group(1)!);
    }

    return {
      'duration': duration,
      'frameRate': frameRate,
    };
  }
}
