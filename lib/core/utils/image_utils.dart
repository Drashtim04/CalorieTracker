import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageUtils {
  /// Compresses and resizes an image for Gemini Vision API.
  /// 
  /// Gemini Vision works best with images that are clear but not excessively large.
  /// Recommended dimensions: ~1024px on the longest side.
  /// Recommended quality: 70-80% to maintain food detail while reducing size.
  static Future<File> optimizeForAi(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );

    if (result == null) return file;

    return File(result.path);
  }

  /// Calculates the file size in MB.
  static double getFileSizeInMb(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
}
