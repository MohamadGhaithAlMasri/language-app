import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/question_entity.dart';
import '../entities/exam_result_entity.dart';

abstract class ExamRepository {
  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    required String language,
    required String serviceNumber,
  });
  
  Future<Either<Failure, void>> submitExam({
    required String serviceNumber,
    required String language,
    required int score,
    required int correctCount,
    required int incorrectCount,
    required String timeTaken,
  });
  
  Future<Either<Failure, List<ExamResultEntity>>> fetchResults(String serviceNumber);
  
  Future<Either<Failure, void>> syncPendingResults();
}
