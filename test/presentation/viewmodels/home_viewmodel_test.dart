import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/presentation/viewmodels/home_viewmodel.dart';

void main() {
  group('HomeState', () {
    test('should have correct default values', () {
      final state = HomeState();

      expect(state.selectedVideoPath, isNull);
      expect(state.selectedVideoThumbnail, isNull);
      expect(state.isProcessing, false);
      expect(state.processingProgress, 0.0);
      expect(state.errorMessage, isNull);
      expect(state.processedVideo, isNull);
      expect(state.options.enableFaceBlur, true);
      expect(state.options.enableMetadataStrip, true);
    });

    test('copyWith should update selected fields', () {
      final state = HomeState();
      final updated = state.copyWith(
        selectedVideoPath: '/test/video.mp4',
        isProcessing: true,
      );

      expect(updated.selectedVideoPath, '/test/video.mp4');
      expect(updated.isProcessing, true);
      expect(updated.processingProgress, 0.0); // unchanged
    });

    test('copyWith should clear errorMessage when set to null explicitly', () {
      final state = HomeState().copyWith(errorMessage: 'Error');
      expect(state.errorMessage, 'Error');

      final cleared = state.copyWith(errorMessage: null);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('HomeViewModel', () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    test('initial state should have default values', () {
      expect(viewModel.state.selectedVideoPath, isNull);
      expect(viewModel.state.isProcessing, false);
    });

    test('selectVideo should update selectedVideoPath', () {
      viewModel.selectVideo('/path/to/video.mp4');

      expect(viewModel.state.selectedVideoPath, '/path/to/video.mp4');
      expect(viewModel.state.errorMessage, isNull);
    });

    test('clearSelection should reset state to defaults', () {
      viewModel.selectVideo('/path/to/video.mp4');
      viewModel.clearSelection();

      expect(viewModel.state.selectedVideoPath, isNull);
      expect(viewModel.state.isProcessing, false);
    });

    test('toggleMetadataStrip should toggle enableMetadataStrip option', () {
      final initialValue = viewModel.state.options.enableMetadataStrip;
      viewModel.toggleMetadataStrip();

      expect(viewModel.state.options.enableMetadataStrip, !initialValue);

      viewModel.toggleMetadataStrip();
      expect(viewModel.state.options.enableMetadataStrip, initialValue);
    });

    test('toggleBiometrics should toggle iris and finger guard options', () {
      expect(viewModel.state.options.enableIrisBlock, false);
      expect(viewModel.state.options.enableFingerGuard, false);

      viewModel.toggleBiometrics();

      expect(viewModel.state.options.enableIrisBlock, true);
      expect(viewModel.state.options.enableFingerGuard, true);

      viewModel.toggleBiometrics();

      expect(viewModel.state.options.enableIrisBlock, false);
      expect(viewModel.state.options.enableFingerGuard, false);
    });

    test('toggleFaceBlur should toggle enableFaceBlur option', () {
      final initialValue = viewModel.state.options.enableFaceBlur;
      viewModel.toggleFaceBlur();

      expect(viewModel.state.options.enableFaceBlur, !initialValue);
    });

    test('processVideo should set error when no video selected', () async {
      await viewModel.processVideo();

      expect(viewModel.state.errorMessage, 'Please select a video first');
      expect(viewModel.state.isProcessing, false);
    });

    test('processVideo should process selected video', () async {
      viewModel.selectVideo('/path/to/video.mp4');
      await viewModel.processVideo();

      expect(viewModel.state.isProcessing, false);
      expect(viewModel.state.processingProgress, 1.0);
      expect(viewModel.state.processedVideo, isNotNull);
      expect(viewModel.state.errorMessage, isNull);
    });
  });
}
