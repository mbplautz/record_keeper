import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Exports the local SQLite database and image assets as a single ZIP file.
  /// Returns the full path to the generated ZIP.
  static Future<void> exportCollection({
    required String databasePath,
    required String imagesDirectoryPath,
    required String thumbnailsDirectoryPath,
    required BuildContext context,
    String manifestVersion = '1.0.0',
  }) async {
    final tempDir = await getTemporaryDirectory();
    final zipPath = '${tempDir.path}/record_collection_export.zip';

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    // 1 Add the database file
    final dbFile = File(databasePath);
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
    }
    else {
      print ('Database file not found at $databasePath');
    }

    // 2 Add all images
    final imageDir = Directory(imagesDirectoryPath);
    if (await imageDir.exists()) {
      for (final file in imageDir.listSync(recursive: true)) {
        if (file is File) {
          encoder.addFile(file);
        }
      }
    }

    final thumbDir = Directory(thumbnailsDirectoryPath);
    if (await thumbDir.exists()) {
      for (final file in thumbDir.listSync(recursive: true)) {
        if (file is File) {
          encoder.addFile(file);
        }
      }
    }

    // 3 Add manifest.json
    final manifest = {
      'version': manifestVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'db_file': dbFile.uri.pathSegments.last,
    };
    final manifestFile = File('${tempDir.path}/manifest.json');
    await manifestFile.writeAsString(jsonEncode(manifest));
    encoder.addFile(manifestFile);

    encoder.close();

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
