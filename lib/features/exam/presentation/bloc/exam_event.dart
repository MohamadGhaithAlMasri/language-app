import 'package:equatable/equatable.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

class StartExamRequested extends ExamEvent {
  final String language;
  final String serviceNumber;

  const StartExamRequested({
    required this.language,
    required this.serviceNumber,
  });

  @override
  List<Object?> get props => [language, serviceNumber];
}

class AnswerSelected extends ExamEvent {
  final int questionIndex;
  final int optionIndex;

  const AnswerSelected({
    required this.questionIndex,
    required this.optionIndex,
  });

  @override
  List<Object?> get props => [questionIndex, optionIndex];
}

class NextQuestionRequested extends ExamEvent {
  const NextQuestionRequested();
}

class FinishExamRequested extends ExamEvent {
  final String serviceNumber;
  const FinishExamRequested({required this.serviceNumber});

  @override
  List<Object?> get props => [serviceNumber];
}

class TimerTicked extends ExamEvent {
  const TimerTicked();
}

class FetchResultsRequested extends ExamEvent {
  final String serviceNumber;
  const FetchResultsRequested({required this.serviceNumber});

  @override
  List<Object?> get props => [serviceNumber];
}

class ResetExamState extends ExamEvent {
  const ResetExamState();
}
