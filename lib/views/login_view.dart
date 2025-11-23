// lib/views/login_view.dart
// Full version with missing methods added
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[50],
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<LoginViewModel>(
                  builder: (context, vm, child) {
                    return Column(
                      children: [
                        _buildHeader(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Bienvenue sur EduNet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Connectez-vous ou créez un compte pour commencer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => _handleTabChange(true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Column(
              children: [
                Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isLoginTab ? Colors.blue[600] : Colors.grey[500],
                  ),
                ),
                if (_isLoginTab)
                  Container(
                    height: 2,
                    color: Colors.blue[600],
                    margin: const EdgeInsets.only(top: 4),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () => _handleTabChange(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Column(
              children: [
                Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: !_isLoginTab ? Colors.blue[600] : Colors.grey[500],
                  ),
                ),
                if (!_isLoginTab)
                  Container(
                    height: 2,
                    color: Colors.blue[600],
                    margin: const EdgeInsets.only(top: 4),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton(LoginViewModel vm, BuildContext context) {
    return ElevatedButton(
      onPressed: vm.loading
          ? null
          : () async {
        final result = await vm.loginWithGoogle();
        if (result != null) {
          widget.updateRole(result['role'] ?? 'student');
          if (result['role'] == 'admin') {
            Navigator.pushNamed(context, '/admin-dashboard');
          } else {
            Navigator.pushNamed(context, '/dashboard');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? 'Erreur inconnue')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[500],
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: vm.loading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Se connecter avec Google'),
    );
  }
}