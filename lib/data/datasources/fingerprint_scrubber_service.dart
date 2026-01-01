import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:nuyna/domain/usecases/scrub_fingerprints_usecase.dart';

/// Service for applying fingerprint smoothing to fingertip regions.
///
/// Uses Gaussian blur to remove high-frequency ridge patterns
/// while preserving the overall finger appearance.
class FingerprintScrubberService {
  
  /// Applies smoothing to specified fingertip regions.
  ///
  /// [imageBytes] - Raw JPEG/PNG image data.
  /// [width] - Image width.
  /// [height] - Image height.
  /// [regions] - List of fingertip regions to smooth.
  /// [smoothingStrength] - Strength of smoothing (0.0-1.0).
  ///
  /// Returns the processed image bytes.
  Future<Uint8List> applySmoothing({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required List<FingertipRegion> regions,
    required double smoothingStrength,
  }) async {
    // Decode image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      return imageBytes;
    }

    // Process each fingertip region
    for (final region in regions) {
      _applySmoothingToRegion(
        image: image,
        centerX: region.centerX,
        centerY: region.centerY,
        radius: region.radius,
        strength: smoothingStrength,
      );
    }

    // Encode back to JPEG
    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  /// Applies Gaussian-like smoothing to a circular region.
  void _applySmoothingToRegion({
    required img.Image image,
    required int centerX,
    required int centerY,
    required int radius,
    required double strength,
  }) {
    final radiusSquared = radius * radius;
    final blurRadius = (radius * 0.3).toInt().clamp(2, 10);

    // Collect pixels within the region
    for (int y = centerY - radius; y <= centerY + radius; y++) {
      for (int x = centerX - radius; x <= centerX + radius; x++) {
        // Check if within image bounds
        if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
          continue;
        }

        // Check if within circular region
        final dx = x - centerX;
        final dy = y - centerY;
        final distanceSquared = dx * dx + dy * dy;

        if (distanceSquared <= radiusSquared) {
          // Calculate blend factor based on distance from center
          final distance = distanceSquared / radiusSquared;
          final blendFactor = strength * (1.0 - distance * 0.5);

          // Apply local average (simple box blur)
          final blurred = _getLocalAverage(image, x, y, blurRadius);
          final original = image.getPixel(x, y);

          // Blend original with blurred
          final r = (original.r * (1 - blendFactor) + blurred.r * blendFactor).toInt();
          final g = (original.g * (1 - blendFactor) + blurred.g * blendFactor).toInt();
          final b = (original.b * (1 - blendFactor) + blurred.b * blendFactor).toInt();

          image.setPixelRgb(x, y, r, g, b);
        }
      }
    }
  }

  /// Gets the local average color around a pixel.
  img.Pixel _getLocalAverage(img.Image image, int cx, int cy, int radius) {
    int sumR = 0, sumG = 0, sumB = 0, count = 0;

    for (int y = cy - radius; y <= cy + radius; y++) {
      for (int x = cx - radius; x <= cx + radius; x++) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          final pixel = image.getPixel(x, y);
          sumR += pixel.r.toInt();
          sumG += pixel.g.toInt();
          sumB += pixel.b.toInt();
          count++;
        }
      }
    }

    if (count == 0) {
      return image.getPixel(cx, cy);
    }

    // Return a pseudo-pixel with average values
    final avgR = sumR ~/ count;
    final avgG = sumG ~/ count;
    final avgB = sumB ~/ count;
    
    // Create a temporary image to get a proper Pixel object
    final tempImg = img.Image(width: 1, height: 1);
    tempImg.setPixelRgb(0, 0, avgR, avgG, avgB);
    return tempImg.getPixel(0, 0);
  }
}
