/// Processed video information entity.
///
/// This entity represents the result of a video processing operation,
/// containing output path, processing time, and frame counts.
class ProcessedVideo {
  /// Path to the processed video output file.
  final String outputPath;

  /// Total time taken to process the video.
  final Duration processingTime;

  /// Total number of frames in the video.
  final int totalFrames;

  /// Number of frames that were processed.
  final int processedFrames;

  /// Creates a new [ProcessedVideo] instance.
  ///
  /// All parameters are required:
  /// - [outputPath]: Path to the output video file
  /// - [processingTime]: Duration of the processing operation
  /// - [totalFrames]: Total frame count
  /// - [processedFrames]: Number of processed frames
  ProcessedVideo({
    required this.outputPath,
    required this.processingTime,
    required this.totalFrames,
    required this.processedFrames,
  });
}
