 import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _announcements = true;
  bool _grades = true;
  bool _schedule = false;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Personnalisez votre expérience Acadify',
                    style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsGroup(
                    'Apparence',
                    [
                      _buildThemeSelector(),
                      _buildSettingsItem(Icons.format_size, 'Taille du texte', trailing: Text('Medium', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant))),
                      _buildSettingsItem(Icons.language, 'Langue', trailing: Text('Français', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsGroup(
                    'Notifications',
                    [
                      _buildToggleItem(Icons.notifications_active, 'Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
                      _buildToggleItem(Icons.campaign, 'Communiqués & Alertes', _announcements, (v) => setState(() => _announcements = v)),
                      _buildToggleItem(Icons.grade, 'Mises à jour des notes', _grades, (v) => setState(() => _grades = v)),
                      _buildToggleItem(Icons.calendar_today, 'Changements de planning', _schedule, (v) => setState(() => _schedule = v)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsGroup(
                    'Sécurité',
                    [
                      _buildSettingsItem(Icons.lock_reset, 'Changer le mot de passe', showChevron: true),
                      _buildSettingsItem(Icons.security, 'Double authentification', showChevron: true),
                      _buildSettingsItem(Icons.devices, 'Appareils connectés', showChevron: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsGroup(
                    'Stockage & Sync',
                    [
                      _buildToggleItem(Icons.sync, 'Synchronisation automatique', _autoSync, (v) => setState(() => _autoSync = v)),
                      _buildSettingsItem(Icons.download_for_offline, 'Gestion du mode hors-ligne', showChevron: true, onTap: () => context.push('/offline-storage')),
                      _buildSettingsItem(Icons.delete_outline, 'Vider le cache', trailing: Text('128 MB', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsGroup(
                    'Support',
                    [
                      _buildSettingsItem(Icons.help_outline, 'Centre d\'aide', trailing: Icon(Icons.open_in_new, size: 20, color: colorScheme.onSurfaceVariant)),
                      _buildSettingsItem(Icons.policy_outlined, 'Politique de confidentialité', showChevron: true),
                      _buildSettingsItem(Icons.info_outline, 'À propos d\'Acadify', showChevron: true),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Version 2.5.0 • UIECC Digital Transformation',
                      style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Text('Thème de l\'application', style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return ValueListenableBuilder<ThemeMode>(
                valueListenable: themeManager,
                builder: (context, currentMode, _) {
                  return SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, label: Text('Clair'), icon: Icon(Icons.light_mode_outlined)),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Sombre'), icon: Icon(Icons.dark_mode_outlined)),
                      ButtonSegment(value: ThemeMode.system, label: Text('Système'), icon: Icon(Icons.settings_suggest_outlined)),
                    ],
                    selected: {currentMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      themeManager.setTheme(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: colorScheme.primary,
                      selectedForegroundColor: colorScheme.onPrimary,
                      side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                  );
                }
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 8),
            Text(
              'Paramètres',
              style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: colorScheme.primary, 
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {Widget? trailing, bool showChevron = false, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            if (trailing != null) trailing,
            if (showChevron) Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.logout),
        label: const Text('Déconnexion'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}