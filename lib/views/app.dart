// lib/views/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../config/app_router.dart';
import '../viewmodels/auth/auth_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    print("🚀 [APP] Building App");

    return ProviderScope(
      child: provider.ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "EduNet",
          theme: ThemeData(
            primaryColor: const Color(0xFF1E3A8A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A),
            ),
          ),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}