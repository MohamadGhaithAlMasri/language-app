import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/entities/language_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../exam/domain/entities/exam_result_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EmployeeEntity>> login({
    required String serviceNumber,
    required String fullName,
    required String motherName,
    required String nationalId,
  }) async {
    try {
      final data = await remoteDataSource.login(
        serviceNumber: serviceNumber,
        fullName: fullName,
        motherName: motherName,
        nationalId: nationalId,
      );

      final List<LanguageEntity> allowed = (data['employee']['languages'] as List? ?? [])
          .map((langJson) => LanguageEntity.fromJson(Map<String, dynamic>.from(langJson)))
          .toList();
      final List<String> completed = List<String>.from(
        data['employee']['completedExams'] ?? [],
      );
      final List<dynamic> resultsList = data['employee']['allResults'] ?? [];
      
      final List<ExamResultEntity> completedResults = resultsList.map((res) {
        final resMap = Map<String, dynamic>.from(res);
        return ExamResultEntity(
          language: resMap['language'] ?? '',
          score: resMap['score'] ?? 0,
          correctCount: resMap['correctCount'] ?? 0,
          incorrectCount: resMap['incorrectCount'] ?? 0,
          timeTaken: resMap['timeTaken'] ?? '00:00',
          timestamp: resMap['timestamp'] != null
              ? DateTime.tryParse(resMap['timestamp']) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();

      final String sNum = (data['employee']['serviceNumber'] ?? '').toString();

      final employee = EmployeeEntity(
        serviceNumber: sNum,
        allowedLanguages: allowed,
        completedExams: completed,
        allResults: completedResults,
      );

      return Right(employee);
    } catch (e) {
      if (e is ServerFailure) {
        return Left(e);
      } else if (e is NetworkFailure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
