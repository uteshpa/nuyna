# nuyna Project Walkthrough

> **Creator's Privacy Toolkit** - Complete offline video privacy protection app  
> **Updated**: 2025-12-26

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
│   └── errors/
│       └── failures.dart
├── data/                  # Data layer (Sprint 2)
│   ├── datasources/
│   │   ├── ml_kit_datasource.dart
│   │   ├── ffmpeg_datasource.dart
│   │   └── storage_datasource.dart
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
└── main.dart
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.0 | State management |
| riverpod | ^2.4.0 | Core Riverpod |
| get_it | ^7.6.0 | Dependency injection |
| intl | ^0.19.0 | Internationalization |
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

## 🧪 Test Coverage

### Test Results Summary

| Category | Tests | Status |
|----------|-------|--------|
| Core Constants | 4 | ✅ Pass |
| Core Failures | 7 | ✅ Pass |
| Domain Entities | 22 | ✅ Pass |
| Domain Use Cases | 10 | ✅ Pass |
| Data Sources | 30 | ✅ Pass |
| Data Repositories | 29 | ✅ Pass |
| Widget Test | 2 | ✅ Pass |
| **Total** | **104** | **104 Pass** |

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
│   │   └── storage_datasource_test.dart
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
└── widget_test.dart
```

---

## 📝 Git History

| Commit | Description |
|--------|-------------|
| `e09d95e` | docs: add session log and update gitignore |
| `e56e3a3` | Sprint 2: Data Layer with Precision Blur |
| `34cbe6f` | chore: add .DS_Store to gitignore |
| `e84850d` | Sprint 1: Core & Domain Layer Foundation |
| `dd2f271` | Setup: Clean Architecture structure with Riverpod and dependencies |
| `a879fde` | Initial Flutter project setup with iOS/Android support |
| `8e7955e` | Initial commit |

---

## 🎯 Next Steps

### Sprint 3: Presentation Layer
- [ ] Create ViewModels
- [ ] Build UI components
- [ ] Implement video player
- [ ] Add processing progress UI

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
