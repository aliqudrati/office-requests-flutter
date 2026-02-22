import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_request_screen.dart';
import 'screens/list_requests_screen.dart';
import 'screens/departments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OfficeRequestsApp());
}

class OfficeRequestsApp extends StatelessWidget {
  const OfficeRequestsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Office Requests',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddRequestScreen(),
        '/list': (context) => const ListRequestsScreen(),
        '/departments': (context) => const DepartmentsScreen(),
      },
    );
  }
}
