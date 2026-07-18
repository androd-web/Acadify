import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  String _selectedRole = 'Étudiant';
  bool _forcePasswordChange = true;
  bool _accountActive = true;
  bool _sendInvitation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  _buildProfilePreview(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, Icons.person, 'Informations Personnelles'),
                  const SizedBox(height: 12),
                  _buildPersonalInfoForm(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, Icons.badge, 'Rôle Et Permissions'),
                  const SizedBox(height: 12),
                  _buildRoleSelection(context),
                  const SizedBox(height: 32),
                  _buildDynamicFields(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, Icons.security, 'Sécurité'),
                  const SizedBox(height: 12),
                  _buildSecuritySection(context),
                  const SizedBox(height: 32),
                  _buildStatusSection(context),
                  const SizedBox(height: 48),
                  _buildActionButtons(context),
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
    final colorScheme = Theme.of(context).colorScheme;
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
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ajouter un utilisateur',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Créez un nouveau compte académique',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.save, color: AppColors.amber),
                onPressed: () {
                  // Lors de la sauvegarde, la date de création (createdAt) sera automatiquement DateTime.now()
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primaryContainer, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCCOxKKLpHAVjSrjqm4h5iRLVRGOg7RoN-QBy004hXaEIEezVv3BkOUDiLm-XGj0-7ONMbv3OjnDV4yaxcS_cjOH_6GlYnEhkydfRNGzqWeenKHVwPixU3ZcQVtgkeWJWeH2lq0wChXwC7qU7y4sDmCFaHNWuzwjnaNbMUG3UtrllRgw4I1_8bDvrFKsJe5Tpr5FRKrczFbGBnzoNlrC1yNEvihL72HAMqtF3L71lGMlQGeImik6UWai3-IkNMkzUZ1y6E6Ue-dZNId',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 3),
                  ),
                  child: const Icon(Icons.photo_camera, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Nouvel Utilisateur', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primaryContainer.withValues(alpha: 0.3)),
            ),
            child: Text(
              _selectedRole.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matricule: ———',
            style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: AppColors.amber, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildTextField(context, 'Matricule', 'Ex: 23U045'),
          const SizedBox(height: 16),
          _buildTextField(context, 'Nom complet', 'Prénom et Nom'),
          const SizedBox(height: 16),
          _buildTextField(context, 'Email Académique', 'nom@acadify.edu', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(context, 'Téléphone', '+237 ...', keyboardType: TextInputType.phone)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(context, 'Date de naissance', 'JJ/MM/AAAA')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, {TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
        ),
        const SizedBox(height: 4),
        TextField(
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRoleCard(context, 'Étudiant', Icons.school, _selectedRole == 'Étudiant'),
          const SizedBox(width: 12),
          _buildRoleCard(context, 'Enseignant', Icons.cast_for_education, _selectedRole == 'Enseignant'),
          const SizedBox(width: 12),
          _buildRoleCard(context, 'Admin', Icons.admin_panel_settings, _selectedRole == 'Admin'),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String role, IconData icon, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primaryContainer : colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              role,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected 
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                    ),
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicFields(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildDropdown(context, 'Filière / Département', ['Génie Logiciel (GL)', 'Réseaux & Télécoms (RT)', 'IA', 'Cyber-sécurité']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDropdown(context, 'Niveau', ['Licence 1', 'Licence 2', 'Licence 3', 'Master 1'])),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown(context, 'Groupe', ['Groupe A', 'Groupe B', 'Groupe C'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> options) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options[0],
              dropdownColor: colorScheme.surface,
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppTextStyles.bodyMedium),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mot de passe temporaire', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      'AC#78x2P',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.amber,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy, color: AppColors.amber),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Forcer le changement au 1er login', style: AppTextStyles.bodyMedium),
              Switch(
                value: _forcePasswordChange,
                onChanged: (v) => setState(() => _forcePasswordChange = v),
                activeThumbColor: AppColors.amber,
                activeTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildToggleOption(context, Icons.check_circle, 'Compte actif', _accountActive, (v) => setState(() => _accountActive = v), colorScheme.primary),
          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 24),
          _buildToggleOption(context, Icons.mail, 'Envoyer une invitation', _sendInvitation, (v) => setState(() => _sendInvitation = v), AppColors.amber),
        ],
      ),
    );
  }

  Widget _buildToggleOption(BuildContext context, IconData icon, String label, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: activeColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor,
          activeTrackColor: activeColor.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Lors de la création du compte, la date de création (createdAt) sera automatiquement DateTime.now()
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Créer le compte', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(context, Icons.dashboard, 'Dashboard', false),
            _buildBottomNavItem(context, Icons.notifications, 'Alertes', false),
            _buildBottomNavItem(context, Icons.group, 'Users', true),
            _buildBottomNavItem(context, Icons.analytics, 'Stats', false),
            _buildBottomNavItem(context, Icons.account_circle, 'Profil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.amber : colorScheme.onSurfaceVariant,
        ),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.amber : colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
