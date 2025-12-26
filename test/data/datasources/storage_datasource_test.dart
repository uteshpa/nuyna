import 'package:flutter_test/flutter_test.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';

void main() {
  late StorageDataSource dataSource;

  setUp(() {
    dataSource = StorageDataSource();
  });

  group('StorageDataSource', () {
    test('should be instantiable', () {
      expect(dataSource, isNotNull);
    });

    test('should have getTemporaryDirectory method', () {
      expect(dataSource.getTemporaryDirectory, isA<Function>());
    });

    test('should have getApplicationDocumentsDirectory method', () {
      expect(dataSource.getApplicationDocumentsDirectory, isA<Function>());
    });

    test('should have saveFile method', () {
      expect(dataSource.saveFile, isA<Function>());
    });

    test('should have readFile method', () {
      expect(dataSource.readFile, isA<Function>());
    });

    test('should have fileExists method', () {
      expect(dataSource.fileExists, isA<Function>());
    });

    test('should have deleteFile method', () {
      expect(dataSource.deleteFile, isA<Function>());
    });

    test('should have createDirectory method', () {
      expect(dataSource.createDirectory, isA<Function>());
    });

    test('should have deleteDirectory method', () {
      expect(dataSource.deleteDirectory, isA<Function>());
    });

    test('should have listFiles method', () {
      expect(dataSource.listFiles, isA<Function>());
    });
  });
}
