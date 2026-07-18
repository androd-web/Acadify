import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScheduleDetailScreen extends StatelessWidget {
  const ScheduleDetailScreen({super.key});

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
        title: Text('Détails du cours', style: theme.textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseHeader(context),
            const SizedBox(height: 32),
            _buildInfoSection(context, 'Date & Heure', 'Lundi 12 Octobre • 08:30 - 10:30', Icons.access_time),
            _buildInfoSection(context, 'Lieu', 'Amphithéâtre A • 2ème étage', Icons.location_on_outlined),
            _buildInfoSection(context, 'Professeur', 'Dr. Bakari Mamadou', Icons.person_outline),
            const SizedBox(height: 40),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.surfaceContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('COURS MAGISTRAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Algorithmique & Structure de Données',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Filière: Informatique S1',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.description_outlined),
            label: const Text('Accéder aux supports de cours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            label: const Text('Rappel 15 min avant'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
