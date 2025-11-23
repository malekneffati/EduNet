// lib/components/auth/register_form.dart
// Création de RegisterForm comme dans votre JS RegisterForm.js, adapté à Flutter.
// Utilise RegisterViewModel pour la logique, et appelle onRoleUpdate sur succès.
// Style conservé similaire.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/register_viewmodel.dart';

class RegisterForm extends StatefulWidget {
  final Function(String) onRoleUpdate;

  const RegisterForm({super.key, required this.onRoleUpdate});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, vm, child) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  onChanged: vm.setName,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 16),
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
                      final result = await vm.register();
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
                      : const Text('S\'inscrire'),
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
        },
      ),
    );
  }
}