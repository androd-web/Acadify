import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _matriculeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserModel? user = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null && mounted) {
          if (user.forcePasswordChange) {
            context.go('/first-login');
          } else {
            // Redirection selon le rôle
            if (user.role == UserRole.student) {
              context.go('/student-dashboard');
            } else if (user.role == UserRole.teacher) {
              context.go('/teacher-dashboard');
            } else if (user.role == UserRole.admin) {
              context.go('/admin-dashboard');
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Grid Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(color: colorScheme.onSurface.withValues(alpha: 0.02)),
            ),
          ),
          // Subtle Top Glow
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Logo with Glow
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.headlineLarge,
                        children: [
                          const TextSpan(text: 'UIECC '),
                          TextSpan(
                            text: 'Sangmélima',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre espace académique intelligent',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 48),
                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context, 'EMAIL'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            style: textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'votre@email.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 24),
                          _buildLabel(context, 'MATRICULE'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _matriculeController,
                            style: textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'Ex: 21A045',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: Validators.validateMatricule,
                          ),
                          const SizedBox(height: 24),
                          _buildLabel(context, 'MOT DE PASSE'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Mot de passe oublié ?',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isLoading 
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                text: 'Se connecter',
                                onPressed: _handleLogin,
                                suffixIcon: Icons.arrow_forward,
                              ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.push('/first-login'),
                              child: Text(
                                'Première connexion ?',
                                style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ? ',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/select-status'),
                          child: Text(
                            'S\'inscrire',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Biometric Button
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                      ),
                      child: Icon(Icons.fingerprint, size: 28, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connexion rapide',
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
          // Offline Status
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mode hors-ligne prêt',
                      style: textTheme.labelMedium?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 24.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

