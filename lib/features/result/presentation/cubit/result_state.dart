import '../../domain/entities/garment_result.dart';

enum ResultFailureType {
  noInternet,
  quotaExceeded,
  invalidGarment,
  unknown,
}

sealed class ResultState {
  const ResultState();
}

final class ResultLoading extends ResultState {
  const ResultLoading({this.progress = 0, this.stage = ''});
  final double progress;
  final String stage;
}

final class ResultLoaded extends ResultState {
  const ResultLoaded(this.results);
  final List<GarmentResult> results;
}

final class ResultError extends ResultState {
  const ResultError(this.type);
  final ResultFailureType type;
}
