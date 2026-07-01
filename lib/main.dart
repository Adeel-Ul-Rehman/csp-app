// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/services/background/notification_service.dart';
import 'package:css_mastery_app/core/constants/app_theme.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/providers/theme_provider.dart';
import 'package:css_mastery_app/providers/chat_provider.dart';
import 'package:css_mastery_app/providers/datetime_provider.dart';
import 'package:css_mastery_app/providers/export_provider.dart';
import 'package:css_mastery_app/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SyllabusProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DateTimeProvider()),
        ChangeNotifierProvider(create: (_) => ExportProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'CSS Mastery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: context.watch<ThemeProvider>().themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}