import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:nuyna/domain/usecases/obfuscate_face_usecase.dart';

/// Service for applying advanced facial obfuscation.
///
/// Implements a multi-layered defense mechanism:
/// - Layer 1: Adversarial noise injection
/// - Layer 2: Landmark displacement
/// - Layer 3: High-frequency smoothing
class FacialObfuscatorService {
  final Random _random = Random();

  /// Layer 1: Applies subtle adversarial noise to confuse AI recognition.
  ///
  /// [noiseIntensity] - Intensity of noise (0.0-1.0, recommend 0.02-0.05).
  Future<Uint8List> applyAdversarialNoise({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required FaceRect faceRect,
    required double noiseIntensity,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final maxNoise = (255 * noiseIntensity).toInt();

    for (int y = faceRect.top; y < faceRect.bottom; y++) {
      for (int x = faceRect.left; x < faceRect.right; x++) {
        if (x < 0 || x >= image.width || y < 0 || y >= image.height) continue;

        final pixel = image.getPixel(x, y);
        
        // Add random noise to each channel
        final noiseR = _random.nextInt(maxNoise * 2 + 1) - maxNoise;
        final noiseG = _random.nextInt(maxNoise * 2 + 1) - maxNoise;
        final noiseB = _random.nextInt(maxNoise * 2 + 1) - maxNoise;

        final newR = (pixel.r + noiseR).clamp(0, 255).toInt();
        final newG = (pixel.g + noiseG).clamp(0, 255).toInt();
        final newB = (pixel.b + noiseB).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, newR, newG, newB);
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  /// Layer 2: Applies minute geometric displacements.
  ///
  /// Creates subtle warping that disrupts facial landmark detection.
  /// [displacementStrength] - Strength of displacement (0.0-1.0).
  Future<Uint8List> applyLandmarkDisplacement({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required FaceRect faceRect,
    required double displacementStrength,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Create a copy to read from
    final original = img.Image.from(image);
    final maxDisplacement = (faceRect.width * displacementStrength).toInt().clamp(1, 5);

    for (int y = faceRect.top; y < faceRect.bottom; y++) {
      for (int x = faceRect.left; x < faceRect.right; x++) {
        if (x < 0 || x >= image.width || y < 0 || y >= image.height) continue;

        // Calculate displacement based on position and sine wave
        final normalizedX = (x - faceRect.left) / faceRect.width;
        final normalizedY = (y - faceRect.top) / faceRect.height;
        
        final dx = (sin(normalizedY * pi * 4) * maxDisplacement).toInt();
        final dy = (sin(normalizedX * pi * 4) * maxDisplacement).toInt();

        final srcX = (x + dx).clamp(0, image.width - 1);
        final srcY = (y + dy).clamp(0, image.height - 1);

        final srcPixel = original.getPixel(srcX, srcY);
        image.setPixelRgb(x, y, srcPixel.r.toInt(), srcPixel.g.toInt(), srcPixel.b.toInt());
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  /// Layer 3: Applies smoothing to remove high-frequency details.
  ///
  /// Removes skin texture and fine details that could be used for identification.
  /// [smoothingRadius] - Radius of smoothing kernel (1-5 recommended).
  Future<Uint8List> applySmoothing({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required FaceRect faceRect,
    required int smoothingRadius,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Create a copy to read from
    final original = img.Image.from(image);

    for (int y = faceRect.top; y < faceRect.bottom; y++) {
      for (int x = faceRect.left; x < faceRect.right; x++) {
        if (x < 0 || x >= image.width || y < 0 || y >= image.height) continue;

        // Box blur
        int sumR = 0, sumG = 0, sumB = 0, count = 0;

        for (int ky = -smoothingRadius; ky <= smoothingRadius; ky++) {
          for (int kx = -smoothingRadius; kx <= smoothingRadius; kx++) {
            final sx = x + kx;
            final sy = y + ky;
            
            if (sx >= 0 && sx < original.width && sy >= 0 && sy < original.height) {
              final pixel = original.getPixel(sx, sy);
              sumR += pixel.r.toInt();
              sumG += pixel.g.toInt();
              sumB += pixel.b.toInt();
              count++;
            }
          }
        }

        if (count > 0) {
          image.setPixelRgb(x, y, sumR ~/ count, sumG ~/ count, sumB ~/ count);
        }
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }
}
