import 'package:get_it/get_it.dart';

import '../../features/camera/domain/use_cases/capture_image_use_case.dart';
import '../../features/camera/presentation/cubit/camera_cubit.dart';
import '../../features/result/data/repositories/result_repository_impl.dart';
import '../../features/result/domain/repositories/result_repository.dart';
import '../../features/result/domain/use_cases/generate_result_use_case.dart';
import '../../features/result/presentation/cubit/result_cubit.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<ResultRepository>(() => ResultRepositoryImpl());

  getIt.registerFactory(() => CaptureImageUseCase());
  getIt.registerFactory(() => GenerateResultUseCase(getIt<ResultRepository>()));

  getIt.registerFactory(() => CameraCubit(getIt<CaptureImageUseCase>()));
  getIt.registerFactory(() => ResultCubit(getIt<GenerateResultUseCase>()));
}
