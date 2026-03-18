import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/repositories/result_repository_impl.dart';
import '../../domain/use_cases/generate_result_use_case.dart';
import 'result_state.dart';

class ResultCubit extends Cubit<ResultState> {
  ResultCubit(this._generateResultUseCase) : super(const ResultLoading());

  final GenerateResultUseCase _generateResultUseCase;

  Future<void> generate(String imagePath, {String? userPrompt}) async {
    emit(const ResultLoading());
    try {
      final results = await _generateResultUseCase(
        imagePath,
        userPrompt: userPrompt,
        onProgress: (progress, stage) {
          emit(ResultLoading(progress: progress, stage: stage));
        },
      );
      if (results.isEmpty) {
        emit(const ResultError(ResultFailureType.invalidGarment));
        return;
      }
      emit(ResultLoaded(results));
    } on SocketException catch (_) {
      emit(const ResultError(ResultFailureType.noInternet));
    } on TimeoutException catch (_) {
      emit(const ResultError(ResultFailureType.noInternet));
    } on http.ClientException catch (_) {
      emit(const ResultError(ResultFailureType.noInternet));
    } on QuotaExceededException catch (_) {
      emit(const ResultError(ResultFailureType.quotaExceeded));
    } on InvalidGarmentException catch (_) {
      emit(const ResultError(ResultFailureType.invalidGarment));
    } on Exception catch (_) {
      emit(const ResultError(ResultFailureType.unknown));
    }
  }
}
