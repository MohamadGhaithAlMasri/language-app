import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/exam/presentation/pages/language_selection_screen.dart';
import '../../features/exam/presentation/pages/exam_screen.dart';
import '../../features/exam/presentation/pages/results_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        name: 'languageSelection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/exam',
        name: 'exam',
        builder: (context, state) => const ExamScreen(),
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),
    ],
  );
}
