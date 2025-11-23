// lib/components/auth/login_form.dart
// Création de LoginForm comme dans votre JS LoginForm.js, adapté à Flutter.
// Utilise LoginViewModel pour la logique, et appelle onRoleUpdate sur succès.
// Style conservé similaire : champs simples avec décoration, bouton élevé.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

class LoginForm extends StatefulWidget {
  final Function(String) onRoleUpdate;

  const LoginForm({super.key, required this.onRoleUpdate});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoginViewModel>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          TextFormField(
            onChanged: vm.setEmail,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) => value!.isEmpty ? 'Email requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: vm.setPassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) => value!.isEmpty ? 'Mot de passe requis' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: vm.loading
                ? null
                : () async {
              if (_formKey.currentState!.validate()) {
                final result = await vm.login();
                if (result != null) {
                  widget.onRoleUpdate(result['role'] ?? 'student');
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: vm.loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Se connecter'),
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 16),
            Text(
              vm.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}