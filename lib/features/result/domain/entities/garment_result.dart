import 'dart:typed_data';

class GarmentResult {
  const GarmentResult({
    required this.title,
    required this.style,
    required this.transformation,
    required this.occasion,
    required this.imageBytes,
  });

  final String title;
  final String style;
  final String transformation;
  final String occasion;
  final Uint8List imageBytes;
}
