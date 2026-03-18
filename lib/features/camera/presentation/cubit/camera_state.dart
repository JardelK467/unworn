sealed class CameraState {
  const CameraState();
}

final class CameraInitial extends CameraState {
  const CameraInitial();
}

final class CameraCapturing extends CameraState {
  const CameraCapturing();
}

final class CameraPreview extends CameraState {
  const CameraPreview(this.imagePath);
  final String imagePath;
}

final class CameraConfirmed extends CameraState {
  const CameraConfirmed(this.imagePath, {this.userPrompt});
  final String imagePath;
  final String? userPrompt;
}

final class CameraError extends CameraState {
  const CameraError(this.message);
  final String message;
}
