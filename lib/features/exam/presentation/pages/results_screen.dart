import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../../../../core/theme.dart';
import 'language_selection_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employee = context.read<AuthBloc>().state.employee;
      final serviceNumber = employee?.serviceNumber ?? '';
      context.read<ExamBloc>().add(FetchResultsRequested(serviceNumber: serviceNumber));
    });
  }

  String _formatArabicDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'كانون الثاني',
      'شباط',
      'آذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين الأول',
      'تشرين الثاني',
      'كانون الأول',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: AppColors.primary,
                size: 22,
              ),
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
        body: BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state.status == ExamStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.fetchedResults.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج بعد',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'يرجى إتمام اختبار أولاً لتتمكن من استعراض نتائجك هنا.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'نتائج الاختبارات المنجزة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.fetchedResults.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final result = state.fetchedResults[index];
                      
                      String langText = '';
                      if (result.language.toLowerCase() == 'english') {
                        langText = 'اللغة الإنجليزية';
                      } else if (result.language.toLowerCase() == 'french') {
                        langText = 'اللغة الفرنسية';
                      } else if (result.language.toLowerCase() == 'russian') {
                        langText = 'اللغة الروسية';
                      } else {
                        langText = result.language;
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'اختبار تحديد المستوى - $langText',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'تاريخ التقديم: ${_formatArabicDate(result.timestamp)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textLight,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: AppColors.border),
                            
                            // Score Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left: score ring
                                SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          width: 76,
                                          height: 76,
                                          child: CircularProgressIndicator(
                                            value: result.score / 100,
                                            strokeWidth: 6,
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                            backgroundColor: const Color(0xFFF1F5F9),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${result.score}',
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textDark,
                                                  ),
                                            ),
                                            const Text(
                                              'من 100',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: AppColors.textLight,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right: Details / Badges
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'إجابات صحيحة: ${result.correctCount}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                                    ),
                                    Text(
                                      'إجابات خاطئة: ${result.incorrectCount}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                    ),
                                    Text(
                                      'الوقت المستغرق: ${result.timeTaken}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Return to Home button
                  OutlinedButton(
                    onPressed: () {
                      context.read<ExamBloc>().add(const ResetExamState());
                      context.goNamed('languageSelection');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'العودة للرئيسية',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      ),
    );
  }
}
