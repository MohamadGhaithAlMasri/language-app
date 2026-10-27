import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/exam/presentation/bloc/exam_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<ExamBloc>(create: (_) => di.sl<ExamBloc>()),
      ],
      child: MaterialApp.router(
        title: 'language test',
        debugShowCheckedModeBanner: false,
        theme: getAppTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
