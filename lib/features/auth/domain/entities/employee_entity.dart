import 'package:equatable/equatable.dart';
import 'language_entity.dart';
import '../../../exam/domain/entities/exam_result_entity.dart';

class EmployeeEntity extends Equatable {
  final String serviceNumber;
  final List<LanguageEntity> allowedLanguages;
  final List<String> completedExams;
  final List<ExamResultEntity> allResults;

  const EmployeeEntity({
    required this.serviceNumber,
    required this.allowedLanguages,
    required this.completedExams,
    required this.allResults,
  });

  @override
  List<Object> get props => [serviceNumber, allowedLanguages, completedExams, allResults];
}
