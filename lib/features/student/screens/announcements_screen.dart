import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Tous', 'Urgent', 'Info', 'Général'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            left: -100,
            top: 200,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Restez informé des dernières annonces universitaires',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 12),
                  _buildFilterChips(context),
                  const SizedBox(height: 20),
                  _buildAnnouncementList(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              Text(
                'Communiqués',
                style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: colorScheme.onSurface),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextField(
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Rechercher un communiqué',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.2) : colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Text(
                _filters[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAnnouncementList(BuildContext context) {
    return Column(
      children: [
        _buildAnnouncementCard(
          context,
          'URGENT',
          'Administration',
          'Auj.',
          'Modification du planning des examens',
          'Veuillez noter que les épreuves du second semestre ont été repoussées. Consultez le nouveau calendrier pour plus de détails.',
          isUrgent: true,
          isPinned: true,
        ),
        const SizedBox(height: 16),
        _buildAnnouncementCard(
          context,
          'INFO',
          'Scolarité',
          'Hier',
          'Ouverture des inscriptions aux clubs',
          'Les inscriptions pour les activités sportives et culturelles sont désormais ouvertes. Rejoignez un club dès aujourd\'hui.',
          hasAttachment: true,
        ),
        const SizedBox(height: 16),
        _buildAnnouncementCard(
          context,
          'GÉNÉRAL',
          'Département Informatique',
          '22 Oct.',
          'Conférence sur l\'IA et l\'Afrique',
          'Rejoignez-nous ce vendredi pour une session spéciale animée par des experts du domaine. Inscription obligatoire.',
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    String tag,
    String dept,
    String time,
    String title,
    String preview, {
    bool isUrgent = false,
    bool isPinned = false,
    bool hasAttachment = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/announcement-detail'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          boxShadow: isUrgent ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.15), blurRadius: 20)] : null,
        ),
        child: Stack(
          children: [
            if (isUrgent)
              Positioned(
                left: -20,
                top: -20,
                bottom: -20,
                child: Container(width: 4, decoration: BoxDecoration(color: colorScheme.primary)),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUrgent ? colorScheme.errorContainer.withValues(alpha: 0.2) : colorScheme.secondaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isUrgent ? colorScheme.error : colorScheme.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(dept, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(time, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        if (isPinned) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.push_pin, size: 16, color: colorScheme.primary),
                        ],
                        if (hasAttachment) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.attachment, size: 16, color: colorScheme.onSurfaceVariant),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
