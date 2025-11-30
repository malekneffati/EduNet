// lib/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth/login_viewmodel.dart';
import '../components/auth/login_form.dart';
import '../components/auth/register_form.dart';

class LoginView extends StatefulWidget {
  final Function(String) updateRole;

  const LoginView({super.key, required this.updateRole});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoginTab = true;

  void _handleTabChange(bool isLogin) {
    setState(() {
      _isLoginTab = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // gray-50
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448), // max-w-md
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // rounded-2xl
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Consumer<LoginViewModel>(
                builder: (context, vm, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBackArrow(context),   // ✅ ADDED
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildTabSelector(),
                      _isLoginTab
                          ? LoginForm(
                        onRoleUpdate: widget.updateRole,
                      )
                          : RegisterForm(
                        onRoleUpdate: widget.updateRole,
                      ),
                      const SizedBox(height: 24),
                      _buildGoogleLoginButton(vm, context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildBackArrow(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        child: const Icon(
          Icons.arrow_back,
          size: 24,
          color: Colors.black, // Same style as your UI (neutral, simple)
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Bienvenue sur EduNet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous ou créez un compte pour commencer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _handleTabChange(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: _isLoginTab
                      ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  )
                      : null,
                ),
                child: Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isLoginTab
                        ? const Color(0xFF2563EB)
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _handleTabChange(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: !_isLoginTab
                      ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  )
                      : null,
                ),
                child: Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: !_isLoginTab
                        ? const Color(0xFF2563EB)
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleLoginButton(LoginViewModel vm, BuildContext context) {
    return ElevatedButton(
      onPressed: vm.loading
          ? null
          : () async {
        final result = await vm.loginWithGoogle();
        if (result != null && mounted) {
          widget.updateRole(result['role'] ?? 'student');
          if (result['role'] == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (vm.error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF4444), // red-500
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: vm.loading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Text(
        'Se connecter / S\'inscrire avec Google',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}