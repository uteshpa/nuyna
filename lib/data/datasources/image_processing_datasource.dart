import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Data source for processing static images with complete metadata removal.
///
/// This class handles image processing operations including:
/// - Complete EXIF metadata removal (date, location, camera info)
/// - Apple MakerNote and XMP removal
/// - AF (autofocus) point data removal
/// - Re-rendering image at pixel level to strip all embedded data
class ImageProcessingDataSource {
  
  /// Processes an image to remove ALL metadata by re-rendering at pixel level.
  ///
  /// [inputPath] - Path to the input image file.
  /// [outputPath] - Path where the processed image will be saved.
  ///
  /// This method:
  /// 1. Reads raw image bytes
  /// 2. Decodes to raw pixel data using 'image' package
  /// 3. Re-encodes from scratch without any metadata
  /// 4. Saves to output path
  ///
  /// This approach ensures complete removal of:
  /// - EXIF data (date, GPS, camera info)
  /// - Apple MakerNote (AF points, focus areas)
  /// - XMP metadata
  /// - All other embedded data
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
    
    final bytes = await inputFile.readAsBytes();
    
    // Decode image to raw pixel data
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image: $inputPath');
    }
    
    // Create a clean copy of the image (strips all metadata)
    // by creating a new image with just the pixel data
    final cleanImage = img.Image(
      width: image.width,
      height: image.height,
      numChannels: image.numChannels,
    );
    
    // Copy pixel data only, no metadata
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        cleanImage.setPixel(x, y, image.getPixel(x, y));
      }
    }
    
    // Determine output format and encode
    final extension = outputPath.toLowerCase().split('.').last;
    Uint8List outputBytes;
    
    switch (extension) {
      case 'png':
        outputBytes = Uint8List.fromList(img.encodePng(cleanImage));
        break;
      case 'jpg':
      case 'jpeg':
      default:
        // JPEG encoding with no EXIF
        outputBytes = Uint8List.fromList(img.encodeJpg(cleanImage, quality: 95));
        break;
    }
    
    // Write the clean image
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(outputBytes);
    
    return outputPath;
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
