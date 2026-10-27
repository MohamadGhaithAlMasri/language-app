import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../../../../core/theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'اختر اللغة للاختبار',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الرجاء تحديد اللغة التي ترغب في أداء الاختبار بها من القائمة أدناه.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              BlocConsumer<ExamBloc, ExamState>(
                listener: (context, state) {
                  if (state.status == ExamStatus.active) {
                    context.goNamed('exam');
                  }
                },
                builder: (context, state) {
                  if (state.errorMessage == null) return const SizedBox.shrink();
                  final isGenerating = state.status == ExamStatus.loading;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isGenerating ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isGenerating ? const Color(0xFFBFDBFE) : const Color(0xFFFCA5A5),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isGenerating)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                            )
                          else
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isGenerating ? Colors.blue[800] : Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Language Items
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final allowedLanguages = state.employee?.allowedLanguages ?? [];
                  final completedExams = state.employee?.completedExams ?? [];

                  if (allowedLanguages.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.accent,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد لغات مسجلة',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'لم يتم تحديد أي لغات لاختبارها لهذا الحساب حالياً.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: allowedLanguages.map((langEntity) {
                      final lang = langEntity.name;
                      final level = langEntity.level;
                      final isCompleted = completedExams.contains(lang);
                      final key = lang.toLowerCase().trim();
                      final theme =
                          _languageThemes[key] ??
                          _LanguageTheme(
                            title: 'اللغة $lang',
                            nativeName: '$lang Language',
                            icon: Icons.language,
                            baseColor: const Color(0xFF64748B),
                          );

                      final Color iconColor = isCompleted
                          ? AppColors.textLight
                          : theme.baseColor;
                      final Color bgColor = isCompleted
                          ? const Color(0xFFF1F5F9)
                          : theme.baseColor.withValues(alpha: 0.1);
                      final Color borderColor = isCompleted
                          ? AppColors.border
                          : theme.baseColor.withValues(alpha: 0.2);

                      final String title = '${theme.title} - المستوى $level';
                      final String subtitle = isCompleted
                          ? 'تم إنجاز الاختبار مسبقاً'
                          : theme.nativeName;
                      final IconData icon = theme.icon;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildLanguageItem(
                          context: context,
                          title: title,
                          subtitle: subtitle,
                          icon: isCompleted ? Icons.check_circle_outline : icon,
                          iconColor: iconColor,
                          bgColor: bgColor,
                          borderColor: borderColor,
                          isDisabled: isCompleted,
                          onTap: () {
                            if (isCompleted) {
                              _showAlreadyTakenDialog(context);
                            } else {
                              _showExamTermsDialog(context, lang, theme.title);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Bottom Disclaimer Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تظهر هنا فقط اللغات التي تم تسجيلك عليها اثناء استكمال المعلومات.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textLight,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Chevron arrow (Left pointing in RTL)
            Icon(
              Icons.chevron_left,
              color: isDisabled ? Colors.grey[300] : AppColors.textLight,
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDisabled
                        ? AppColors.textLight
                        : AppColors.textDark,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: isDisabled ? AppColors.error : AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlreadyTakenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (diagContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.accent),
              SizedBox(width: 8),
              Text('تنبيه'),
            ],
          ),
          content: const Text(
            'لقد قمت بإجراء هذا الاختبار مسبقاً، لا يمكنك إجراؤه مرة أخرى.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagContext),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExamTermsDialog(
    BuildContext context,
    String language,
    String title,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (diagContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.gavel_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تعليمات وشروط اختبار $title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'يرجى قراءة الشروط والتعليمات التالية بدقة قبل بدء الاختبار:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTermItem(
                  icon: Icons.videocam,
                  text:
                      'سيتم تفعيل الكاميرا الأمامية طوال فترة الاختبار لمراقبة الغش ومطابقة الوجه.',
                ),
                _buildTermItem(
                  icon: Icons.people_outline,
                  text:
                      'يجب تقديم الاختبار بمفردك. ظهور أي شخص آخر أو وجه إضافي سيلغي الاختبار فوراً.',
                ),
                _buildTermItem(
                  icon: Icons.phonelink_erase,
                  text:
                      'يمنع الخروج من التطبيق، أو الرد على المكالمات، أو سحب شريط التنبيهات كي لا يتم إلغاء الاختبار تلقائياً.',
                ),
                _buildTermItem(
                  icon: Icons.block,
                  text:
                      'تم حظر لقطات الشاشة، تسجيل الفيديو، ونسخ أو تحديد النصوص بشكل كامل.',
                ),
                _buildTermItem(
                  icon: Icons.timer,
                  text:
                      'الاختبار محدد بوقت تنازلي، ويجب الإجابة وإنهاء الأسئلة قبل نفاد الوقت لحفظ النتيجة.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagContext),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(diagContext);
                final serviceNumber = context.read<AuthBloc>().state.employee?.serviceNumber ?? '';
                context.read<ExamBloc>().add(
                  StartExamRequested(
                    language: language,
                    serviceNumber: serviceNumber,
                  ),
                );
              },
              child: const Text(
                'أوافق وابدأ الاختبار',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == currentIndex) return;
          if (index == 0) {
            context.goNamed('languageSelection');
          } else if (index == 1) {
            context.goNamed('results');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'الاختبارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'النتائج',
          ),
        ],
      ),
    );
  }
}

class _LanguageTheme {
  final String title;
  final String nativeName;
  final IconData icon;
  final Color baseColor;

  const _LanguageTheme({
    required this.title,
    required this.nativeName,
    required this.icon,
    required this.baseColor,
  });
}

const Map<String, _LanguageTheme> _languageThemes = {
  'english': _LanguageTheme(
    title: 'اللغة الإنجليزية',
    nativeName: 'English Language',
    icon: Icons.language,
    baseColor: Color(0xFF10B981),
  ),
  'french': _LanguageTheme(
    title: 'اللغة الفرنسية',
    nativeName: 'Langue Française',
    icon: Icons.translate,
    baseColor: Color(0xFFF59E0B),
  ),
  'russian': _LanguageTheme(
    title: 'اللغة الروسية',
    nativeName: 'Русский язык',
    icon: Icons.g_translate,
    baseColor: Color(0xFF3B82F6),
  ),
  'german': _LanguageTheme(
    title: 'اللغة الألمانية',
    nativeName: 'Deutsche Sprache',
    icon: Icons.language,
    baseColor: Color(0xFFEF4444),
  ),
  'hungarian': _LanguageTheme(
    title: 'اللغة الهنغارية',
    nativeName: 'Magyar nyelv',
    icon: Icons.language,
    baseColor: Color(0xFF14B8A6),
  ),
  'italian': _LanguageTheme(
    title: 'اللغة الإيطالية',
    nativeName: 'Lingua Italiana',
    icon: Icons.language,
    baseColor: Color(0xFF06B6D4),
  ),
  'spanish': _LanguageTheme(
    title: 'اللغة الإسبانية',
    nativeName: 'Idioma Español',
    icon: Icons.language,
    baseColor: Color(0xFF6366F1),
  ),
  'turkish': _LanguageTheme(
    title: 'اللغة التركية',
    nativeName: 'Türkçe',
    icon: Icons.language,
    baseColor: Color(0xFFF97316),
  ),
  'chinese': _LanguageTheme(
    title: 'اللغة الصينية',
    nativeName: '中文',
    icon: Icons.language,
    baseColor: Color(0xFFEC4899),
  ),
};
