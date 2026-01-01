import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../entities/processed_video.dart';
import '../entities/video_processing_options.dart';
import '../entities/face_region.dart';
import '../repositories/face_detection_repository.dart';
import '../repositories/video_repository.dart';
import 'package:nuyna/data/datasources/image_processing_datasource.dart';
import 'package:nuyna/domain/usecases/scrub_fingerprints_usecase.dart';
import 'package:nuyna/domain/usecases/obfuscate_face_usecase.dart';
import 'package:nuyna/core/di/service_locator.dart';

/// Use case for processing media (images and videos) with privacy features.
///
/// This use case orchestrates the media processing workflow:
/// - For images: Face/Hand Detection -> Obfuscation/Scrubbing -> Metadata Stripping
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
  /// Processing Pipeline:
  /// 1. Face/Hand Detection
  /// 2. Fingerprint Scrubbing (if enableFingerGuard)
  /// 3. Advanced Face Obfuscation (if enableAdvancedFaceObfuscation)
  /// 4. Face Blur (if enableFaceBlur)
  /// 5. Metadata Stripping (if enableMetadataStrip)
  Future<ProcessedVideo> execute({
    required String mediaPath,
    required VideoProcessingOptions options,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (_isImageFile(mediaPath)) {
      // Process static image with Level 2 protection
      return await _processImage(mediaPath, options, stopwatch);
    } else {
      // Process video
      return await _processVideo(mediaPath, options, stopwatch);
    }
  }

  /// Process a static image with Level 2 protection
  Future<ProcessedVideo> _processImage(
    String imagePath,
    VideoProcessingOptions options,
    Stopwatch stopwatch,
  ) async {
    // Read image file
    final inputFile = File(imagePath);
    var imageBytes = await inputFile.readAsBytes();
    
    // Decode to get dimensions
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      stopwatch.stop();
      return ProcessedVideo(
        outputPath: imagePath,
        processingTime: stopwatch.elapsed,
        totalFrames: 1,
        processedFrames: 0,
      );
    }
    
    final width = decodedImage.width;
    final height = decodedImage.height;
    int processedLayers = 0;

    // Step 1: Fingerprint Scrubbing (Palm Scrubber)
    if (options.enableFingerGuard) {
      try {
        final scrubUseCase = getIt<ScrubFingerprintsUseCase>();
        imageBytes = await scrubUseCase.execute(
          imageBytes: imageBytes,
          width: width,
          height: height,
        );
        processedLayers++;
      } catch (e) {
        // Continue processing even if fingerprint scrubbing fails
      }
    }

    // Step 2: Advanced Face Obfuscation
    if (options.enableAdvancedFaceObfuscation) {
      try {
        // Detect faces from image bytes
        final detectionResult = await _faceDetectionRepository.detectFaces(imageBytes.toList());

        if (detectionResult.faces.isNotEmpty) {
          final obfuscateUseCase = getIt<ObfuscateFaceUseCase>();
          imageBytes = await obfuscateUseCase.execute(
            imageBytes: imageBytes,
            width: width,
            height: height,
            faceRegions: detectionResult.faces,
          );
          processedLayers++;
        }
      } catch (e) {
        // Continue processing even if obfuscation fails
      }
    }

    // Step 3: Standard Face Blur (if enabled and not already obfuscated)
    if (options.enableFaceBlur && !options.enableAdvancedFaceObfuscation) {
      try {
        // Detect faces from image bytes
        final detectionResult = await _faceDetectionRepository.detectFaces(imageBytes.toList());

        if (detectionResult.faces.isNotEmpty) {
          // Apply simple blur using image package
          imageBytes = await _applySimpleBlur(
            imageBytes, 
            width, 
            height, 
            detectionResult.faces,
            options.blurStrength.toInt(),
          );
          processedLayers++;
        }
      } catch (e) {
        // Continue processing
      }
    }

    // Step 4: Metadata Stripping (final step)
    final tempDir = await getTemporaryDirectory();
    final inputExt = _imageProcessingDataSource.getOutputExtension(imagePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/nuyna_processed_$timestamp.$inputExt';

    if (options.enableMetadataStrip) {
      // Write intermediate result and strip metadata
      final tempPath = '${tempDir.path}/nuyna_temp_$timestamp.$inputExt';
      await File(tempPath).writeAsBytes(imageBytes);
      await _imageProcessingDataSource.removeMetadata(
        inputPath: tempPath,
        outputPath: outputPath,
      );
      await File(tempPath).delete();
    } else {
      // Just write the processed bytes
      await File(outputPath).writeAsBytes(imageBytes);
    }

    stopwatch.stop();

    return ProcessedVideo(
      outputPath: outputPath,
      processingTime: stopwatch.elapsed,
      totalFrames: 1,
      processedFrames: processedLayers > 0 ? 1 : 0,
    );
  }


  /// Applies simple blur to face regions
  Future<Uint8List> _applySimpleBlur(
    Uint8List imageBytes,
    int width,
    int height,
    List<FaceRegion> faces,
    int blurRadius,
  ) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    for (final face in faces) {
      final left = (face.boundingBox.left * width).toInt().clamp(0, width - 1);
      final top = (face.boundingBox.top * height).toInt().clamp(0, height - 1);
      final faceWidth = (face.boundingBox.width * width).toInt();
      final faceHeight = (face.boundingBox.height * height).toInt();
      final right = (left + faceWidth).clamp(0, width);
      final bottom = (top + faceHeight).clamp(0, height);

      // Apply box blur to face region
      final original = img.Image.from(image);
      for (int y = top; y < bottom; y++) {
        for (int x = left; x < right; x++) {
          int sumR = 0, sumG = 0, sumB = 0, count = 0;
          for (int ky = -blurRadius; ky <= blurRadius; ky++) {
            for (int kx = -blurRadius; kx <= blurRadius; kx++) {
              final sx = (x + kx).clamp(0, width - 1);
              final sy = (y + ky).clamp(0, height - 1);
              final pixel = original.getPixel(sx, sy);
              sumR += pixel.r.toInt();
              sumG += pixel.g.toInt();
              sumB += pixel.b.toInt();
              count++;
            }
          }
          if (count > 0) {
            image.setPixelRgb(x, y, sumR ~/ count, sumG ~/ count, sumB ~/ count);
          }
        }
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
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
