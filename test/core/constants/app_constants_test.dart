import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('appName should be nuyna', () {
      expect(AppConstants.appName, 'nuyna');
    });

    test('appVersion should be 1.0.0', () {
      expect(AppConstants.appVersion, '1.0.0');
    });

    test('minFaceSize should be 0.15', () {
      expect(AppConstants.minFaceSize, 0.15);
    });

    test('defaultDetectionSensitivity should be 0.7', () {
      expect(AppConstants.defaultDetectionSensitivity, 0.7);
    });

    group('blur strength values', () {
      test('minBlurStrength should be 10.0', () {
        expect(AppConstants.minBlurStrength, 10.0);
      });

      test('defaultBlurStrength should be 15.0', () {
        expect(AppConstants.defaultBlurStrength, 15.0);
      });

      test('maxBlurStrength should be 25.0', () {
        expect(AppConstants.maxBlurStrength, 25.0);
      });

      test('blur strength range should be valid', () {
        expect(AppConstants.minBlurStrength, lessThan(AppConstants.defaultBlurStrength));
        expect(AppConstants.defaultBlurStrength, lessThan(AppConstants.maxBlurStrength));
      });
    });

    test('maxConcurrentFrames should be 4', () {
      expect(AppConstants.maxConcurrentFrames, 4);
    });

    test('processingTimeout should be 10 minutes', () {
      expect(AppConstants.processingTimeout, const Duration(minutes: 10));
      expect(AppConstants.processingTimeout.inMinutes, 10);
    });
  });
}
