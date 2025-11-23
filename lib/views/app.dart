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
    print("🚀 [APP] ===== DÉBUT BUILD APP =====");

    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          print("📊 [APP] État AuthViewModel:");
          print("   - loading: ${authViewModel.loading}");
          print("   - isAuthenticated: ${authViewModel.isAuthenticated}");
          print("   - user: ${authViewModel.user?.email}");

          final homeContent = _buildHomeContent(authViewModel);
          print("🏠 [APP] Home content: ${homeContent.runtimeType}");

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "EduNet",
            // ✅ UTILISATION DE HOME (recommandé)
            home: homeContent,
            // ✅ ROUTES POUR LES AUTRES PAGES
            routes: {
              '/login': (context) {
                print("🔄 [ROUTE] Navigation vers /login");
                return LoginView(
                  updateRole: (role) {
                    print("🎯 [ROUTE] Role mis à jour: $role");
                  },
                );
              },
              '/catalog': (context) {
                print("🔄 [ROUTE] Navigation vers /catalog");
                return const CatalogView();
              },
              '/dashboard': (context) {
                print("🔄 [ROUTE] Navigation vers /dashboard");
                return const DashboardView();
              },
              '/subscription': (context) {
                print("🔄 [ROUTE] Navigation vers /subscription");
                return const SubscriptionView();
              },
            },
            onGenerateRoute: (settings) {
              print("🛣️ [ROUTE] onGenerateRoute appelé: ${settings.name}");
              return null;
            },
            onUnknownRoute: (settings) {
              print("❌ [ROUTE] Route inconnue: ${settings.name}");
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Page non trouvée')),
                  body: Center(child: Text('Route ${settings.name} non trouvée')),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(AuthViewModel authViewModel) {
    print("🔄 [APP] Construction du contenu HOME...");

    if (authViewModel.loading) {
      print("⏳ [APP] ÉTAT: Loading - Affichage spinner");
      return _buildLoadingScreen();
    }

    if (authViewModel.isAuthenticated) {
      print("✅ [APP] ÉTAT: Authentifié - Redirection vers HomeView");
      return const HomeView();
    } else {
      print("🔐 [APP] ÉTAT: Non authentifié - Redirection vers LoginView");
      return LoginView(
        updateRole: (role) {
          print("🔄 [APP] Callback updateRole déclenché: $role");
          _handleRoleUpdate(role, authViewModel);
        },
      );
    }
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

  void _handleRoleUpdate(String role, AuthViewModel authViewModel) {
    print("🎯 [APP] Traitement updateRole: $role");

    // Ici vous pouvez mettre à jour le AuthViewModel si nécessaire
    // Par exemple: authViewModel.updateRole(role);

    print("✅ [APP] Role traité: $role");
  }
}