import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScheduleDetailScreen extends StatelessWidget {
  const ScheduleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Détail du cours'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            _buildMainHeroCard(),
            
            const SizedBox(height: 24),
            // Info Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildInfoGridItem(Icons.meeting_room, 'Salle', 'Amphi A'),
                _buildInfoGridItem(Icons.school, 'Filière', 'Génie Logiciel'),
                _buildInfoGridItem(Icons.trending_up, 'Niveau', 'Licence 2'),
                _buildInfoGridItem(Icons.timer, 'Durée', '2h'),
              ],
            ),
            
            const SizedBox(height: 32),
            Text('Objectifs du jour', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Text(
                'Introduction aux Arbres Binaires de Recherche (ABR). Optimisation des recherches et structures arborescentes complexes.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Documents attachés', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            _buildAttachedFileItem('Support de cours - ABR.pdf', true),
            _buildAttachedFileItem('Exercices TD 04.pdf', false),
            _buildAttachedFileItem('Ressources Complémentaires.zip', false),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push('/pdf-viewer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.open_in_new, color: Color(0xFF06090A)),
                    const SizedBox(width: 8),
                    Text('OUVRIR LE PDF', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF06090A), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppColors.primaryContainer),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('AJOUTER UN RAPPEL', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('En cours', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Text('Cours Magistral', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Algorithmique & Structure de Données', style: AppTextStyles.headlineLarge.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Text('Dr. Bakari', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoRow(Icons.schedule, '08:30 - 10:30'),
              const SizedBox(width: 24),
              _buildInfoRow(Icons.location_on, 'Amphi A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGridItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachedFileItem(String filename, bool isOffline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(
              filename.endsWith('.zip') ? Icons.folder_zip : Icons.picture_as_pdf,
              color: filename.endsWith('.zip') ? AppColors.amber : AppColors.alertRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filename, style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis),
                if (isOffline)
                  Row(
                    children: [
                      const Icon(Icons.offline_pin, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Disponible hors-ligne', style: AppTextStyles.labelMedium.copyWith(fontSize: 10, color: AppColors.primary.withValues(alpha: 0.8))),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.download_outlined, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

