import 'package:equatable/equatable.dart';

class ExamResultEntity extends Equatable {
  final String language;
  final int score;
  final int correctCount;
  final int incorrectCount;
  final String timeTaken;
  final DateTime timestamp;

  const ExamResultEntity({
    required this.language,
    required this.score,
    required this.correctCount,
    required this.incorrectCount,
    required this.timeTaken,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
        language,
        score,
        correctCount,
        incorrectCount,
        timeTaken,
        timestamp,
      ];
}
