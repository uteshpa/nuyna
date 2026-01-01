import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Data source for processing static images with EXIF metadata removal.
///
/// This class handles image processing operations including:
/// - Removing EXIF metadata (date, location, camera info, focus points)
/// - Re-encoding images without metadata using flutter_image_compress
class ImageProcessingDataSource {
  
  /// Processes an image to remove all EXIF metadata.
  ///
  /// [inputPath] - Path to the input image file.
  /// [outputPath] - Path where the processed image will be saved.
  ///
  /// This method uses flutter_image_compress which:
  /// 1. Decodes the image
  /// 2. Re-encodes without EXIF data (keepExif: false is default)
  /// 3. Saves to output path
  ///
  /// Returns the output path on success.
  /// Throws an exception if processing fails.
  Future<String> removeMetadata({
    required String inputPath,
    required String outputPath,
  }) async {
    final inputFile = File(inputPath);
    
    if (!await inputFile.exists()) {
      throw Exception('Input file does not exist: $inputPath');
    }
    
    // Use flutter_image_compress to re-encode without EXIF
    // keepExif defaults to false, which strips all EXIF metadata
    final result = await FlutterImageCompress.compressAndGetFile(
      inputPath,
      outputPath,
      quality: 95,
      keepExif: false, // Explicitly remove all EXIF data
      format: _getCompressFormat(inputPath),
    );
    
    if (result == null) {
      throw Exception('Failed to compress image: $inputPath');
    }
    
    return result.path;
  }
  
  /// Gets the compress format based on file extension.
  CompressFormat _getCompressFormat(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      case 'heic':
      case 'heif':
        // Convert HEIC/HEIF to JPEG for compatibility
        return CompressFormat.jpeg;
      default:
        return CompressFormat.jpeg;
    }
  }
  
  /// Checks if a file is an image based on extension.
  bool isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp'].contains(ext);
  }
  
  /// Gets the output file extension for the processed image.
  /// HEIC/HEIF will be converted to JPEG for compatibility.
  String getOutputExtension(String inputPath) {
    final ext = inputPath.toLowerCase().split('.').last;
    // Convert HEIC/HEIF to JPEG for wider compatibility
    if (ext == 'heic' || ext == 'heif') {
      return 'jpg';
    }
    if (ext == 'png') {
      return 'png';
    }
    return 'jpg';
  }
}
