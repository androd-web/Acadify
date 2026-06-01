import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

class SelectStatusScreen extends StatelessWidget {
  const SelectStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppAssets.logo, height: 80),
                const SizedBox(height: 48),
                Text(
                  'Qui êtes-vous ?',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 32,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez votre profil pour continuer.',
                  style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 48),
                _buildRoleCard(
                  context,
                  'Étudiant',
                  'Accédez à vos cours, notes et planning',
                  Icons.school,
                  () => context.push('/register-student'),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context,
                  'Enseignant',
                  'Gérez vos cours et vos étudiants',
                  Icons.co_present,
                  () => context.push('/register-teacher'),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context,
                  'Administration',
                  'Gérez l\'université',
                  Icons.corporate_fare,
                  () => context.push('/register-admin'),
                ),
                const SizedBox(height: 48),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Déjà inscrit ? Se connecter',
                    style: AppTextStyles.labelMedium.copyWith(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: colorScheme.onSurface)),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
