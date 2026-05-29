import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GradeDetailScreen extends StatelessWidget {
  const GradeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail des notes'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.download_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            _buildCourseHeroCard(),
            
            const SizedBox(height: 32),
            Text('Statistiques académiques', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem('4/120', 'Rang', Icons.emoji_events)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatItem('94%', 'Réussite', Icons.trending_up, color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatItem('12.4', 'Moy. Promo', Icons.groups)),
              ],
            ),
            
            const SizedBox(height: 32),
            Text('Évaluations détaillées', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            _buildEvaluationItem('Examen', '12 Jan 2024', '15.5', 2.0, 'Validé', AppColors.primary),
            _buildEvaluationItem('TD 01', '05 Dec 2023', '18.0', 0.5, 'Excellent', AppColors.amber),
            _buildEvaluationItem('Contrôle Continu', '20 Nov 2023', '17.0', 0.5, 'Validé', AppColors.primary),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Algorithmique & Structure de Données', style: AppTextStyles.headlineMedium.copyWith(fontSize: 22)),
          Text('Semestre 1 • Dr. Bakari', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MOYENNE GÉNÉRALE', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '16.5', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary, fontSize: 32)),
                        TextSpan(text: ' / 20', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Validé', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              // Mini Circular Progress
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: 0.82,
                      strokeWidth: 5,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    Center(child: Text('82%', style: AppTextStyles.labelMedium)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: color)),
          Text(label, style: AppTextStyles.labelMedium.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEvaluationItem(String title, String date, String grade, double coeff, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(date, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: grade, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: color)),
                        TextSpan(text: ' /20', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Text('Coeff: $coeff', style: AppTextStyles.labelMedium.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Théorie', style: TextStyle(fontSize: 10, color: Colors.white38)),
                Row(
                  children: [
                    Icon(status == 'Excellent' ? Icons.star : Icons.check_circle, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

