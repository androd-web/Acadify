import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildOfflineBanner(),
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildGreeting(),
                      const SizedBox(height: 32),
                      _buildAvailableOfflineSection(),
                      const SizedBox(height: 32),
                      _buildUnavailableSection(),
                      const SizedBox(height: 32),
                      _buildFooter(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildReconnectionToast(),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.amber.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.amber, size: 18),
          const SizedBox(width: 8),
          Text(
            'Mode hors-ligne — données du 25 Mai 2026 · 18:42',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, color: AppColors.onSurface),
              const SizedBox(width: 16),
              Text(
                'UniLinc',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'OFFLINE',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.amber, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const Icon(Icons.cloud_off, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bonjour, Clément 👋', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text(
          'Vous êtes hors-ligne — contenu disponible en cache',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAvailableOfflineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_download, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text('Disponible hors-ligne', style: AppTextStyles.headlineMedium),
          ],
        ),
        const SizedBox(height: 16),
        _buildOfflineCard(Icons.menu_book, 'Mes cours téléchargés', '8 documents prêts à la lecture', true),
        const SizedBox(height: 16),
        _buildOfflineCard(Icons.calendar_month, 'Emploi du temps', 'Semaine du 26 Mai 2026', false, trailing: _buildDaysRow()),
        const SizedBox(height: 16),
        _buildOfflineCard(Icons.grade, 'Mes notes', 'Dernière synchro : il y a 2h', false, trailing: Row(
          children: [
            const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('À jour', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ],
        )),
      ],
    );
  }

  Widget _buildOfflineCard(IconData icon, String title, String subtitle, bool showProgress, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1614),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'HORS-LIGNE',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
          Text(subtitle, style: AppTextStyles.bodySmall),
          if (showProgress) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 1.0,
                backgroundColor: AppColors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                minHeight: 4,
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(height: 16),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildDaysRow() {
    return Row(
      children: ['L', 'M', 'M', 'J'].map((day) {
        final isToday = day == 'M'; // Simplified
        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 2),
          ),
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.labelMedium.copyWith(color: isToday ? Colors.black : Colors.white, fontSize: 10),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnavailableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_off, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Text('Non disponible sans connexion', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 16),
        _buildUnavailableCard(Icons.campaign, 'Communiqués', 'Actualités du campus en temps réel'),
        const SizedBox(height: 16),
        _buildUnavailableCard(Icons.contact_page, 'Annuaire campus', 'Recherche d\'étudiants & profs'),
      ],
    );
  }

  Widget _buildUnavailableCard(IconData icon, String title, String subtitle) {
    return Opacity(
      opacity: 0.4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1614),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'INDISPONIBLE',
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.info_outline, size: 18, color: AppColors.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Opacity(
      opacity: 0.6,
      child: Column(
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sync, size: 18),
                  const SizedBox(width: 8),
                  Text('Données synchronisées le 25 Mai 2026 à 18:42', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.storage, size: 18),
              const SizedBox(width: 8),
              Text('Espace utilisé : 124 Mo', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReconnectionToast() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Connexion rétablie',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Synchroniser'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF06090A),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Accueil', true, () => context.go('/student-dashboard')),
            _buildBottomNavItem(Icons.menu_book, 'Cours', false, () => context.push('/courses')),
            _buildBottomNavItem(Icons.grade, 'Notes', false, () => context.push('/grades')),
            _buildBottomNavItem(Icons.calendar_month, 'Planning', false, () => context.push('/schedule')),
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
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            )
          else
            Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}
