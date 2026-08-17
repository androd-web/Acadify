import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminSecurityScreen extends StatefulWidget {
  const AdminSecurityScreen({super.key});

  @override
  State<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends State<AdminSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_passwordController.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'password': _passwordController.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe mis à jour avec succès !'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : Reconnectez-vous avant de changer le mot de passe.', style: AppTextStyles.bodyMedium),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sécurité du Compte',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20, color: colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MODIFIER LE MOT DE PASSE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Nouveau mot de passe
              Text('Nouveau mot de passe', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                style: AppTextStyles.bodyMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                  if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryAccent),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirmer le mot de passe
              Text('Confirmer le mot de passe', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureText,
                style: AppTextStyles.bodyMedium,
                validator: (value) {
                  if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  prefixIcon: const Icon(Icons.lock_reset, color: AppColors.primaryAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _updatePassword,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Mettre à jour le mot de passe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
