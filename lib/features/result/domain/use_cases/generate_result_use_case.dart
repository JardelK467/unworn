import '../repositories/result_repository.dart';
import '../entities/garment_result.dart';

class GenerateResultUseCase {
  GenerateResultUseCase(this._repository);

  final ResultRepository _repository;

  Future<List<GarmentResult>> call(
    String imagePath, {
    String? userPrompt,
    ProgressCallback? onProgress,
  }) {
    return _repository.generateStyles(
      imagePath,
      userPrompt: userPrompt,
      onProgress: onProgress,
    );
  }
}
