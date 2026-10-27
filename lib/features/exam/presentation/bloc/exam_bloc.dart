import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/exam_repository.dart';
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository examRepository;
  Timer? _timer;

  ExamBloc({required this.examRepository}) : super(const ExamState()) {
    on<StartExamRequested>(_onStartExamRequested);
    on<AnswerSelected>(_onAnswerSelected);
    on<NextQuestionRequested>(_onNextQuestionRequested);
    on<FinishExamRequested>(_onFinishExamRequested);
    on<TimerTicked>(_onTimerTicked);
    on<FetchResultsRequested>(_onFetchResultsRequested);
    on<ResetExamState>(_onResetExamState);
  }

  Future<void> _onStartExamRequested(StartExamRequested event, Emitter<ExamState> emit) async {
    emit(state.copyWith(status: ExamStatus.loading, clearErrorMessage: true));
    
    final result = await examRepository.getQuestions(
      language: event.language,
      serviceNumber: event.serviceNumber,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ExamStatus.failure,
        errorMessage: failure.message,
      )),
      (questions) {
        emit(state.copyWith(
          status: ExamStatus.active,
          selectedLanguage: event.language,
          questions: questions,
          currentQuestionIndex: 0,
          selectedAnswers: {},
          timeRemainingSeconds: 2720,
        ));
        
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          add(const TimerTicked());
        });
      },
    );
  }

  void _onAnswerSelected(AnswerSelected event, Emitter<ExamState> emit) {
    final updatedAnswers = Map<int, int>.from(state.selectedAnswers);
    updatedAnswers[event.questionIndex] = event.optionIndex;
    emit(state.copyWith(selectedAnswers: updatedAnswers));
  }

  void _onNextQuestionRequested(NextQuestionRequested event, Emitter<ExamState> emit) {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
    }
  }

  void _onTimerTicked(TimerTicked event, Emitter<ExamState> emit) {
    if (state.timeRemainingSeconds > 0) {
      emit(state.copyWith(timeRemainingSeconds: state.timeRemainingSeconds - 1));
    }
    // Note: The UI layer will listen to timeRemainingSeconds == 0 and dispatch FinishExamRequested
  }

  Future<void> _onFinishExamRequested(FinishExamRequested event, Emitter<ExamState> emit) async {
    _timer?.cancel();
    emit(state.copyWith(status: ExamStatus.submitting));

    int correct = 0;
    int incorrect = 0;

    for (int i = 0; i < state.questions.length; i++) {
      final selected = state.selectedAnswers[i];
      final correctIdx = state.questions[i].correctOptionIndex;

      if (selected != null) {
        if (selected == correctIdx) {
          correct++;
        } else {
          incorrect++;
        }
      } else {
        incorrect++;
      }
    }

    final totalQuestions = state.questions.isEmpty ? 1 : state.questions.length;
    final scorePercentage = ((correct / totalQuestions) * 100).round();

    final totalDuration = 2720;
    final timeSpent = totalDuration - state.timeRemainingSeconds;
    final minutes = (timeSpent ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeSpent % 60).toString().padLeft(2, '0');
    final timeTakenStr = '$minutes:$seconds';

    final submitDate = DateTime.now();

    final result = await examRepository.submitExam(
      serviceNumber: event.serviceNumber,
      language: state.selectedLanguage!,
      score: scorePercentage,
      correctCount: correct,
      incorrectCount: incorrect,
      timeTaken: timeTakenStr,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ExamStatus.success, // We show success even if it failed but we saved locally, but failure here means even local save failed.
        errorMessage: failure.message,
        correctCount: correct,
        incorrectCount: incorrect,
        timeTakenString: timeTakenStr,
        examSubmissionDate: submitDate,
      )),
      (_) => emit(state.copyWith(
        status: ExamStatus.success,
        correctCount: correct,
        incorrectCount: incorrect,
        timeTakenString: timeTakenStr,
        examSubmissionDate: submitDate,
      )),
    );
  }

  Future<void> _onFetchResultsRequested(FetchResultsRequested event, Emitter<ExamState> emit) async {
    emit(state.copyWith(status: ExamStatus.loading, clearErrorMessage: true));
    
    final result = await examRepository.fetchResults(event.serviceNumber);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ExamStatus.failure,
        errorMessage: failure.message,
      )),
      (results) => emit(state.copyWith(
        status: ExamStatus.resultsLoaded,
        fetchedResults: results,
      )),
    );
  }

  void _onResetExamState(ResetExamState event, Emitter<ExamState> emit) {
    _timer?.cancel();
    emit(const ExamState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
