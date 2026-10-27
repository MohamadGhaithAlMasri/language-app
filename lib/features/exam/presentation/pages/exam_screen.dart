import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../../../../core/theme.dart';
import '../../../../widgets/anti_cheat_detector.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.example.language/security');
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secureScreen(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secureScreen(false);
    super.dispose();
  }

  Future<void> _secureScreen(bool secure) async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('secureScreen', {'secure': secure});
      }
    } catch (e) {
      debugPrint('Error modifying screen security flags: $e');
    }
  }

  void _handleCheatingDetected(BuildContext context, String reason) {
    // Cancel the exam and return back to language selection without submitting results
    context.read<ExamBloc>().add(const ResetExamState());
    context.goNamed('languageSelection');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (diagContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
              SizedBox(width: 8),
              Text('تم إلغاء الاختبار تلقائياً'),
            ],
          ),
          content: Text(
            reason,
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(diagContext);
              },
              child: const Text('موافق', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the app is minimized, put to background, or Home button pressed
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Cancel exam and reset state without submitting results
      context.read<ExamBloc>().add(const ResetExamState());
      context.goNamed('languageSelection');
      
      // Show warning toast or scaffold message in background
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إلغاء الاختبار تلقائياً لمحاولتك مغادرة شاشة الامتحان!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          // Cancel the exam and go back to language selection without submitting
          context.read<ExamBloc>().add(const ResetExamState());
          context.goNamed('languageSelection');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إلغاء الاختبار بسبب محاولة الخروج من شاشة الامتحان!',
                textAlign: TextAlign.center,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
        // Wrap the entire screen body in SelectionContainer.disabled to completely block copy-paste/text selection
        child: SelectionContainer.disabled(
          child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'وزارة الداخلية - اختبار اللغات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.border, height: 1),
            ),
          ),
          body: Stack(
            children: [
              BlocConsumer<ExamBloc, ExamState>(
                listener: (context, state) {
                  if (state.status == ExamStatus.success) {
                    if (state.selectedLanguage != null) {
                      context.read<AuthBloc>().add(ExamCompletedEvent(state.selectedLanguage!));
                    }
                    context.goNamed('results');
                  } else if (state.status == ExamStatus.failure && state.errorMessage != null) {
                    if (state.selectedLanguage != null) {
                      context.read<AuthBloc>().add(ExamCompletedEvent(state.selectedLanguage!));
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                    context.goNamed('results'); // Still go to results to show the local save message
                  }
                },
                builder: (context, state) {
                  if (state.questions.isEmpty || state.status == ExamStatus.submitting) {
                    return const Center(child: CircularProgressIndicator());
                  }

              final currentQuestion = state.questions[state.currentQuestionIndex];
              final totalQuestions = state.questions.length;
              final progress = (state.currentQuestionIndex + 1) / totalQuestions;
              final selectedOption = state.selectedAnswers[state.currentQuestionIndex];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upper row containing Timer and Subject
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Current subject
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المادة الحالية',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textLight,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                () {
                                  final selected = state.selectedLanguage?.toLowerCase() ?? '';
                                  if (selected.startsWith('english')) {
                                    return 'اللغة الإنجليزية - تحديد المستوى';
                                  } else if (selected.startsWith('french')) {
                                    return 'اللغة الفرنسية - تحديد المستوى';
                                  } else if (selected.startsWith('russian')) {
                                    return 'اللغة الروسية - تحديد المستوى';
                                  }
                                  return '${state.selectedLanguage} - تحديد المستوى';
                                }(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Timer Block
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1FDF9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD1FAE5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTimer(state.timeRemainingSeconds),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.timer_outlined, color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'السؤال ${state.currentQuestionIndex + 1} من $totalQuestions',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'التقدم',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Question details card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question Header
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accent, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    '${state.currentQuestionIndex + 1}',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'اختر الترجمة الصحيحة للكلمة المظللة في السياق التالي:',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Sentence details block with highlighted word
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: RichText(
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                  height: 1.6,
                                ),
                                children: _buildHighlightedSpans(
                                  sentence: currentQuestion.text,
                                  keyword: currentQuestion.keyword,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Choices
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) => Column(
                        children: [
                          _buildChoiceItem(
                            context: context,
                            label: currentQuestion.options[index],
                            isSelected: selectedOption == index,
                            onTap: () {
                              context.read<ExamBloc>().add(
                                AnswerSelected(questionIndex: state.currentQuestionIndex, optionIndex: index),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        // Next question button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (state.currentQuestionIndex == totalQuestions - 1) {
                                final serviceNumber = context.read<AuthBloc>().state.serviceNumber;
                                context.read<ExamBloc>().add(FinishExamRequested(serviceNumber: serviceNumber));
                              } else {
                                context.read<ExamBloc>().add(const NextQuestionRequested());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.currentQuestionIndex == totalQuestions - 1
                                      ? 'إنهاء وعرض النتائج'
                                      : 'السؤال التالي',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          AntiCheatDetector(
            onMultipleFacesDetected: () {
              _handleCheatingDetected(
                context,
                'تم إلغاء اختبارك وإخراجك فوراً بسبب اكتشاف أكثر من وجه في الكاميرا. لم يتم حفظ أو رفع أي نتيجة.',
              );
            },
            onNoFaceDetected: () {
              _handleCheatingDetected(
                context,
                'تم إلغاء اختبارك وإخراجك فوراً بسبب عدم وجود وجه أمام الكاميرا. لم يتم حفظ أو رفع أي نتيجة.',
              );
            },
          ),
        ],
      ),
    ),
  ),
),
);
  }

  Widget _buildChoiceItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textDark,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedSpans({
    required String sentence,
    required String keyword,
  }) {
    final List<TextSpan> spans = [];
    final lowerSentence = sentence.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    
    int startIndex = lowerSentence.indexOf(lowerKeyword);
    if (startIndex == -1) {
      spans.add(TextSpan(text: sentence));
      return spans;
    }

    if (startIndex > 0) {
      spans.add(TextSpan(text: sentence.substring(0, startIndex)));
    }

    spans.add(TextSpan(
      text: sentence.substring(startIndex, startIndex + keyword.length),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      ),
    ));

    if (startIndex + keyword.length < sentence.length) {
      spans.add(TextSpan(
        text: sentence.substring(startIndex + keyword.length),
      ));
    }

    return spans;
  }


}
