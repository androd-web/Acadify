import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';

class AnnouncementDetail extends StatelessWidget {
  const AnnouncementDetail({super.key});

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
        actions: [
          IconButton(icon: Icon(Icons.share_outlined, color: colorScheme.onSurface), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'URGENT',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Suspension des cours pour la fête de l\'Ascension',
              style: theme.textTheme.headlineLarge?.copyWith(height: 1.2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
                  child: Icon(Icons.admin_panel_settings, size: 16, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Administration Centrale', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text('Publié le 12 Mai 2024 à 10:30', style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Chers étudiants, l\'administration vous informe que l\'ensemble des activités académiques seront suspendues ce Jeudi 14 Mai à l\'occasion de la fête nationale de l\'Ascension.\n\nLes cours reprendront normalement le Vendredi 15 Mai selon l\'emploi du temps habituel. Nous vous encourageons à mettre à profit ce temps pour vos révisions personnelles.\n\nCordialement,\nLe Secrétariat Académique.',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: colorScheme.onSurface.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attachment, color: colorScheme.primary),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calendrier_Semestre_2.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1.4 MB • PDF', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.download_for_offline, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
