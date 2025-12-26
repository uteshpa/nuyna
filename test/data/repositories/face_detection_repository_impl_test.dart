import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/core/errors/failures.dart';
import 'package:nuyna/data/datasources/ml_kit_datasource.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';
import 'package:nuyna/data/repositories/face_detection_repository_impl.dart';
import 'package:nuyna/domain/repositories/face_detection_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FaceDetectionRepositoryImpl', () {
    late FaceDetectionRepositoryImpl repository;
    late MlKitDataSource mlKitDataSource;
    late StorageDataSource storageDataSource;

    setUp(() {
      mlKitDataSource = MlKitDataSource();
      storageDataSource = StorageDataSource();
      repository = FaceDetectionRepositoryImpl(
        mlKitDataSource: mlKitDataSource,
        storageDataSource: storageDataSource,
      );
    });

    test('should be instantiable', () {
      expect(repository, isNotNull);
    });

    test('should implement FaceDetectionRepository', () {
      expect(repository, isA<FaceDetectionRepository>());
    });

    test('should have detectFaces method', () {
      expect(repository.detectFaces, isA<Function>());
    });

    test('should have dispose method', () {
      expect(repository.dispose, isA<Function>());
    });

    test('detectFaces should throw FaceDetectionFailure on empty input', () async {
      // Empty image bytes should result in a FaceDetectionFailure
      expect(
        () => repository.detectFaces([]),
        throwsA(isA<FaceDetectionFailure>()),
      );
    });
  });
}
