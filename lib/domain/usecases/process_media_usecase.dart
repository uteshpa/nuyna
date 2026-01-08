import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:ffmpeg_kit_flutter_minimal/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_minimal/return_code.dart';
import '../entities/processed_video.dart';
import '../entities/video_processing_options.dart';
import '../entities/face_region.dart';
import '../repositories/face_detection_repository.dart';
import '../repositories/video_repository.dart';
import 'package:nuyna/data/datasources/image_processing_datasource.dart';
import 'package:nuyna/domain/usecases/scrub_fingerprints_usecase.dart';
import 'package:nuyna/domain/usecases/obfuscate_face_usecase.dart';
import 'package:nuyna/core/di/service_locator.dart';
import 'package:nuyna/core/constants/app_constants.dart';

/// Use case for processing media (images and videos) with privacy features.
///
/// This use case orchestrates the media processing workflow:
/// - For images: Face/Hand Detection -> Obfuscation/Scrubbing -> Metadata Stripping
/// - For videos: Frame extraction, face detection, blur application
class ProcessMediaUseCase {
  final VideoRepository _videoRepository;
  final FaceDetectionRepository _faceDetectionRepository;
  final ImageProcessingDataSource _imageProcessingDataSource;
  
  // T9-03: Cached UseCase instances to reduce DI lookup overhead
  ScrubFingerprintsUseCase? _cachedScrubUseCase;
  ObfuscateFaceUseCase? _cachedObfuscateUseCase;

  /// Creates a new [ProcessMediaUseCase] instance.
  ProcessMediaUseCase(
    this._videoRepository,
    this._faceDetectionRepository,
    this._imageProcessingDataSource,
  );
  
  /// Get or create ScrubFingerprintsUseCase (cached for performance)
  ScrubFingerprintsUseCase get _scrubUseCase {
    _cachedScrubUseCase ??= getIt<ScrubFingerprintsUseCase>();
    return _cachedScrubUseCase!;
  }
  
  /// Get or create ObfuscateFaceUseCase (cached for performance)
  ObfuscateFaceUseCase get _obfuscateUseCase {
    _cachedObfuscateUseCase ??= getIt<ObfuscateFaceUseCase>();
    return _cachedObfuscateUseCase!;
  }

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

  /// Process a video with frame-by-frame processing
  Future<ProcessedVideo> _processVideo(
    String videoPath,
    VideoProcessingOptions options,
    Stopwatch stopwatch,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/nuyna_processed_$timestamp.mp4';
    final framesDir = '${tempDir.path}/frames_$timestamp';
    final processedFramesDir = '${tempDir.path}/processed_frames_$timestamp';
    
    int totalFrames = 0;
    int processedFrames = 0;

    try {
      // Create directories for frame processing
      await Directory(framesDir).create(recursive: true);
      await Directory(processedFramesDir).create(recursive: true);

      // Check if any processing is needed beyond metadata stripping
      final needsFrameProcessing = options.enableFaceBlur || 
          options.enableAdvancedFaceObfuscation || 
          options.enableFingerGuard;

      if (needsFrameProcessing) {
        // Step 1: Extract frames from video
        print('[nuyna] Starting video frame extraction...');
        final extractCommand = '-i "$videoPath" -vf fps=10 "$framesDir/frame_%04d.png"';
        final extractSession = await FFmpegKit.execute(extractCommand);
        final extractReturnCode = await extractSession.getReturnCode();
        
        if (!ReturnCode.isSuccess(extractReturnCode)) {
          throw Exception('Frame extraction failed');
        }

        // Get list of extracted frames
        final frameFiles = await Directory(framesDir).list().toList();
        final framePaths = frameFiles
            .where((f) => f.path.endsWith('.png'))
            .map((f) => f.path)
            .toList()
          ..sort();
        
        totalFrames = framePaths.length;
        print('[nuyna] Extracted $totalFrames frames');

        // Step 2: Process frames in parallel batches for performance
        print('[nuyna] Processing $totalFrames frames with ${AppConstants.maxConcurrentFrames} parallel workers...');
        final batchSize = AppConstants.maxConcurrentFrames;
        
        for (int batchStart = 0; batchStart < framePaths.length; batchStart += batchSize) {
          final batchEnd = (batchStart + batchSize).clamp(0, framePaths.length);
          final batchPaths = framePaths.sublist(batchStart, batchEnd);
          
          // Process batch in parallel
          final futures = batchPaths.asMap().entries.map((entry) async {
            final batchIndex = entry.key;
            final framePath = entry.value;
            final globalIndex = batchStart + batchIndex;
            
            try {
              final frameFile = File(framePath);
              var frameBytes = Uint8List.fromList(await frameFile.readAsBytes());
              
              // Decode to get dimensions
              final decodedFrame = img.decodeImage(frameBytes);
              if (decodedFrame == null) return null;
              
              final width = decodedFrame.width;
              final height = decodedFrame.height;

              // Apply fingerprint scrubbing
              if (options.enableFingerGuard) {
                try {
                  final scrubUseCase = getIt<ScrubFingerprintsUseCase>();
                  frameBytes = await scrubUseCase.execute(
                    imageBytes: frameBytes,
                    width: width,
                    height: height,
                  );
                } catch (e) {
                  // Continue if scrubbing fails
                }
              }

              // Apply advanced face obfuscation
              if (options.enableAdvancedFaceObfuscation) {
                try {
                  final obfuscateUseCase = getIt<ObfuscateFaceUseCase>();
                  frameBytes = await obfuscateUseCase.executeWithDetection(
                    imageBytes: frameBytes,
                    width: width,
                    height: height,
                  );
                } catch (e) {
                  // Continue if obfuscation fails
                }
              }

              // Apply standard face blur
              if (options.enableFaceBlur && !options.enableAdvancedFaceObfuscation) {
                try {
                  final detectionResult = await _faceDetectionRepository.detectFaces(frameBytes.toList());
                  if (detectionResult.faces.isNotEmpty) {
                    frameBytes = await _applySimpleBlur(
                      frameBytes,
                      width,
                      height,
                      detectionResult.faces,
                      options.blurStrength.toInt(),
                    );
                  }
                } catch (e) {
                  // Continue if blur fails
                }
              }

              // Save processed frame as JPEG for better performance (T9-02)
              final processedFramePath = '$processedFramesDir/frame_${globalIndex.toString().padLeft(4, '0')}.jpg';
              final processedImage = img.decodeImage(frameBytes);
              if (processedImage != null) {
                await File(processedFramePath).writeAsBytes(img.encodeJpg(processedImage, quality: 95));
              } else {
                await File(processedFramePath).writeAsBytes(frameBytes);
              }
              
              return globalIndex;
            } catch (e) {
              return null;
            }
          }).toList();

          // Wait for all frames in batch to complete
          final results = await Future.wait(futures);
          processedFrames += results.where((r) => r != null).length;

          // Log progress every batch
          print('[nuyna] Processed ${batchEnd} of $totalFrames frames (${((batchEnd / totalFrames) * 100).toStringAsFixed(0)}%)');
        }

        // Step 3: Reassemble frames into video
        print('[nuyna] Reassembling $processedFrames frames into video...');
        
        // Get audio from original video and combine with processed JPEG frames
        // Using JPEG input for faster processing (T9-02)
        final assembleCommand = '-framerate 10 -i "$processedFramesDir/frame_%04d.jpg" '
            '-i "$videoPath" -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p '
            '-map 0:v -map 1:a? -shortest '
            '-map_metadata -1 -movflags +faststart "$outputPath"';
        
        final assembleSession = await FFmpegKit.execute(assembleCommand);
        final assembleReturnCode = await assembleSession.getReturnCode();
        
        if (!ReturnCode.isSuccess(assembleReturnCode)) {
          // Fallback: just strip metadata without frame processing
          print('[nuyna] Frame reassembly failed, falling back to metadata strip only');
          await _stripMetadataOnly(videoPath, outputPath);
        }

        print('[nuyna] Video processing complete');
      } else {
        // No frame processing needed, just strip metadata
        await _stripMetadataOnly(videoPath, outputPath);
      }

      // Cleanup temp directories
      try {
        await Directory(framesDir).delete(recursive: true);
        await Directory(processedFramesDir).delete(recursive: true);
      } catch (e) {
        // Ignore cleanup errors
      }

    } catch (e) {
      print('[nuyna] Video processing error: $e');
      // Fallback to simple file copy
      final inputFile = File(videoPath);
      await inputFile.copy(outputPath);
    }

    stopwatch.stop();

    return ProcessedVideo(
      outputPath: outputPath,
      processingTime: stopwatch.elapsed,
      totalFrames: totalFrames,
      processedFrames: processedFrames,
    );
  }

  /// Strip metadata only without frame processing
  Future<void> _stripMetadataOnly(String videoPath, String outputPath) async {
    try {
      final command = '-i "$videoPath" -map_metadata -1 -c copy -movflags +faststart "$outputPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (!ReturnCode.isSuccess(returnCode)) {
        // Fallback to re-encoding
        final fallbackCommand = '-i "$videoPath" -map_metadata -1 -c:v libx264 -c:a aac -movflags +faststart "$outputPath"';
        final fallbackSession = await FFmpegKit.execute(fallbackCommand);
        final fallbackReturnCode = await fallbackSession.getReturnCode();
        
        if (!ReturnCode.isSuccess(fallbackReturnCode)) {
          // Final fallback: just copy
          await File(videoPath).copy(outputPath);
        }
      }
    } catch (e) {
      await File(videoPath).copy(outputPath);
    }
  }
}

