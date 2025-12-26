import '../entities/face_region.dart';
import '../entities/processed_video.dart';
import '../entities/video_processing_options.dart';
import '../repositories/face_detection_repository.dart';
import '../repositories/video_repository.dart';

/// Use case for processing videos with face blur and other privacy features.
///
/// This use case orchestrates the video processing workflow:
/// 1. Extracting frames from the video
/// 2. Detecting faces in each frame
/// 3. Applying blur to detected face regions
class ProcessVideoUseCase {
  final VideoRepository _videoRepository;
  final FaceDetectionRepository _faceDetectionRepository;

  /// Creates a new [ProcessVideoUseCase] instance.
  ///
  /// [_videoRepository] - Repository for video operations.
  /// [_faceDetectionRepository] - Repository for face detection operations.
  ProcessVideoUseCase(
    this._videoRepository,
    this._faceDetectionRepository,
  );

  /// Executes the video processing workflow.
  ///
  /// [videoPath] - The path to the input video file.
  /// [options] - Processing options including blur settings and features.
  ///
  /// Returns a [ProcessedVideo] containing the output path, processing time,
  /// and frame counts.
  ///
  /// Processing Flow:
  /// 1. If [options.enableFaceBlur] is false, returns ProcessedVideo with
  ///    input videoPath as-is
  /// 2. Extracts frames using [_videoRepository.extractFrames]
  /// 3. For each frame, executes [_faceDetectionRepository.detectFaces]
  /// 4. Stores results in a map of frame index to face regions
  /// 5. Applies blur using [_videoRepository.applyBlur]
  /// 6. Returns ProcessedVideo with output path, processing time,
  ///    total frames, and processed frames
  Future<ProcessedVideo> execute({
    required String videoPath,
    required VideoProcessingOptions options,
  }) async {
    final stopwatch = Stopwatch()..start();

    // If face blur is disabled, return the original video as-is
    if (!options.enableFaceBlur) {
      stopwatch.stop();
      return ProcessedVideo(
        outputPath: videoPath,
        processingTime: stopwatch.elapsed,
        totalFrames: 0,
        processedFrames: 0,
      );
    }

    // Step 1: Extract frames from the video
    final frames = await _videoRepository.extractFrames(videoPath);
    final totalFrames = frames.length;

    // Step 2: Detect faces in each frame
    final Map<int, List<FaceRegion>> faceRegions = {};
    int processedFrames = 0;

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final detectionResult = await _faceDetectionRepository.detectFaces(frame);

      // Filter faces by detection sensitivity
      final filteredFaces = detectionResult.faces
          .where((face) => face.confidence >= options.detectionSensitivity)
          .toList();

      if (filteredFaces.isNotEmpty) {
        faceRegions[i] = filteredFaces;
        processedFrames++;
      }
    }

    // Step 3: Apply blur to detected face regions
    final outputPath = await _videoRepository.applyBlur(
      videoPath: videoPath,
      faceRegions: faceRegions,
      blurStrength: options.blurStrength,
    );

    stopwatch.stop();

    // Step 4: Return the processed video result
    return ProcessedVideo(
      outputPath: outputPath,
      processingTime: stopwatch.elapsed,
      totalFrames: totalFrames,
      processedFrames: processedFrames,
    );
  }
}
