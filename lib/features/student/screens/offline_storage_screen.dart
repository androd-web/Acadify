import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OfflineStorageScreen extends StatelessWidget {
  const OfflineStorageScreen({super.key});

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
        title: Text('Gestion du stockage', style: theme.textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageSummary(context),
            const SizedBox(height: 32),
            const Text('Fichiers téléchargés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFileItem(context, 'Cours_Algorithmique_S1.pdf', '3.2 MB', Icons.description),
            _buildFileItem(context, 'TD2_Reseaux.pdf', '1.8 MB', Icons.description),
            _buildFileItem(context, 'Annales_Maths_2023.pdf', '4.5 MB', Icons.description),
            const SizedBox(height: 32),
            _buildClearAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Espace occupé', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('9.5 MB / 500 MB', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.019,
              minHeight: 10,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, String name, String size, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(size, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildClearAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text('Libérer de l\'espace', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 8),
          const Text(
            'Ceci supprimera tous les fichiers téléchargés. Vous devrez les télécharger à nouveau pour les lire hors-ligne.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Tout supprimer', style: TextStyle(decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}
