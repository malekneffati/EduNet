// lib/views/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import 'home_view.dart';
import 'login_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    print("📱 [APP] Build exécuté");

    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          print("📌 [APP] Auth : loading=${authViewModel.loading}, isAuth=${authViewModel.isAuthenticated}");

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "EduNet",
            home: _buildContent(authViewModel),
          );
        },
      ),
    );
  }

  Widget _buildContent(AuthViewModel authViewModel) {
    if (authViewModel.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return authViewModel.isAuthenticated
        ? const HomeView()
        : LoginView(
      updateRole: (role) {
        print("🟦 Role updated: $role");
      },
    );
  }
}
