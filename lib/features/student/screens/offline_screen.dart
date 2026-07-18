import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

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
        title: Text('Mode Hors-ligne', style: theme.textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Contenu disponible'),
            const SizedBox(height: 16),
            _buildOfflineItem(context, 'Algorithmique', '4 documents • 12 MB', Icons.book, Colors.blue),
            _buildOfflineItem(context, 'Mathématiques', '2 documents • 5.4 MB', Icons.functions, Colors.green),
            _buildOfflineItem(context, 'Notes S1', 'Dernière sync: Hier', Icons.grade, Colors.orange),
            const SizedBox(height: 40),
            _buildStorageInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 48, color: colorScheme.primary),
          const SizedBox(height: 16),
          const Text('Vous êtes hors-ligne', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'L\'application utilise les données mises en cache sur votre appareil. Les changements seront synchronisés dès votre retour en ligne.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOfflineItem(BuildContext context, String title, String subtitle, IconData icon, Color color) {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Espace utilisé', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('17.4 MB / 500 MB', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.034,
              minHeight: 6,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Gérer le stockage local'),
          ),
        ],
      ),
    );
  }
}
