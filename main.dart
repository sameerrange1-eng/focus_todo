import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FocusTodoApp());
}

class FocusTodoApp extends StatelessWidget {
  const FocusTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Focus Todo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2D5BFF),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2D5BFF),
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
