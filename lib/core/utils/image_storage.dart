import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorage {
  static Future<String> saveImage(File imageFile, String taskId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final taskImagesDir = Directory(path.join(appDir.path, 'task_images', taskId));
    if (!await taskImagesDir.exists()) {
      await taskImagesDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final savedFile = await imageFile.copy(path.join(taskImagesDir.path, fileName));
    return savedFile.path;
  }

  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteTaskImages(String taskId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final taskImagesDir = Directory(path.join(appDir.path, 'task_images', taskId));
    if (await taskImagesDir.exists()) {
      await taskImagesDir.delete(recursive: true);
    }
  }
}

