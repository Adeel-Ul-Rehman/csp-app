import 'package:flutter/material.dart';
import 'package:css_mastery_app/routes/app_routes.dart';
import 'package:css_mastery_app/screens/home/home_screen.dart';
import 'package:css_mastery_app/screens/splash/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold(
        body: Center(
          child: Text('Route Error'),
        ),
      );
    });
  }
}
