import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VideoSaverDataSource {
  static const _channel = MethodChannel('com.uteshpa.nuyna/video_saver');

  Future<bool> saveVideoWithoutMetadata(String filePath) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'saveVideoWithoutMetadata',
        {'filePath': filePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to save video: '${e.message}'.");
      return false;
    }
  }
}

