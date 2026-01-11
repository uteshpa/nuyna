import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:nuyna/domain/entities/face_region.dart';

/// Data source for hand detection using MediaPipe via Platform Channel
/// 
/// This implementation uses a Platform Channel to communicate with
/// native MediaPipe Hands SDK on iOS (Swift) and Android (Kotlin).
class MediaPipeDataSource {
  bool _isInitialized = false;
  
  /// Platform channel for MediaPipe Hands
  static const MethodChannel _channel = MethodChannel('com.nuyna.mediapipe/hands');
  
  /// Initialize the hand detector
  Future<void> initialize() async {
    _isInitialized = true;
  }
  
  /// Detect hands from an image file path
  /// 
  /// Returns a list of [HandDetectionResult] containing landmark positions
  Future<List<HandDetectionResult>> detectHandsFromImagePath(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Placeholder implementation
    // In production, use Platform Channel to call native MediaPipe
    return [];
  }
  
  /// Detect hands from raw image bytes
  /// 
  /// [imageBytes] - Raw image data
  /// [width] - Image width in pixels
  /// [height] - Image height in pixels
  Future<List<HandDetectionResult>> detectHandsFromBytes(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Placeholder implementation
    // In production, use Platform Channel to call native MediaPipe
    return [];
  }
  
  /// Convert hand detection results to FaceRegion format for blur processing
  /// 
  /// This allows unified handling of biometric landmarks (face + hands)
  List<FaceRegion> convertToFaceRegions(List<HandDetectionResult> hands) {
    final regions = <FaceRegion>[];
    
    for (final hand in hands) {
      // Extract fingertip landmarks for Finger Guard
      final fingertipLandmarks = hand.getFingertipLandmarks();
      
      if (fingertipLandmarks.isNotEmpty) {
        // Create a FaceRegion for each hand's fingertips
        regions.add(FaceRegion(
          boundingBox: hand.boundingBox,
          landmarks: fingertipLandmarks,
          confidence: hand.confidence,
        ));
      }
    }
    
    return regions;
  }
  
  /// Release resources
  void close() {
    _isInitialized = false;
  }

  /// Detect hand landmarks for fingerprint scrubbing via Platform Channel
  ///
  /// Returns a list of [HandLandmarkResult] with normalized coordinates
  Future<List<HandLandmarkResult>> detectHandLandmarks(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Call native MediaPipe via Platform Channel
      final result = await _channel.invokeMethod<List<dynamic>>(
        'detectHandLandmarks',
        {
          'imageBytes': imageBytes,
          'width': width,
          'height': height,
        },
      );

      if (result == null || result.isEmpty) {
        return [];
      }

      // Parse the result from native side
      return _parseHandLandmarkResults(result);
    } on PlatformException catch (e) {
      // Platform channel not implemented or error occurred
      print('MediaPipe Platform Channel error: ${e.message}');
      return [];
    } on MissingPluginException {
      // Native implementation not available
      print('MediaPipe native implementation not available');
      return [];
    }
  }

  /// Parse native hand landmark results
  List<HandLandmarkResult> _parseHandLandmarkResults(List<dynamic> results) {
    final handResults = <HandLandmarkResult>[];

    for (final handData in results) {
      if (handData is! Map) continue;

      final landmarksList = handData['landmarks'] as List<dynamic>?;
      if (landmarksList == null) continue;

      final landmarks = <NormalizedLandmark>[];
      for (final lm in landmarksList) {
        if (lm is List && lm.length >= 2) {
          landmarks.add(NormalizedLandmark(
            x: (lm[0] as num).toDouble(),
            y: (lm[1] as num).toDouble(),
            z: lm.length > 2 ? (lm[2] as num).toDouble() : 0.0,
          ));
        }
      }

      if (landmarks.isNotEmpty) {
        handResults.add(HandLandmarkResult(
          landmarks: landmarks,
          handSize: (handData['handSize'] as num?)?.toDouble() ?? 0.1,
          confidence: (handData['confidence'] as num?)?.toDouble() ?? 0.9,
        ));
      }
    }

    return handResults;
  }
}

/// Result containing hand landmarks with normalized coordinates
class HandLandmarkResult {
  /// List of 21 landmark points with normalized (0-1) coordinates
  final List<NormalizedLandmark> landmarks;

  /// Estimated hand size (normalized)
  final double handSize;

  /// Detection confidence
  final double confidence;

  const HandLandmarkResult({
    required this.landmarks,
    required this.handSize,
    required this.confidence,
  });
}

/// Normalized landmark point (0-1 range)
class NormalizedLandmark {
  final double x;
  final double y;
  final double z;

  const NormalizedLandmark({
    required this.x,
    required this.y,
    this.z = 0.0,
  });
}

/// Result of hand detection containing landmarks
class HandDetectionResult {
  /// Bounding box of the detected hand
  final ui.Rect boundingBox;
  
  /// All detected landmarks (21 points per hand)
  final List<HandLandmark> landmarks;
  
  /// Detection confidence (0.0 to 1.0)
  final double confidence;
  
  /// Hand type: left or right
  final HandType handType;
  
  const HandDetectionResult({
    required this.boundingBox,
    required this.landmarks,
    required this.confidence,
    required this.handType,
  });
  
  /// Get fingertip landmarks only (5 points)
  List<ui.Offset> getFingertipLandmarks() {
    final fingertipIndices = [
      HandLandmarkType.thumbTip,
      HandLandmarkType.indexFingerTip,
      HandLandmarkType.middleFingerTip,
      HandLandmarkType.ringFingerTip,
      HandLandmarkType.pinkyTip,
    ];
    
    return landmarks
        .where((l) => fingertipIndices.contains(l.type))
        .map((l) => l.position)
        .toList();
  }
}

/// Individual hand landmark point
class HandLandmark {
  /// Position in image coordinates
  final ui.Offset position;
  
  /// Type of landmark
  final HandLandmarkType type;
  
  /// Confidence for this specific landmark
  final double confidence;
  
  const HandLandmark({
    required this.position,
    required this.type,
    required this.confidence,
  });
}

/// Hand type enumeration
enum HandType {
  left,
  right,
}

/// Hand landmark types (21 points per hand)
enum HandLandmarkType {
  wrist,
  thumbCmc,
  thumbMcp,
  thumbIp,
  thumbTip,
  indexFingerMcp,
  indexFingerPip,
  indexFingerDip,
  indexFingerTip,
  middleFingerMcp,
  middleFingerPip,
  middleFingerDip,
  middleFingerTip,
  ringFingerMcp,
  ringFingerPip,
  ringFingerDip,
  ringFingerTip,
  pinkyMcp,
  pinkyPip,
  pinkyDip,
  pinkyTip,
}
