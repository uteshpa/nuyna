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
  final int frameCount;
  final int facesDetected;
  final Duration totalProcessingTime;
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
  Future<FaceDetectionResult> detectFaces(String imagePath);
  Future<FaceDetectionResult> detectFacesInFrame(List<int> frameData);
}
```

**[video_repository.dart](file:///Users/uenoryouhei/Uteshpa/nuyna/lib/domain/repositories/video_repository.dart)**
```dart
abstract class VideoRepository {
  Future<ProcessedVideo> processVideo(String inputPath, VideoProcessingOptions options);
  Future<List<int>> extractFrame(String videoPath, int frameIndex);
  Future<void> applyBlurToRegions(String inputPath, String outputPath, List<FaceRegion> regions, double blurStrength);
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

## 🧪 Test Coverage

### Test Results Summary

| Category | Tests | Status |
|----------|-------|--------|
| Core Constants | 4 | ✅ Pass |
| Core Failures | 7 | ✅ Pass |
| Domain Entities | 22 | ✅ Pass |
| Domain Use Cases | 10 | ✅ Pass |
| Widget Test | 1 | ⚠️ Needs update |
| **Total** | **60** | **59 Pass / 1 Fail** |

### Test Files

```
test/
├── core/
│   ├── constants/
│   │   └── app_constants_test.dart
│   └── errors/
│       └── failures_test.dart
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

> **Note**: `widget_test.dart` fails because it still tests the default Flutter counter app, not the current main.dart implementation. This should be updated in a future sprint.

---

## 📝 Git History

| Commit | Description |
|--------|-------------|
| `34cbe6f` | chore: add .DS_Store to gitignore |
| `e84850d` | Sprint 1: Core & Domain Layer Foundation |
| `dd2f271` | Setup: Clean Architecture structure with Riverpod and dependencies |
| `a879fde` | Initial Flutter project setup with iOS/Android support |
| `8e7955e` | Initial commit |

---

## 🎯 Next Steps

### Sprint 2: Data Layer Implementation
- [ ] Implement `FaceDetectionRepositoryImpl`
- [ ] Implement `VideoRepositoryImpl`
- [ ] Add FFmpeg integration
- [ ] Add ML Kit face detection

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

## 📂 Repository

- **Remote**: github-nuyna:uteshpa/nuyna.git
- **Branch**: main
- **Status**: ✅ Fully synced with origin
