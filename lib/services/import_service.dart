// lib/services/import_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record_keeper/utils/file_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:version/version.dart';

class ImportService {
  static final _requiredMinimumVersion = '1.0.0';

  static Future<int> importCollection(File zipFile, Database db) async {
    final tempDir = await getTemporaryDirectory();
    final unzipDir = Directory(p.join(tempDir.path, 'import_temp'));
    if (await unzipDir.exists()) await unzipDir.delete(recursive: true);
    await unzipDir.create();

    // 1. Unzip
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = p.join(unzipDir.path, file.name);
      if (file.isFile) {
        final data = file.content as List<int>;
        File(filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }

    // 2. Validate manifest
    final manifestFile = File(p.join(unzipDir.path, 'manifest.json'));
    if (!await manifestFile.exists()) {
      await unzipDir.delete(recursive: true);
      throw Exception("Invalid import: Missing manifest.json");
    }
    final manifestContent = await manifestFile.readAsString();
    final manifest = jsonDecode(manifestContent);
    if (manifest['db_file'] != 'record_keeper.db') {
      await unzipDir.delete(recursive: true);
      throw Exception("Invalid import: Incorrect manifest content");
    }
    final minimumVersion = Version.parse(_requiredMinimumVersion);
    final importVersion = Version.parse(manifest['version'] ?? '0.0.0');
    if (importVersion < minimumVersion) {
      await unzipDir.delete(recursive: true);
      throw Exception("Incompatible import: Export was created with a newer version of the app");
    }

    // 3. Open imported DB
    final importDbPath = p.join(unzipDir.path, 'record_keeper.db');
    final importDb = await openDatabase(importDbPath);

    // 4. ID remapping
    final Map<String, String> albumIdMap = {};
    final Map<int, int> trackIdMap = {};
    final Map<int, int> tagIdMap = {};

    final albums = await importDb.query('albums');
    for (final album in albums) {
      final oldId = album['id'] as String;
      final albumCopy = Map<String, dynamic>.from(album)..remove('id');
      final newId = DateTime.now().microsecondsSinceEpoch.toString();
      albumCopy['id'] = newId;
      albumCopy['cover_image_path'] = album['cover_image_path'] != null
          ? p.join('images', '${newId}_cover.jpg')
          : null;
      albumCopy['cover_thumbnail_path'] = album['cover_thumbnail_path'] != null
          ? p.join('thumbnails', '${newId}_thumb.jpg')
          : null;
      await db.insert('albums', albumCopy);
      albumIdMap[oldId] = newId;
    }

    final tracks = await importDb.query('tracks');
    for (final track in tracks) {
      final oldId = track['id'] as int;
      final oldAlbumId = track['album_id'] as String;
      final newAlbumId = albumIdMap[oldAlbumId];
      if (newAlbumId == null) continue; // Skip orphaned tracks
      final trackCopy = Map<String, dynamic>.from(track)
        ..remove('id');
      trackCopy['album_id'] = newAlbumId;
      final newId = await db.insert('tracks', trackCopy);
      trackIdMap[oldId] = newId;
    }

    final tags = await importDb.query('tags');
    for (final tag in tags) {
      final oldId = tag['id'] as int;
      final oldAlbumId = tag['album_id'] as String;
      final newAlbumId = albumIdMap[oldAlbumId];
      if (newAlbumId == null) continue; // Skip oprhaned tags
      final tagCopy = Map<String, dynamic>.from(tag)
        ..remove('id');
      tagCopy['album_id'] = newAlbumId;
      final newId = await db.insert('tags', tagCopy);
      tagIdMap[oldId] = newId;
    }

    // 5. Image remapping
    final imageDir = Directory(await getImagesDirectoryPath());
    for (final oldId in albumIdMap.keys) {
      final newId = albumIdMap[oldId]!;
      final oldImage = File(p.join(unzipDir.path, '${oldId}_cover.jpg'));
      if (await oldImage.exists()) {
        await oldImage.copy(p.join(imageDir.path, '${newId}_cover.jpg'));
      }

    }

    final thumbnailDir = Directory(await getThumbnailsDirectoryPath());
    for (final oldId in albumIdMap.keys) {
      final newId = albumIdMap[oldId]!;
      final oldImage = File(p.join(unzipDir.path, '${oldId}_thumb.jpg'));
      if (await oldImage.exists()) {
        await oldImage.copy(p.join(thumbnailDir.path, '${newId}_thumb.jpg'));
      }
    }

    await importDb.close();
    await unzipDir.delete(recursive: true);

    return albums.length;
  }

}
