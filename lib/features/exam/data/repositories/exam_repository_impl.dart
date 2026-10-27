import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/exam_result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_data_source.dart';
import '../datasources/exam_local_data_source.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remoteDataSource;
  final ExamLocalDataSource localDataSource;

  ExamRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    required String language,
    required String serviceNumber,
  }) async {
    try {
      final data = await remoteDataSource.getQuestions(
        language: language,
        serviceNumber: serviceNumber,
      );
      final questions = data.map((q) => QuestionEntity.fromJson(Map<String, dynamic>.from(q))).toList();
      return Right(questions);
    } catch (e) {
      if (e is ServerFailure || e is NetworkFailure) {
        return Left(e as Failure);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitExam({
    required String serviceNumber,
    required String language,
    required int score,
    required int correctCount,
    required int incorrectCount,
    required String timeTaken,
  }) async {
    final payload = {
      'serviceNumber': serviceNumber.trim(),
      'language': language,
      'score': score,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'timeTaken': timeTaken,
    };

    try {
      await remoteDataSource.submitExam(payload);
      return const Right(null);
    } catch (e) {
      // Save locally if submission fails
      try {
        final resultData = jsonEncode(payload);
        await localDataSource.savePendingResult(resultData);
        return const Right(null); // Return success since we saved locally
      } catch (e) {
        return Left(CacheFailure('Failed to save exam result locally: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<ExamResultEntity>>> fetchResults(String serviceNumber) async {
    await syncPendingResults();
    try {
      final data = await remoteDataSource.fetchResults(serviceNumber);
      final results = data.map((res) {
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
      return Right(results);
    } catch (e) {
      if (e is ServerFailure || e is NetworkFailure) {
        return Left(e as Failure);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingResults() async {
    try {
      final pending = await localDataSource.getPendingResults();
      if (pending.isEmpty) return const Right(null);

      for (final item in pending) {
        try {
          final data = jsonDecode(item);
          await remoteDataSource.submitExam(data);
          await localDataSource.removePendingResult(item);
        } catch (e) {
          // If a single item fails, keep it and continue
          continue;
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to sync pending results: $e'));
    }
  }
}
