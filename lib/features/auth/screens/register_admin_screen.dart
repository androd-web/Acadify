import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/primary_button.dart';

class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _fonctionController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _fonctionController.dispose();
    _adminCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Inscription Administration', style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informations personnelles',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 24),
              
              _buildLabel('NOM'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(hintText: 'Saisissez votre nom'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('PRÉNOM'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prenomController,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(hintText: 'Saisissez votre prénom'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('ADRESSE EMAIL'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                style: AppTextStyles.bodyMedium,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'votre@email.com'),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('FONCTION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fonctionController,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(hintText: 'ex: Scolarité, Direction'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              
              const SizedBox(height: 40),
              
              // Admin Code Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock, color: AppColors.amber, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code administrateur',
                                style: AppTextStyles.headlineMedium.copyWith(fontSize: 20, color: AppColors.amber),
                              ),
                              Text(
                                'Code confidentiel réservé à la direction',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _adminCodeController,
                      obscureText: true,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        fillColor: AppColors.background,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.amber, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              Text(
                'Créer votre mot de passe',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 24),
              
              _buildLabel('MOT DE PASSE'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Minimum 8 caractères',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('CONFIRMER'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(hintText: 'Ressaisissez le mot de passe'),
                validator: (v) {
                  if (v!.isEmpty) return 'Requis';
                  if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
              
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Créer mon compte',
                backgroundColor: AppColors.amber,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.go('/admin-dashboard');
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Votre compte sera validé avant activation.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(letterSpacing: 1.2),
    );
  }
}

