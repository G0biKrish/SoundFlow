import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;

class MetadataScanner {
  final List<String> _supportedExtensions = ['.mp3', '.m4a', '.flac', '.wav'];

  Stream<File> scanDirectory(
    Directory dir, {
    List<String> excludedPaths = const [],
  }) async* {
    if (!await dir.exists()) return;

    yield* _scanRecursive(dir, excludedPaths);
  }

  Stream<File> _scanRecursive(
      Directory dir, List<String> excludedPaths) async* {
    // Check if this directory is explicitly excluded
    if (excludedPaths.any((exclude) => dir.path.startsWith(exclude))) {
      return;
    }

    try {
      final entities = dir.list(recursive: false, followLinks: false);
      await for (final entity in entities) {
        if (entity is Directory) {
          // Skip hidden folders starting with dot
          if (p.basename(entity.path).startsWith('.')) continue;

          yield* _scanRecursive(entity, excludedPaths);
        } else if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (_supportedExtensions.contains(ext)) {
            yield entity;
          }
        }
      }
    } catch (e) {
      // Log error but continue scanning other directories
      print('Error scanning directory ${dir.path}: $e');
    }
  }

  Future<Metadata?> getMetadata(File file) async {
    try {
      return await MetadataRetriever.fromFile(file);
    } catch (e) {
      print('Error parsing metadata for ${file.path}: $e');
      return null;
    }
  }
}
