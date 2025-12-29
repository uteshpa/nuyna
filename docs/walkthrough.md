# nuyna Project Walkthrough

> **Creator's Privacy Toolkit** - Complete offline video privacy protection app  
> **Updated**: 2025-12-29

---

## 📋 Project Overview

**nuyna** is a Flutter application designed to provide comprehensive privacy protection for video content creators. The app processes videos entirely offline to blur faces, block irises, and protect sensitive information.

---

## 🏗️ Architecture

The project follows **Clean Architecture** principles with **MVVM** pattern:

```
lib/
├── core/                  # Shared utilities and constants
│   ├── constants/
│   │   └── app_constants.dart
│   ├── di/
│   │   └── service_locator.dart   [Sprint 4]
│   └── errors/
│       └── failures.dart
├── data/                  # Data layer (Sprint 2)
│   ├── datasources/
│   │   ├── ml_kit_datasource.dart
│   │   ├── ffmpeg_datasource.dart
│   │   ├── storage_datasource.dart
│   │   └── mediapipe_datasource.dart
│   └── repositories/
│       ├── face_detection_repository_impl.dart
│       └── video_repository_impl.dart
├── domain/                # Business logic layer
│   ├── entities/
│   │   ├── face_region.dart
│   │   ├── face_detection_result.dart
│   │   ├── processed_video.dart
│   │   └── video_processing_options.dart
│   ├── repositories/
│   │   ├── face_detection_repository.dart
│   │   └── video_repository.dart
│   └── usecases/
│       └── process_video_usecase.dart
├── presentation/          # UI layer (Sprint 3-4)
│   ├── pages/
│   │   └── home_page.dart
│   └── viewmodels/
│       └── home_viewmodel.dart
└── main.dart
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^3.1.0 | State management (Notifier API) |
| riverpod | ^3.1.0 | Core Riverpod |
| get_it | ^9.2.0 | Dependency injection |
| image_picker | ^1.1.2 | Video selection from gallery |
| intl | ^0.20.2 | Internationalization |
| path_provider | ^2.1.0 | File system access |
| google_mlkit_face_detection | ^0.13.1 | Face detection & landmarks |
| ffmpeg_kit_flutter_minimal | ^6.0.8 | Video processing |
| dartz | ^0.10.1 | Functional programming |

---

## ✅ Completed Sprints

### Sprint 1: Core & Domain Layer Foundation

**Commit**: `e84850d` - Sprint 1: Core & Domain Layer Foundation

#### Core Layer

**[app_constants.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/core/constants/app_constants.dart)**
- `defaultBlurStrength`: 15.0
- `defaultDetectionSensitivity`: 0.5
- `maxConcurrentFrames`: 4
- `processingTimeout`: 10 minutes

**[failures.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/core/errors/failures.dart)**
- `Failure` (abstract base class)
- `VideoProcessingFailure`
- `FaceDetectionFailure`
- `StorageFailure`
- `FFmpegFailure`
- `UnknownFailure`

#### Domain Layer - Entities

**[face_region.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/entities/face_region.dart)**
```dart
class FaceRegion {
  final Rect boundingBox;
  final List<Offset> landmarks;
  final double confidence;
}
```

**[face_detection_result.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/entities/face_detection_result.dart)**
```dart
class FaceDetectionResult {
  final List<FaceRegion> faces;
  final double confidence;
  final Duration processingTime;
}
```

**[processed_video.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/entities/processed_video.dart)**
```dart
class ProcessedVideo {
  final String outputPath;
  final Duration processingTime;
  final int totalFrames;
  final int processedFrames;
}
```

**[video_processing_options.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/entities/video_processing_options.dart)**
```dart
class VideoProcessingOptions {
  final bool enableFaceBlur;      // default: true
  final bool enableIrisBlock;     // default: false
  final bool enableFingerGuard;   // default: false
  final bool enableMetadataStrip; // default: true
  final double blurStrength;      // default: 15.0
  final double detectionSensitivity; // default: 0.5
  
  VideoProcessingOptions copyWith({...});
}
```

#### Domain Layer - Repositories

**[face_detection_repository.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/repositories/face_detection_repository.dart)**
```dart
abstract class FaceDetectionRepository {
  Future<FaceDetectionResult> detectFaces(List<int> imageBytes);
}
```

**[video_repository.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/repositories/video_repository.dart)**
```dart
abstract class VideoRepository {
  Future<List<List<int>>> extractFrames(String videoPath);
  Future<String> applyBlur({required String videoPath, required Map<int, List<FaceRegion>> faceRegions, required double blurStrength});
  Future<ProcessedVideo> processVideo({required String videoPath, required Map<int, List<FaceRegion>> faceRegions, required double blurStrength});
}
```

#### Domain Layer - Use Cases

**[process_video_usecase.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/usecases/process_video_usecase.dart)**
```dart
class ProcessVideoUseCase {
  final FaceDetectionRepository faceDetectionRepository;
  final VideoRepository videoRepository;
  
  Future<ProcessedVideo> execute(String inputPath, VideoProcessingOptions options);
}
```

---

### Sprint 2: Data Layer with Precision Blur

#### Data Sources

**[ml_kit_datasource.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/data/datasources/ml_kit_datasource.dart)**
- Uses ML Kit with `enableLandmarks: true` for precision detection
- `detectFacesFromImage(String imagePath)` - File-based detection
- `detectFacesFromBytes(Uint8List imageBytes, int width, int height)` - Bytes-based detection
- Extracts biometric landmarks: eyes, nose, mouth, ears, cheeks

**[ffmpeg_datasource.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/data/datasources/ffmpeg_datasource.dart)**
- `extractFrames(videoPath, outputDir)` - Extract frames at specified FPS
- `applyPrecisionBlurFilter(...)` - Apply blur using landmark coordinates
- `generateLandmarkBlurFilter(...)` - Generate FFmpeg complex filter string
- `getVideoInfo(videoPath)` - Get duration and frame rate

> [!IMPORTANT]
> **Precision Blur Implementation**: Uses `boxblur` with `enable='hypot(X-x,Y-y)<radius'` to blur only small circular areas around each landmark point, not the entire face bounding box.

**[storage_datasource.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/data/datasources/storage_datasource.dart)**
- `getTemporaryDirectory()` / `getApplicationDocumentsDirectory()`
- `saveFile(path, bytes)` / `readFile(path)`
- `createDirectory(path)` / `deleteDirectory(path)`
- `fileExists(path)` / `deleteFile(path)` / `listFiles(path)`

#### Repository Implementations

**[face_detection_repository_impl.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/data/repositories/face_detection_repository_impl.dart)**
- Converts ML Kit `Face` objects to domain `FaceRegion` entities
- Extracts landmarks: leftEye, rightEye, noseBase, mouth points, ears, cheeks
- Handles temporary file creation/cleanup for image processing
- Throws `FaceDetectionFailure` on errors

**[video_repository_impl.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/data/repositories/video_repository_impl.dart)**
- `extractFrames()` - Extract frames and read as bytes
- `applyBlur()` - Validate inputs and apply precision blur filter
- `processVideo()` - Full pipeline with timing and frame counting
- Validates blur strength (10.0-25.0 range)

---

### Sprint 3: Presentation Layer & Finger Guard

**Commit**: `f0fea4f` - Sprint 3: Presentation Layer & Finger Guard

#### Presentation Layer

**[home_page.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/presentation/pages/home_page.dart)**
- Main UI matching wireframe design
- nuyna logo with leaf icon
- Video selection area with dashed border
- Three action buttons: METADATA, BIOMETRICS, FACE
- Toggle states with visual feedback
- DashedBorderPainter for custom border effect

**[home_viewmodel.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/presentation/viewmodels/home_viewmodel.dart)**
- Riverpod StateNotifier pattern
- HomeState with video path, processing status, options
- Methods: selectVideo, clearSelection, toggleMetadataStrip, toggleBiometrics, toggleFaceBlur, processVideo
- Integrated with VideoProcessingOptions

#### Finger Guard Data Source

**[mediapipe_datasource.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/data/datasources/mediapipe_datasource.dart)**
- Hand detection with 21 landmark points
- HandDetectionResult, HandLandmark, HandType, HandLandmarkType
- getFingertipLandmarks() - Extract 5 fingertip positions
- convertToFaceRegions() - Unified biometric landmark format

---

### Sprint 4: Integration & Core Features

**Commit**: `58ef52b` - feat: Sprint 4 - Integration & Core Features

#### Dependency Injection

**[service_locator.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/core/di/service_locator.dart)**
- get_it based service locator
- Registers: DataSources, Repositories, UseCases
- `setupLocator()` called in main() before runApp()
- `resetLocator()` for test cleanup

#### ViewModel Integration

**[home_viewmodel.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/presentation/viewmodels/home_viewmodel.dart)**
- ProcessVideoUseCase injected via get_it
- Real video processing pipeline connected
- Error handling with state updates

#### UI Features

**[home_page.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/presentation/pages/home_page.dart)**
- Video picker via image_picker package
- Process button (visible when video selected)
- Real-time progress display
- Success/Error SnackBar notifications
- ConsumerStatefulWidget for lifecycle management

---

### Sprint 5: Results & Export

**Commit**: `70828a3` - feat: Sprint 5 - Results & Export

#### ResultPage

**[result_page.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/presentation/pages/result_page.dart)**
- Video player with play/pause controls
- Processing stats display (time, frames)
- Save to Gallery button (gallery_saver_plus)
- Share button (share_plus)
- Navigation back to Home

#### Dependencies Added

| Package | Version | Purpose |
|---------|---------|---------|
| video_player | ^2.9.1 | Video playback |
| gallery_saver_plus | ^3.0.5 | Save to device gallery |
| share_plus | ^9.0.0 | Native share sheet |

#### Navigation Flow

- Processing success triggers navigation to ResultPage
- ProcessedVideo passed to ResultPage
- Back button returns to Home

---

## 🧪 Test Coverage

### Test Results Summary

| Category | Tests | Status |
|----------|-------|--------|
| Core Constants | 4 | ✅ Pass |
| Core Failures | 7 | ✅ Pass |
| Domain Entities | 22 | ✅ Pass |
| Domain Use Cases | 10 | ✅ Pass |
| Data Sources | 47 | ✅ Pass |
| Data Repositories | 29 | ✅ Pass |
| Presentation ViewModels | 11 | ✅ Pass |
| Widget Tests | 12 | ✅ Pass |
| **Total** | **136** | **136 Pass** |

### Test Files

```
test/
├── core/
│   ├── constants/
│   │   └── app_constants_test.dart
│   └── errors/
│       └── failures_test.dart
├── data/
│   ├── datasources/
│   │   ├── ffmpeg_datasource_test.dart
│   │   ├── ml_kit_datasource_test.dart
│   │   ├── storage_datasource_test.dart
│   │   └── mediapipe_datasource_test.dart
│   └── repositories/
│       ├── face_detection_repository_impl_test.dart
│       └── video_repository_impl_test.dart
├── domain/
│   ├── entities/
│   │   ├── face_detection_result_test.dart
│   │   ├── face_region_test.dart
│   │   ├── processed_video_test.dart
│   │   └── video_processing_options_test.dart
│   └── usecases/
│       └── process_video_usecase_test.dart
├── presentation/
│   ├── pages/
│   │   └── home_page_test.dart
│   └── viewmodels/
│       └── home_viewmodel_test.dart
└── widget_test.dart
```

---

## 📝 Git History

| Commit | Description |
|--------|-------------|
| `70828a3` | feat: Sprint 5 - Results & Export |
| `58ef52b` | feat: Sprint 4 - Integration & Core Features |
| `f5e8186` | Migrate HomeViewModel to Riverpod 3.1 Notifier pattern |
| `f0fea4f` | Sprint 3: Presentation Layer & Finger Guard |
| `e56e3a3` | Sprint 2: Data Layer with Precision Blur |
| `e84850d` | Sprint 1: Core & Domain Layer Foundation |

---

## 🎯 Next Steps

### Sprint 6: Polish & Optimization
- [ ] Real device testing (iOS/Android)
- [ ] Performance optimization
- [ ] UI/UX improvements
- [ ] Error handling enhancement

---

## 🔧 Development Commands

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

---

## 🛠️ Development Environment

| Tool | Version | Notes |
|------|---------|-------|
| Flutter | 3.x | Dart SDK included |
| Gradle | 9.2.1 | Native installation (Antigravity addon removed) |
| Java | 1.8.0_461 | Oracle Corporation |

---

## 📂 Repository

- **Remote**: github-nuyna:uteshpa/nuyna.git
- **Branch**: main
- **Status**: ✅ Sprint 2 completed and pushed
