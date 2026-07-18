import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';

class GradeDetailScreen extends StatelessWidget {
  const GradeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Détails du module', style: theme.textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            _buildEvaluationList(context),
            const SizedBox(height: 32),
            _buildTeacherComment(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text('ALGORITHMIQUE', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text('16.5 / 20', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 8),
          Text('Rang: 3ème sur 45', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEvaluationList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Évaluations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildEvalItem(context, 'Devoir Surveillé 1', '14.0', '20%'),
        _buildEvalItem(context, 'Partiel Mi-Semestre', '17.5', '30%'),
        _buildEvalItem(context, 'Examen Final', '16.5', '50%'),
      ],
    );
  }

  Widget _buildEvalItem(BuildContext context, String title, String score, String weight) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Coefficient: $weight', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          Text('$score / 20', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTeacherComment(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.comment_outlined, size: 18),
              SizedBox(width: 8),
              Text('Commentaire du Professeur', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Excellente progression ce semestre. Les concepts de structures de données sont bien maîtrisés. Continuez ainsi !',
            style: TextStyle(color: colorScheme.onSurface, height: 1.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
