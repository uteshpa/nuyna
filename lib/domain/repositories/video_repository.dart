import '../entities/face_region.dart';
import '../entities/processed_video.dart';

/// Abstract repository interface for video processing operations.
///
/// Implementations of this repository should use FFmpeg Kit to extract
/// frames, generate blur filters, and measure processing time.
abstract class VideoRepository {
  /// Extracts frames from the video at the given path.
  ///
  /// [videoPath] - The path to the video file.
  ///
  /// Returns a list of frames, where each frame is represented as
  /// a list of bytes.
  ///
  /// Throws [StorageFailure] if [videoPath] is empty or the file
  /// does not exist.
  Future<List<List<int>>> extractFrames(String videoPath);

  /// Applies blur effect to the video based on detected face regions.
  ///
  /// [videoPath] - The path to the input video file.
  /// [faceRegions] - A map of frame indices to detected face regions.
  /// [blurStrength] - The strength of the blur effect.
  ///
  /// Returns the path to the processed video file.
  ///
  /// Throws [VideoProcessingFailure] if [blurStrength] is not in
  /// the valid range (10.0 - 25.0).
  Future<String> applyBlur({
    required String videoPath,
    required Map<int, List<FaceRegion>> faceRegions,
    required double blurStrength,
  });

  /// Processes the video by applying blur to detected face regions.
  ///
  /// [videoPath] - The path to the input video file.
  /// [faceRegions] - A map of frame indices to detected face regions.
  /// [blurStrength] - The strength of the blur effect.
  ///
  /// Returns a [ProcessedVideo] containing output path, processing time,
  /// and frame counts.
  ///
  /// Throws [VideoProcessingFailure] if [blurStrength] is not in
  /// the valid range (10.0 - 25.0).
  Future<ProcessedVideo> processVideo({
    required String videoPath,
    required Map<int, List<FaceRegion>> faceRegions,
    required double blurStrength,
  });
}
