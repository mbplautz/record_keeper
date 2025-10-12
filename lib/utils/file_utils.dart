import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:sqflite/sqflite.dart';

Future<String> getDatabasePath() async {
  final docsDir = await getDatabasesPath();
  return p.join(docsDir, 'record_keeper.db');
}

Future<String> getImagesDirectoryPath() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docsDir.path, 'images'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir.path;
}

Future<String> getThumbnailsDirectoryPath() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docsDir.path, 'thumbnails'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir.path;
}