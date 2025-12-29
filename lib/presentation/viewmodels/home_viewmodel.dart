import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/domain/entities/video_processing_options.dart';
import 'package:nuyna/domain/entities/processed_video.dart';

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
/// Migration from StateNotifier to Notifier (Riverpod 3.x):
/// - Changed: extends `StateNotifier<HomeState>` → extends `Notifier<HomeState>`
/// - Changed: Constructor removed, replaced with build() method
/// - Unchanged: state getter/setter usage remains the same
class HomeViewModel extends Notifier<HomeState> {
  // Future: Inject UseCases via constructor
  // final ProcessVideoUseCase _processVideoUseCase;

  /// Initialize the state
  /// 
  /// This replaces the constructor in StateNotifier.
  /// The build() method is called once when the provider is first accessed.
  @override
  HomeState build() {
    return HomeState();
  }

  /// Select a video file
  void selectVideo(String videoPath) {
    state = state.copyWith(
      selectedVideoPath: videoPath,
      errorMessage: null,
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

  /// Start video processing
  Future<void> processVideo() async {
    if (state.selectedVideoPath == null) {
      state = state.copyWith(errorMessage: 'Please select a video first');
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      processingProgress: 0.0,
      errorMessage: null,
    );

    try {
      // TODO: Implement actual processing with UseCase
      // Simulate processing for now
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        state = state.copyWith(processingProgress: i / 100);
      }

      state = state.copyWith(
        isProcessing: false,
        processingProgress: 1.0,
        processedVideo: ProcessedVideo(
          outputPath: '${state.selectedVideoPath}_processed.mp4',
          processingTime: const Duration(seconds: 1),
          totalFrames: 100,
          processedFrames: 100,
        ),
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
/// 
/// Migration from StateNotifierProvider to NotifierProvider (Riverpod 3.x):
/// - Changed: `StateNotifierProvider<HomeViewModel, HomeState>` → `NotifierProvider<HomeViewModel, HomeState>`
/// - Changed: Provider constructor syntax simplified
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
