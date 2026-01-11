import 'package:get_it/get_it.dart';

// Data Sources
import 'package:nuyna/data/datasources/ml_kit_datasource.dart';
import 'package:nuyna/data/datasources/ffmpeg_datasource.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';
import 'package:nuyna/data/datasources/mediapipe_datasource.dart';
import 'package:nuyna/data/datasources/image_processing_datasource.dart';
import 'package:nuyna/data/datasources/fingerprint_scrubber_service.dart';
import 'package:nuyna/data/datasources/facial_obfuscator_service.dart';
import 'package:nuyna/data/datasources/settings_datasource.dart';

// Repositories
import 'package:nuyna/domain/repositories/face_detection_repository.dart';
import 'package:nuyna/domain/repositories/video_repository.dart';
import 'package:nuyna/data/repositories/face_detection_repository_impl.dart';
import 'package:nuyna/data/repositories/video_repository_impl.dart';

// UseCases
import 'package:nuyna/domain/usecases/process_video_usecase.dart';
import 'package:nuyna/domain/usecases/process_media_usecase.dart';
import 'package:nuyna/domain/usecases/scrub_fingerprints_usecase.dart';
import 'package:nuyna/domain/usecases/obfuscate_face_usecase.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Setup all dependencies for the application
/// 
/// This function registers all DataSources, Repositories, and UseCases
/// using lazy singleton pattern for optimal memory usage.
void setupLocator() {
  // DataSources
  getIt.registerLazySingleton<MlKitDataSource>(() => MlKitDataSource());
  getIt.registerLazySingleton<FFmpegDataSource>(() => FFmpegDataSource());
  getIt.registerLazySingleton<StorageDataSource>(() => StorageDataSource());
  getIt.registerLazySingleton<MediaPipeDataSource>(() => MediaPipeDataSource());
  getIt.registerLazySingleton<ImageProcessingDataSource>(() => ImageProcessingDataSource());
  
  // Sprint 6: Level 2 Protection Services
  getIt.registerLazySingleton<FingerprintScrubberService>(() => FingerprintScrubberService());
  getIt.registerLazySingleton<FacialObfuscatorService>(() => FacialObfuscatorService());
  
  // Sprint 8: Settings persistence
  getIt.registerLazySingleton<SettingsDataSource>(() => SettingsDataSource());

  // Repositories
  getIt.registerLazySingleton<FaceDetectionRepository>(
    () => FaceDetectionRepositoryImpl(
      mlKitDataSource: getIt<MlKitDataSource>(),
      storageDataSource: getIt<StorageDataSource>(),
    ),
  );
  getIt.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(
      ffmpegDataSource: getIt<FFmpegDataSource>(),
      storageDataSource: getIt<StorageDataSource>(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton<ProcessVideoUseCase>(
    () => ProcessVideoUseCase(
      getIt<VideoRepository>(),
      getIt<FaceDetectionRepository>(),
    ),
  );
  getIt.registerLazySingleton<ProcessMediaUseCase>(
    () => ProcessMediaUseCase(
      getIt<VideoRepository>(),
      getIt<FaceDetectionRepository>(),
      getIt<ImageProcessingDataSource>(),
    ),
  );
  
  // Sprint 6: Level 2 Protection UseCases
  getIt.registerLazySingleton<ScrubFingerprintsUseCase>(
    () => ScrubFingerprintsUseCase(
      getIt<MediaPipeDataSource>(),
      getIt<FingerprintScrubberService>(),
    ),
  );
  getIt.registerLazySingleton<ObfuscateFaceUseCase>(
    () => ObfuscateFaceUseCase(
      getIt<FacialObfuscatorService>(),
      getIt<MlKitDataSource>(),
    ),
  );
}

/// Reset the service locator (useful for testing)
Future<void> resetLocator() async {
  await getIt.reset();
}
