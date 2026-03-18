import 'dart:io';

class CaptureImageUseCase {
  Future<String> call(String rawPath) async {
    final file = File(rawPath);
    if (!await file.exists()) {
      throw Exception('Captured image file not found');
    }
    return file.path;
  }
}
