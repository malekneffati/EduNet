// lib/views/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import 'home_view.dart';
import 'login_view.dart';
import 'dashboard_view.dart';
import 'catalog_view.dart';
import 'subscription_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    print("🚀 [APP] Building App");

    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "EduNet",
            theme: ThemeData(
              primaryColor: const Color(0xFF1E3A8A),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A8A),
              ),
            ),

            // ✅ ALWAYS START AT HOME (PUBLIC PAGE)
            home: authViewModel.loading
                ? _buildLoadingScreen()
                : const HomeView(),

            // ✅ DEFINE ALL ROUTES
            routes: {
              '/home': (context) => const HomeView(),
              '/catalog': (context) => const CatalogView(),
              '/subscription': (context) => const SubscriptionView(),
              '/login': (context) => LoginView(
                updateRole: (role) {
                  print("🎯 [APP] Role updated: $role");
                },
              ),
              // ✅ FIXED: Dashboard checks auth but DOESN'T redirect on logout
              '/dashboard': (context) {
                // Check if authenticated
                if (!authViewModel.isAuthenticated) {
                  print("🔒 [APP] Not authenticated - showing login");
                  // Show login instead of redirecting
                  return LoginView(
                    updateRole: (role) {
                      print("🎯 [APP] Role updated: $role");
                    },
                  );
                }
                return const DashboardView();
              },
            },

            // ✅ HANDLE UNKNOWN ROUTES - GO TO HOME (NO BLACK SCREEN)
            onUnknownRoute: (settings) {
              print("⚠️ [APP] Unknown route: ${settings.name} - Redirecting to home");
              return MaterialPageRoute(
                builder: (context) => const HomeView(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Chargement d'EduNet...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}