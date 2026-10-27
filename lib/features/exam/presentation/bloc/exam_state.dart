import 'package:equatable/equatable.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/exam_result_entity.dart';

enum ExamStatus { initial, loading, active, submitting, success, resultsLoaded, failure }

class ExamState extends Equatable {
  final ExamStatus status;
  final String? selectedLanguage;
  final List<QuestionEntity> questions;
  final int currentQuestionIndex;
  final Map<int, int> selectedAnswers;
  final int timeRemainingSeconds;
  
  final int correctCount;
  final int incorrectCount;
  final String timeTakenString;
  final DateTime? examSubmissionDate;
  
  final List<ExamResultEntity> fetchedResults;
  final String? errorMessage;

  const ExamState({
    this.status = ExamStatus.initial,
    this.selectedLanguage,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.timeRemainingSeconds = 2720,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.timeTakenString = '00:00',
    this.examSubmissionDate,
    this.fetchedResults = const [],
    this.errorMessage,
  });

  ExamState copyWith({
    ExamStatus? status,
    String? selectedLanguage,
    List<QuestionEntity>? questions,
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    int? timeRemainingSeconds,
    int? correctCount,
    int? incorrectCount,
    String? timeTakenString,
    DateTime? examSubmissionDate,
    List<ExamResultEntity>? fetchedResults,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ExamState(
      status: status ?? this.status,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      timeTakenString: timeTakenString ?? this.timeTakenString,
      examSubmissionDate: examSubmissionDate ?? this.examSubmissionDate,
      fetchedResults: fetchedResults ?? this.fetchedResults,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedLanguage,
        questions,
        currentQuestionIndex,
        selectedAnswers,
        timeRemainingSeconds,
        correctCount,
        incorrectCount,
        timeTakenString,
        examSubmissionDate,
        fetchedResults,
        errorMessage,
      ];
}
