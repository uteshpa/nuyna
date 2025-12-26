import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

/// Data source for local storage operations.
///
/// This class provides access to the device's file system for
/// temporary file storage and file operations.
class StorageDataSource {
  /// Gets the temporary directory for storing intermediate files.
  ///
  /// Returns the system's temporary directory.
  Future<Directory> getTemporaryDirectory() async {
    return await path_provider.getTemporaryDirectory();
  }

  /// Gets the application documents directory for persistent storage.
  ///
  /// Returns the app's documents directory.
  Future<Directory> getApplicationDocumentsDirectory() async {
    return await path_provider.getApplicationDocumentsDirectory();
  }

  /// Saves bytes to a file at the specified path.
  ///
  /// [path] - The file path to save to.
  /// [bytes] - The bytes to write.
  ///
  /// Returns the created file.
  Future<File> saveFile(String path, List<int> bytes) async {
    final file = File(path);
    return await file.writeAsBytes(bytes);
  }

  /// Reads bytes from a file.
  ///
  /// [path] - The file path to read from.
  ///
  /// Returns the file contents as bytes.
  Future<List<int>> readFile(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }

  /// Checks if a file exists.
  ///
  /// [path] - The file path to check.
  ///
  /// Returns true if the file exists.
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Deletes a file.
  ///
  /// [path] - The file path to delete.
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Creates a directory if it doesn't exist.
  ///
  /// [path] - The directory path to create.
  ///
  /// Returns the created directory.
  Future<Directory> createDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Deletes a directory and all its contents.
  ///
  /// [path] - The directory path to delete.
  Future<void> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Lists all files in a directory.
  ///
  /// [path] - The directory path to list.
  ///
  /// Returns a list of file paths.
  Future<List<String>> listFiles(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return [];
    }
    final files = await dir.list().toList();
    return files.whereType<File>().map((f) => f.path).toList();
  }
}
