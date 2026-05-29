import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'dart:math' as math;

class OfflineStorageScreen extends StatefulWidget {
  const OfflineStorageScreen({super.key});

  @override
  State<OfflineStorageScreen> createState() => _OfflineStorageScreenState();
}

class _OfflineStorageScreenState extends State<OfflineStorageScreen> with SingleTickerProviderStateMixin {
  late AnimationController _syncController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
  }

  void _handleSync() async {
    setState(() => _isSyncing = true);
    _syncController.repeat();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _isSyncing = false);
      _syncController.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronisation terminée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildSyncHero(),
                  const SizedBox(height: 24),
                  _buildStorageCard(),
                  const SizedBox(height: 32),
                  Text('Contenu téléchargé', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 16),
                  _buildContentList(),
                  const SizedBox(height: 32),
                  Text('Options de synchro', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 16),
                  _buildSyncOptions(),
                  const SizedBox(height: 32),
                  _buildSyncButton(),
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
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Mode Offline',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryContainer, const Color(0xFF06090A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.15), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSyncing ? 'Synchronisation...' : 'Synchronisation active',
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
              ),
              Text(
                'Dernière synchro: il y a 2 min',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryContainer),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _syncController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _syncController.value * 2 * math.pi,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8A317)),
                      ),
                    ),
                    const Icon(Icons.sync, color: Colors.white, size: 28),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1614),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STOCKAGE UTILISÉ', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
              Text('1.2 GB / 2.0 GB', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('NETTOYER LE CACHE', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return Column(
      children: [
        _buildContentItem(Icons.menu_book, 'Cours téléchargés', '12 fichiers • 450 MB', AppColors.primary),
        const SizedBox(height: 12),
        _buildContentItem(Icons.picture_as_pdf, 'PDF enregistrés', '8 fichiers • 120 MB', AppColors.amber),
        const SizedBox(height: 12),
        _buildContentItem(Icons.calendar_today, 'Planning Offline', 'Mis à jour hier', AppColors.secondary),
      ],
    );
  }

  Widget _buildContentItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1614),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text('OFFLINE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.refresh, size: 18, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildSyncOptions() {
    return Column(
      children: [
        _buildToggleOption('Synchro automatique', 'Mise à jour périodique', true),
        _buildToggleOption('Wi-Fi uniquement', 'Économiser les données mobiles', true),
        _buildToggleOption('Arrière-plan', 'Continuer même l\'app fermée', false),
      ],
    );
  }

  Widget _buildToggleOption(String title, String subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeThumbColor: const Color(0xFFE8A317),
            activeTrackColor: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSyncing ? null : _handleSync,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8A317),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync),
            const SizedBox(width: 8),
            Text(
              _isSyncing ? 'Synchronisation...' : 'Synchroniser maintenant',
              style: AppTextStyles.headlineMedium.copyWith(color: Colors.black, fontSize: 18),
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
          color: AppColors.surfaceContainer.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Accueil', false, () => context.go('/student-dashboard')),
            _buildBottomNavItem(Icons.menu_book, 'Cours', false, () => context.push('/courses')),
            _buildBottomNavItem(Icons.grade, 'Notes', false, () => context.push('/grades')),
            _buildBottomNavItem(Icons.calendar_today, 'Planning', false, () => context.push('/schedule')),
            _buildBottomNavItem(Icons.person, 'Profil', true, () => context.push('/profile')),
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
          Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}
