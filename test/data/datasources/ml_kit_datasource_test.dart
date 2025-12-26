import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/data/datasources/ml_kit_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MlKitDataSource', () {
    test('should be instantiable', () {
      // Note: This test verifies the class can be instantiated.
      // Actual face detection tests require a device with ML Kit support.
      final dataSource = MlKitDataSource();
      expect(dataSource, isNotNull);
      // Note: dispose() calls FaceDetector.close() which requires platform channel
      // Skip disposal in unit tests - integration tests should test with real platform
    });

    test('should have detectFacesFromImage method', () {
      final dataSource = MlKitDataSource();
      expect(dataSource.detectFacesFromImage, isA<Function>());
    });

    test('should have detectFacesFromBytes method', () {
      final dataSource = MlKitDataSource();
      expect(dataSource.detectFacesFromBytes, isA<Function>());
    });

    test('should have dispose method', () {
      final dataSource = MlKitDataSource();
      expect(dataSource.dispose, isA<Function>());
    });
  });
}
