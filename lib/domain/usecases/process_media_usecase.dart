import 'package:path_provider/path_provider.dart';
import '../entities/processed_video.dart';
import '../entities/video_processing_options.dart';
import '../entities/face_region.dart';
import '../repositories/face_detection_repository.dart';
import '../repositories/video_repository.dart';
import 'package:nuyna/data/datasources/image_processing_datasource.dart';

/// Use case for processing media (images and videos) with privacy features.
///
/// This use case orchestrates the media processing workflow:
/// - For images: EXIF metadata removal
/// - For videos: Frame extraction, face detection, blur application
class ProcessMediaUseCase {
  final VideoRepository _videoRepository;
  final FaceDetectionRepository _faceDetectionRepository;
  final ImageProcessingDataSource _imageProcessingDataSource;

  /// Creates a new [ProcessMediaUseCase] instance.
  ProcessMediaUseCase(
    this._videoRepository,
    this._faceDetectionRepository,
    this._imageProcessingDataSource,
  );

  /// Checks if a file is an image based on extension.
  bool _isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp'].contains(ext);
  }

  /// Executes the media processing workflow.
  ///
  /// [mediaPath] - The path to the input media file (image or video).
  /// [options] - Processing options including metadata strip, blur settings.
  ///
  /// Routes to appropriate processor based on file type:
  /// - Images: EXIF metadata removal
  /// - Videos: Face detection and blur (if enabled)
  Future<ProcessedVideo> execute({
    required String mediaPath,
    required VideoProcessingOptions options,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (_isImageFile(mediaPath)) {
      // Process static image
      return await _processImage(mediaPath, options, stopwatch);
    } else {
      // Process video
      return await _processVideo(mediaPath, options, stopwatch);
    }
  }

  /// Process a static image - remove EXIF metadata
  Future<ProcessedVideo> _processImage(
    String imagePath,
    VideoProcessingOptions options,
    Stopwatch stopwatch,
  ) async {
    // If metadata strip is disabled, return original
    if (!options.enableMetadataStrip) {
      stopwatch.stop();
      return ProcessedVideo(
        outputPath: imagePath,
        processingTime: stopwatch.elapsed,
        totalFrames: 1,
        processedFrames: 0,
      );
    }

    // Get output path in temp directory
    final tempDir = await getTemporaryDirectory();
    final inputExt = _imageProcessingDataSource.getOutputExtension(imagePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/nuyna_processed_$timestamp.$inputExt';

    // Remove metadata by re-encoding
    await _imageProcessingDataSource.removeMetadata(
      inputPath: imagePath,
      outputPath: outputPath,
    );

    stopwatch.stop();

    return ProcessedVideo(
      outputPath: outputPath,
      processingTime: stopwatch.elapsed,
      totalFrames: 1,
      processedFrames: 1,
    );
  }

  /// Process a video - face detection and blur
  Future<ProcessedVideo> _processVideo(
    String videoPath,
    VideoProcessingOptions options,
    Stopwatch stopwatch,
  ) async {
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
