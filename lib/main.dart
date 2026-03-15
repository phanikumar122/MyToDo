import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await NotificationService().init();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared services
    final authService = AuthService();
    final apiService  = ApiService(getToken: authService.getIdToken);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            apiService:  apiService,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (_) => TaskProvider(api: apiService),
          update: (_, auth, task) {
            if (auth.isLoggedIn && task!.tasks.isEmpty) {
              task.loadTasks();
            }
            return task ?? TaskProvider(api: apiService);
          },
        ),
        ChangeNotifierProvider(
          create: (_) => TimerProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          title:         'To-Do Productivity',
          debugShowCheckedModeBanner: false,
          theme:         lightTheme,
          darkTheme:     darkTheme,
          themeMode:     themeProvider.themeMode,
          home:          const SplashScreen(),
        ),
      ),
    );
  }
}
