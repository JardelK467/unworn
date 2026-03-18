import '../entities/garment_result.dart';

typedef ProgressCallback = void Function(double progress, String stage);

abstract class ResultRepository {
  Future<List<GarmentResult>> generateStyles(
    String imagePath, {
    String? userPrompt,
    ProgressCallback? onProgress,
  });
}
