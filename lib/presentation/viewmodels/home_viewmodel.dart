import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/core/di/service_locator.dart';
import 'package:nuyna/domain/entities/video_processing_options.dart';
import 'package:nuyna/domain/entities/processed_video.dart';
import 'package:nuyna/domain/usecases/process_media_usecase.dart';

/// State class for the Home screen
class HomeState {
  final String? selectedVideoPath;
  final String? selectedVideoThumbnail;
  final bool isProcessing;
  final double processingProgress;
  final String? errorMessage;
  final ProcessedVideo? processedVideo;
  final VideoProcessingOptions options;

  HomeState({
    this.selectedVideoPath,
    this.selectedVideoThumbnail,
    this.isProcessing = false,
    this.processingProgress = 0.0,
    this.errorMessage,
    this.processedVideo,
    VideoProcessingOptions? options,
  }) : options = options ?? VideoProcessingOptions();

  HomeState copyWith({
    String? selectedVideoPath,
    String? selectedVideoThumbnail,
    bool? isProcessing,
    double? processingProgress,
    String? errorMessage,
    ProcessedVideo? processedVideo,
    VideoProcessingOptions? options,
  }) {
    return HomeState(
      selectedVideoPath: selectedVideoPath ?? this.selectedVideoPath,
      selectedVideoThumbnail: selectedVideoThumbnail ?? this.selectedVideoThumbnail,
      isProcessing: isProcessing ?? this.isProcessing,
      processingProgress: processingProgress ?? this.processingProgress,
      errorMessage: errorMessage,
      processedVideo: processedVideo ?? this.processedVideo,
      options: options ?? this.options,
    );
  }
}

/// ViewModel (Notifier) for the Home screen
/// 
/// Integrates with ProcessMediaUseCase for image and video processing.
class HomeViewModel extends Notifier<HomeState> {
  late final ProcessMediaUseCase _processMediaUseCase;

  @override
  HomeState build() {
    _processMediaUseCase = getIt<ProcessMediaUseCase>();
    return HomeState();
  }

  /// Select a video file
  void selectVideo(String videoPath) {
    state = state.copyWith(
      selectedVideoPath: videoPath,
      errorMessage: null,
      processedVideo: null,
    );
  }

  /// Clear selected video
  void clearSelection() {
    state = HomeState();
  }

  /// Toggle metadata stripping option
  void toggleMetadataStrip() {
    state = state.copyWith(
      options: state.options.copyWith(
        enableMetadataStrip: !state.options.enableMetadataStrip,
      ),
    );
  }

  /// Toggle biometrics (iris + finger guard) option
  void toggleBiometrics() {
    final newIrisBlock = !state.options.enableIrisBlock;
    final newFingerGuard = !state.options.enableFingerGuard;
    state = state.copyWith(
      options: state.options.copyWith(
        enableIrisBlock: newIrisBlock,
        enableFingerGuard: newFingerGuard,
      ),
    );
  }

  /// Toggle face blur option
  void toggleFaceBlur() {
    state = state.copyWith(
      options: state.options.copyWith(
        enableFaceBlur: !state.options.enableFaceBlur,
      ),
    );
  }

  /// Start media processing using ProcessMediaUseCase
  Future<void> processVideo() async {
    if (state.selectedVideoPath == null) {
      state = state.copyWith(errorMessage: 'Please select media first');
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      processingProgress: 0.0,
      errorMessage: null,
    );

    try {
      // Update progress to 10% - starting
      state = state.copyWith(processingProgress: 0.1);

      final result = await _processMediaUseCase.execute(
        mediaPath: state.selectedVideoPath!,
        options: state.options,
      );

      state = state.copyWith(
        isProcessing: false,
        processingProgress: 1.0,
        processedVideo: result,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Processing failed: $e',
      );
    }
  }
}

/// Provider for HomeViewModel
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
