import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/core/di/service_locator.dart';
import 'package:nuyna/presentation/viewmodels/home_viewmodel.dart';

void main() {
  setUpAll(() {
    // Setup DI before tests
    setupLocator();
  });

  tearDownAll(() async {
    await resetLocator();
  });

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
    late ProviderContainer container;
    late HomeViewModel viewModel;

    setUp(() {
      container = ProviderContainer();
      viewModel = container.read(homeViewModelProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have default values', () {
      final state = container.read(homeViewModelProvider);
      expect(state.selectedVideoPath, isNull);
      expect(state.isProcessing, false);
    });

    test('selectVideo should update selectedVideoPath', () {
      viewModel.selectVideo('/path/to/video.mp4');

      final state = container.read(homeViewModelProvider);
      expect(state.selectedVideoPath, '/path/to/video.mp4');
      expect(state.errorMessage, isNull);
    });

    test('clearSelection should reset state to defaults', () {
      viewModel.selectVideo('/path/to/video.mp4');
      viewModel.clearSelection();

      final state = container.read(homeViewModelProvider);
      expect(state.selectedVideoPath, isNull);
      expect(state.isProcessing, false);
    });

    test('toggleMetadataStrip should toggle enableMetadataStrip option', () {
      final initialState = container.read(homeViewModelProvider);
      final initialValue = initialState.options.enableMetadataStrip;

      viewModel.toggleMetadataStrip();

      final state1 = container.read(homeViewModelProvider);
      expect(state1.options.enableMetadataStrip, !initialValue);

      viewModel.toggleMetadataStrip();

      final state2 = container.read(homeViewModelProvider);
      expect(state2.options.enableMetadataStrip, initialValue);
    });

    test('toggleBiometrics should toggle iris and finger guard options', () {
      final initialState = container.read(homeViewModelProvider);
      expect(initialState.options.enableIrisBlock, false);
      expect(initialState.options.enableFingerGuard, false);

      viewModel.toggleBiometrics();

      final state1 = container.read(homeViewModelProvider);
      expect(state1.options.enableIrisBlock, true);
      expect(state1.options.enableFingerGuard, true);

      viewModel.toggleBiometrics();

      final state2 = container.read(homeViewModelProvider);
      expect(state2.options.enableIrisBlock, false);
      expect(state2.options.enableFingerGuard, false);
    });

    test('toggleFaceBlur should toggle enableFaceBlur option', () {
      final initialState = container.read(homeViewModelProvider);
      final initialValue = initialState.options.enableFaceBlur;

      viewModel.toggleFaceBlur();

      final state = container.read(homeViewModelProvider);
      expect(state.options.enableFaceBlur, !initialValue);
    });

    test('processVideo should set error when no video selected', () async {
      await viewModel.processVideo();

      final state = container.read(homeViewModelProvider);
      expect(state.errorMessage, 'Please select a video first');
      expect(state.isProcessing, false);
    });
  });
}
