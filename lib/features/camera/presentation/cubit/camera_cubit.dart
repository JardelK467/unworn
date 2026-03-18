import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/capture_image_use_case.dart';
import 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit(this._captureImageUseCase) : super(const CameraInitial());

  final CaptureImageUseCase _captureImageUseCase;

  Future<void> onImageCaptured(String rawPath) async {
    emit(const CameraCapturing());
    try {
      final path = await _captureImageUseCase(rawPath);
      emit(CameraPreview(path));
    } on Exception catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  void onImageConfirmed(String imagePath, {String? userPrompt}) {
    emit(CameraConfirmed(imagePath, userPrompt: userPrompt));
  }

  void retake() {
    emit(const CameraInitial());
  }
}
