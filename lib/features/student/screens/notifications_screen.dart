import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'Toutes';

  final List<String> _filters = ['Toutes', 'Notes', 'Communiqués', 'Planning', 'Absences'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 100,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restez informé de votre activité académique',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildNotificationFeed(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Notifications',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.check, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _activeFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive ? null : Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationFeed() {
    return Column(
      children: [
        _buildNotificationCard(
          icon: Icons.grading,
          title: 'Nouvelle note publiée',
          description: 'Votre note pour Algorithmique (S1) est disponible.',
          time: 'Il y a 10 min',
          isUnread: true,
          typeColor: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildNotificationCard(
          icon: Icons.warning_amber_rounded,
          title: 'Communiqué important',
          description: 'L\'administration a publié une note concernant les examens.',
          time: 'Aujourd\'hui, 09:45',
          isUnread: false,
          typeColor: AppColors.error,
        ),
        const SizedBox(height: 16),
        _buildNotificationCard(
          icon: Icons.calendar_month,
          title: 'Changement de salle',
          description: 'Le cours de Réseaux Mobiles est déplacé en Salle 302.',
          time: 'Hier, 16:20',
          isUnread: false,
          typeColor: AppColors.secondary,
        ),
        const SizedBox(height: 16),
        _buildNotificationCard(
          icon: Icons.description,
          title: 'Nouveau document',
          description: 'Support de cours - Graphes.pdf a été ajouté.',
          time: 'Hier, 14:05',
          isUnread: true,
          typeColor: AppColors.amber,
        ),
        const SizedBox(height: 32),
        Opacity(
          opacity: 0.2,
          child: Column(
            children: [
              const Icon(Icons.notifications_paused_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'FIN DES NOTIFICATIONS RÉCENTES',
                style: AppTextStyles.labelMedium.copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required bool isUnread,
    required Color typeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF1C211E).withValues(alpha: 0.6) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: isUnread 
          ? Border(left: BorderSide(color: typeColor, width: 4))
          : Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: typeColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    if (isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: typeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Accueil', false, () => context.go('/student-dashboard')),
            _buildBottomNavItem(Icons.menu_book, 'Cours', false, () => context.push('/courses')),
            _buildBottomNavItem(Icons.grade, 'Notes', false, () => context.push('/grades')),
            _buildBottomNavItem(Icons.calendar_month, 'Planning', true, () => context.push('/schedule')),
            _buildBottomNavItem(Icons.person, 'Profil', false, () => context.push('/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 4),
                  Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                ],
              ),
            )
          else
            Column(
              children: [
                Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelMedium),
              ],
            ),
        ],
      ),
    );
  }
}
