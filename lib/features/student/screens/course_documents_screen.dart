import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CourseDocumentsScreen extends StatelessWidget {
  const CourseDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Column(
          children: [
            Text('Algorithmique', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
            Text('12 documents disponibles', style: AppTextStyles.labelSmall),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un document',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _buildFilterChip('Tous', true),
                _buildFilterChip('PDF', false),
                _buildFilterChip('TD', false),
                _buildFilterChip('Examens', false),
                _buildFilterChip('Offline', false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDocCard(context, 'Cours 01 - Introduction', 'Dr. Bakari', '2.4 MB', '12 Oct 2023', true, false),
                _buildDocCard(context, 'TD 02 - Tris & Listes', 'Dr. Bakari', '1.8 MB', '05 Oct 2023', false, true),
                _buildDocCard(context, 'Annale Examen 2022', 'Département', '4.1 MB', '15 Sep 2023', false, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
        labelStyle: TextStyle(color: isActive ? Colors.white : Colors.white38, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, String title, String author, String size, String date, bool isNew, bool isOffline) {
    return GestureDetector(
      onTap: () => context.push('/pdf-viewer'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.description, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('NOUVEAU', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$size • $date • $author', style: AppTextStyles.labelSmall),
                  if (isOffline)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.offline_pin, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('Offline', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(isOffline ? Icons.check_circle : Icons.cloud_download_outlined, color: isOffline ? AppColors.primary : AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

