import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/exam/domain/repositories/exam_repository.dart';
import '../../features/exam/data/repositories/exam_repository_impl.dart';
import '../../features/exam/data/datasources/exam_remote_data_source.dart';
import '../../features/exam/data/datasources/exam_local_data_source.dart';
import '../../features/exam/presentation/bloc/exam_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerFactory(() => ExamBloc(examRepository: sl()));

  sl.registerLazySingleton<ExamRepository>(
    () => ExamRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<ExamRemoteDataSource>(
    () => ExamRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ExamLocalDataSource>(
    () => ExamLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton(() => ApiClient(dio: sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
}
