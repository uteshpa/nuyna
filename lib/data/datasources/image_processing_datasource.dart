import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Data source for processing static images with EXIF metadata removal.
///
/// This class handles image processing operations including:
/// - Decoding images from file
/// - Removing EXIF metadata (date, location, camera info)
/// - Re-encoding images without metadata
class ImageProcessingDataSource {
  
  /// Processes an image to remove all EXIF metadata.
  ///
  /// [inputPath] - Path to the input image file.
  /// [outputPath] - Path where the processed image will be saved.
  ///
  /// This method:
  /// 1. Reads and decodes the image
  /// 2. Re-encodes the image without preserving EXIF data
  /// 3. Saves to output path
  ///
  /// Returns the output path on success.
  /// Throws an exception if processing fails.
  Future<String> removeMetadata({
    required String inputPath,
    required String outputPath,
  }) async {
    final inputFile = File(inputPath);
    final bytes = await inputFile.readAsBytes();
    
    // Decode the image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image: $inputPath');
    }
    
    // Clear EXIF data by re-encoding without metadata
    // The image package does not preserve EXIF by default when encoding
    final extension = outputPath.toLowerCase().split('.').last;
    Uint8List outputBytes;
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        // JPEG encoding without EXIF metadata
        outputBytes = Uint8List.fromList(img.encodeJpg(image, quality: 95));
        break;
      case 'png':
        // PNG encoding (PNG doesn't have EXIF in the same way)
        outputBytes = Uint8List.fromList(img.encodePng(image));
        break;
      case 'webp':
        // WebP encoding
        outputBytes = Uint8List.fromList(img.encodeJpg(image, quality: 95));
        break;
      default:
        // Default to JPEG
        outputBytes = Uint8List.fromList(img.encodeJpg(image, quality: 95));
    }
    
    // Write the processed image
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
    return ext;
  }
}
