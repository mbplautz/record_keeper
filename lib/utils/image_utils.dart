// lib/utils/image_utils.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();
  static String applicationDocumentsDirectory = '';

  /// Pick an image from the gallery or camera.
  /// [fromCamera] = true to use camera, false to use gallery.
  static Future<File?> pickImage({bool fromCamera = false}) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 90, // compress a little on pick
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  /// Save an image to the app's documents directory.
  /// Returns the saved file path.
  static Future<String> saveImage(File imageFile, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final String imagesDirectoryName = 'images';

    final imagesDir = Directory(p.join(dir.path, imagesDirectoryName));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final name = p.join(imagesDirectoryName, filename ?? p.basename(imageFile.path));
    final newPath = p.join(dir.path, name);
    await imageFile.copy(newPath).then((f) => f.path);
    return name;
  }

  /// Generate a thumbnail (smaller version) of an image and save it.
  /// Returns the saved thumbnail file path.
  static Future<String> generateThumbnail(
    File originalFile, {
    int maxWidth = 200,
    int maxHeight = 200,
    String? filename,
  }) async {
    final bytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      throw Exception("Failed to decode image: ${originalFile.path}");
    }

    final thumbnail = img.copyResize(
      originalImage,
      width: maxWidth,
      height: maxHeight,
      interpolation: img.Interpolation.average,
    );

    final String thumbnailDirectoryName = 'thumbnails';

    final dir = await getApplicationDocumentsDirectory();
    final thumbsDir = Directory(p.join(dir.path, thumbnailDirectoryName));
    if (!await thumbsDir.exists()) {
      await thumbsDir.create(recursive: true);
    }

    final name = p.join(thumbnailDirectoryName, filename ?? "thumb_${p.basename(originalFile.path)}");
    final newPath = p.join(dir.path, name);
    final thumbFile = File(newPath);
    await thumbFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));

    return name;
  }

  /// Delete an image or thumbnail file if it exists.
  static Future<void> deleteImage(String path) async {
    final newPath = p.join(applicationDocumentsDirectory, path);
    final file = File(newPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Load a Flutter Image widget from a file path (safe fallback).
  static Widget loadImageWidget(String? path, {double? width, double? height}) {
    if (path == null || path.isEmpty) {
    //  || !File(path).existsSync()) {
      return const Icon(Icons.image_not_supported);
    }

    final dir = applicationDocumentsDirectory;
    final fullPath = p.join(dir, path);

    if (!File(fullPath).existsSync()) {
      return const Icon(Icons.image_not_supported);
    }

    return Image.file(
      File(fullPath),
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
