import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/domain/entities/video_processing_options.dart';

void main() {
  group('VideoProcessingOptions', () {
    test('should create instance with default values', () {
      final options = VideoProcessingOptions();

      expect(options.enableFaceBlur, true);
      expect(options.enableIrisBlock, false);
      expect(options.enableFingerGuard, false);
      expect(options.enableMetadataStrip, true);
      expect(options.blurStrength, 15.0);
      expect(options.detectionSensitivity, 0.7);
    });

    test('should create instance with custom values', () {
      final options = VideoProcessingOptions(
        enableFaceBlur: false,
        enableIrisBlock: true,
        enableFingerGuard: true,
        enableMetadataStrip: false,
        blurStrength: 20.0,
        detectionSensitivity: 0.8,
      );

      expect(options.enableFaceBlur, false);
      expect(options.enableIrisBlock, true);
      expect(options.enableFingerGuard, true);
      expect(options.enableMetadataStrip, false);
      expect(options.blurStrength, 20.0);
      expect(options.detectionSensitivity, 0.8);
    });

    group('copyWith', () {
      test('should return same values when no parameters provided', () {
        final options = VideoProcessingOptions();
        final copied = options.copyWith();

        expect(copied.enableFaceBlur, options.enableFaceBlur);
        expect(copied.enableIrisBlock, options.enableIrisBlock);
        expect(copied.enableFingerGuard, options.enableFingerGuard);
        expect(copied.enableMetadataStrip, options.enableMetadataStrip);
        expect(copied.blurStrength, options.blurStrength);
        expect(copied.detectionSensitivity, options.detectionSensitivity);
      });

      test('should update enableFaceBlur when provided', () {
        final options = VideoProcessingOptions(enableFaceBlur: true);
        final copied = options.copyWith(enableFaceBlur: false);

        expect(copied.enableFaceBlur, false);
        expect(copied.enableIrisBlock, options.enableIrisBlock);
      });

      test('should update enableIrisBlock when provided', () {
        final options = VideoProcessingOptions(enableIrisBlock: false);
        final copied = options.copyWith(enableIrisBlock: true);

        expect(copied.enableIrisBlock, true);
      });

      test('should update enableFingerGuard when provided', () {
        final options = VideoProcessingOptions(enableFingerGuard: false);
        final copied = options.copyWith(enableFingerGuard: true);

        expect(copied.enableFingerGuard, true);
      });

      test('should update enableMetadataStrip when provided', () {
        final options = VideoProcessingOptions(enableMetadataStrip: true);
        final copied = options.copyWith(enableMetadataStrip: false);

        expect(copied.enableMetadataStrip, false);
      });

      test('should update blurStrength when provided', () {
        final options = VideoProcessingOptions(blurStrength: 15.0);
        final copied = options.copyWith(blurStrength: 25.0);

        expect(copied.blurStrength, 25.0);
      });

      test('should update detectionSensitivity when provided', () {
        final options = VideoProcessingOptions(detectionSensitivity: 0.7);
        final copied = options.copyWith(detectionSensitivity: 0.9);

        expect(copied.detectionSensitivity, 0.9);
      });

      test('should update multiple values when provided', () {
        final options = VideoProcessingOptions();
        final copied = options.copyWith(
          enableFaceBlur: false,
          blurStrength: 20.0,
          detectionSensitivity: 0.5,
        );

        expect(copied.enableFaceBlur, false);
        expect(copied.blurStrength, 20.0);
        expect(copied.detectionSensitivity, 0.5);
        expect(copied.enableIrisBlock, options.enableIrisBlock);
        expect(copied.enableFingerGuard, options.enableFingerGuard);
        expect(copied.enableMetadataStrip, options.enableMetadataStrip);
      });
    });
  });
}
