import 'package:crudapp/info_employee.dart';
import 'package:crudapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:crudapp/screens/not_found.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/main':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => EmployeeInfoScreen(
              username: args['username'],
              isAuthenticated: args['isAuthenticated'],
            ),
          );
        }
        return _errorRoute();
      case 'screens/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundScreen(routeName: settings.name),
        );
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Error: Đối số route không có giá trị')),
      ),
    );
  }
}

class CheckLoginScreen extends StatelessWidget {
  const CheckLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = false;

    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? '/main' : 'screens/login',
      );
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
