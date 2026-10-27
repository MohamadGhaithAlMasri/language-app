import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/theme.dart';
import '../../../../widgets/syrian_emblem.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const SyrianEmblem(size: 110),
                const SizedBox(height: 16),

                Text(
                  'بوابة اختبار اللغات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'تسجيل الدخول - بيانات الموظف',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.status == AuthStatus.success) {
                      context.goNamed('languageSelection');
                    } else if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          context: context,
                          label: 'الرقم الوظيفي',
                          placeholder: 'أدخل الرقم الوظيفي',
                          icon: Icons.badge_outlined,
                          errorText: state.serviceNumberError,
                          onChanged: (val) => context.read<AuthBloc>().add(
                            LoginFieldChanged(serviceNumber: val),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          context: context,
                          label: 'الاسم الكامل',
                          placeholder: 'الاسم الكامل كما في الهوية',
                          icon: Icons.person_outline,
                          errorText: state.fullNameError,
                          onChanged: (val) => context.read<AuthBloc>().add(
                            LoginFieldChanged(fullName: val),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          context: context,
                          label: 'اسم الأم',
                          placeholder: 'اسم الأم الكامل',
                          icon: Icons.people_outline,
                          errorText: state.motherNameError,
                          onChanged: (val) => context.read<AuthBloc>().add(
                            LoginFieldChanged(motherName: val),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          context: context,
                          label: 'الرقم الوطني',
                          placeholder: 'أدخل الرقم الوطني (11 خانة)',
                          icon: Icons.credit_card_outlined,
                          errorText: state.nationalIdError,
                          keyboardType: TextInputType.number,
                          onChanged: (val) => context.read<AuthBloc>().add(
                            LoginFieldChanged(nationalId: val),
                          ),
                        ),
                        if (state.status == AuthStatus.loading) ...[
                          const SizedBox(height: 12),
                          const Center(child: CircularProgressIndicator()),
                        ],
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    const LoginSubmitted(),
                                  );
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
                                'التحقق والمتابعة',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentLight,
                      ),
                      child: const Icon(
                        Icons.security_outlined,
                        color: AppColors.accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'بوابة إلكترونية مؤمنة - وزارة الداخلية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String placeholder,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
              width: 1,
            ),
          ),
          child: TextField(
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(color: AppColors.error, fontSize: 11),
          ),
        ],
      ],
    );
  }
}
