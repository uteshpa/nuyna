/// Base class for all failure types in the application.
///
/// All specific failure types extend this class to provide
/// a consistent error handling mechanism.
abstract class Failure {
  /// The error message describing the failure.
  final String message;

  /// Creates a new [Failure] instance with the given [message].
  Failure(this.message);
}

/// Failure type for video processing errors.
class VideoProcessingFailure extends Failure {
  /// Creates a new [VideoProcessingFailure] with the given [message].
  VideoProcessingFailure(super.message);
}

/// Failure type for face detection errors.
class FaceDetectionFailure extends Failure {
  /// Creates a new [FaceDetectionFailure] with the given [message].
  FaceDetectionFailure(super.message);
}

/// Failure type for storage-related errors.
class StorageFailure extends Failure {
  /// Creates a new [StorageFailure] with the given [message].
  StorageFailure(super.message);
}

/// Failure type for FFmpeg-related errors.
class FFmpegFailure extends Failure {
  /// Creates a new [FFmpegFailure] with the given [message].
  FFmpegFailure(super.message);
}

/// Failure type for unknown or unexpected errors.
class UnknownFailure extends Failure {
  /// Creates a new [UnknownFailure] with the given [message].
  UnknownFailure(super.message);
}
