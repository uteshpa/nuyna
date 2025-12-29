import 'dart:typed_data';

/// Stub data source for ML Kit Face Detection on simulators.
///
/// Returns empty results since ML Kit is not available on simulators.
class MlKitDataSourceStub {
  /// Returns an empty list (no face detection on simulator).
  Future<List<dynamic>> detectFacesFromImage(String imagePath) async {
    return [];
  }

  /// Returns an empty list (no face detection on simulator).
  Future<List<dynamic>> detectFacesFromBytes(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    return [];
  }

  /// No-op dispose.
  void dispose() {}
}
