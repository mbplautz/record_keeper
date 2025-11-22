import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:share_plus/share_plus.dart';

class ExportService {
  
  /// Exports the local SQLite database and image assets as a single ZIP file.
  /// Returns the full path to the generated ZIP.
  static void exportCollection({
    required String databasePath,
    required String imagesDirectoryPath,
    required String thumbnailsDirectoryPath,
    required String tempDir,
    required String zipPath,
    String manifestVersion = '1.0.0',
  }) {
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    final errorList = <String>[];

    // 1 Add the database file
    final dbFile = File(databasePath);
    if (dbFile.existsSync()) {
      encoder.addFile(dbFile);
    }
    else {
      errorList.add('Database file not found at $databasePath');
    }

    // 2 Add all images
    final imageDir = Directory(imagesDirectoryPath);
    if (imageDir.existsSync()) {
      for (final file in imageDir.listSync(recursive: true)) {
        if (file is File) {
          encoder.addFile(file);
        }
      }
    }
    else {
      errorList.add('Images directory not found at $imagesDirectoryPath');
    }

    final thumbDir = Directory(thumbnailsDirectoryPath);
    if (thumbDir.existsSync()) {
      for (final file in thumbDir.listSync(recursive: true)) {
        if (file is File) {
          encoder.addFile(file);
        }
      }
    }
    else {
      errorList.add('Thumbnails directory not found at $thumbnailsDirectoryPath');
    }

    // 3 Add manifest.json
    final manifest = <String, dynamic>{
      'version': manifestVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'db_file': dbFile.uri.pathSegments.last,
    };
    if (errorList.isNotEmpty) {
      manifest['errors'] = errorList;
    }
    final manifestFile = File('$tempDir/manifest.json');
    manifestFile.writeAsStringSync(jsonEncode(manifest));
    encoder.addFile(manifestFile);

    encoder.close();

  }

  static Future<void> shareExportedFile(String zipPath, BuildContext context) async {
    final zipFile = File(zipPath);

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      // Mobile: Show native share sheet
      final box = context.findRenderObject() as RenderBox?;

      SharePlus.instance.share(
        ShareParams(
          //text: 'Exported Collection',
          subject: 'Exported Collection',
          files: [XFile(zipFile.path)],
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.macOS ||
               defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.linux) {
      // Desktop: Show save file picker
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Exported Collection',
        fileName: 'collection_export.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (savePath != null) {
        await zipFile.copy(savePath);
      }
    } else {
      // fallback
      print('Export complete: ${zipFile.path}');
    }
  }
}
