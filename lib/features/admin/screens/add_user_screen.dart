import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Contrôleurs de saisie
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: 'AC#78x2P');
  final TextEditingController _specialiteController = TextEditingController(); // Pour l'enseignant
  final TextEditingController _adminPosteController = TextEditingController(); // Pour l'admin

  String _selectedRole = 'Étudiant'; // 'Étudiant', 'Enseignant', 'Admin'
  String _selectedFiliere = 'Génie Logiciel (GL)';
  String _selectedNiveau = 'Licence 1';

  bool _forcePasswordChange = true;
  bool _accountActive = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _matriculeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specialiteController.dispose();
    _adminPosteController.dispose();
    super.dispose();
  }

  // Fonction pour générer un mot de passe aléatoire
  void _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#%&*';
    final rand = Random();
    final password = List.generate(10, (index) => chars[rand.nextInt(chars.length)]).join();
    setState(() {
      _passwordController.text = password;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nouveau mot de passe généré !')),
    );
  }

  Future<void> _saveUser() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom et l\'email sont obligatoires !')),
      );
      return;
    }

    if (_selectedRole == 'Étudiant' && _matriculeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le matricule est obligatoire pour un étudiant !')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String roleKey = 'student';
      if (_selectedRole == 'Enseignant') roleKey = 'teacher';
      if (_selectedRole == 'Admin') roleKey = 'admin';

      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': roleKey,
        'password': _passwordController.text.trim(),
        'forcePasswordChange': _forcePasswordChange,
        'status': _accountActive ? 'active' : 'inactive',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Ajout des champs spécifiques selon le rôle
      if (roleKey == 'student') {
        userData['matricule'] = _matriculeController.text.trim().toUpperCase();
        userData['filiere'] = _selectedFiliere;
        userData['niveau'] = _selectedNiveau;
      } else if (roleKey == 'teacher') {
        userData['specialite'] = _specialiteController.text.trim();
      } else if (roleKey == 'admin') {
        userData['poste'] = _adminPosteController.text.trim();
      }

      // On crée un document avec un ID généré automatiquement
      await _firestore.collection('users').add(userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur enregistré avec succès !')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 90,
            child: _isSaving 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildProfilePreview(context),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, Icons.badge, 'Sélection du Rôle'),
                      const SizedBox(height: 12),
                      _buildRoleSelection(context),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, Icons.person, 'Informations Personnelles'),
                      const SizedBox(height: 12),
                      _buildPersonalInfoForm(context),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, Icons.school, 'Spécialité & Permissions'),
                      const SizedBox(height: 12),
                      _buildDynamicFields(context),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, Icons.security, 'Sécurité'),
                      const SizedBox(height: 12),
                      _buildSecuritySection(context),
                      const SizedBox(height: 24),
                      _buildStatusSection(context),
                      const SizedBox(height: 40),
                      _buildActionButtons(context),
                      const SizedBox(height: 40),
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
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ajouter un utilisateur',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Créez un nouveau compte académique',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save, color: AppColors.amber),
                onPressed: _saveUser,
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
      padding: const EdgeInsets.all(20),
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
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primaryContainer, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.photo_camera, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty ? 'Nouvel Utilisateur' : _nameController.text,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
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
          if (_selectedRole == 'Étudiant') ...[
            const SizedBox(height: 8),
            Text(
              _matriculeController.text.isEmpty ? 'Matricule: ———' : 'Matricule: ${_matriculeController.text.toUpperCase()}',
              style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
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
          if (_selectedRole == 'Étudiant') ...[
            _buildTextField(
              context, 
              'Matricule', 
              'Ex: 23U045', 
              _matriculeController,
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            context, 
            'Nom complet', 
            'Prénom et Nom', 
            _nameController,
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context, 
            'Email Académique', 
            'nom@acadify.edu', 
            _emailController, 
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, 
    String label, 
    String hint, 
    TextEditingController controller, {
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
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
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
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
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              size: 28,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              role,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 14,
              height: 14,
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
                      width: 6,
                      height: 6,
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
      child: _selectedRole == 'Étudiant'
          ? Column(
              children: [
                _buildDropdown(
                  context, 
                  'Filière / Département', 
                  ['Génie Logiciel (GL)', 'Réseaux & Télécoms (RT)', 'IA', 'Cyber-sécurité'],
                  _selectedFiliere,
                  (v) => setState(() => _selectedFiliere = v!),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  context, 
                  'Niveau', 
                  ['Licence 1', 'Licence 2', 'Licence 3', 'Master 1'],
                  _selectedNiveau,
                  (v) => setState(() => _selectedNiveau = v!),
                ),
              ],
            )
          : _selectedRole == 'Enseignant'
              ? Column(
                  children: [
                    _buildTextField(
                      context, 
                      'Spécialité', 
                      'Ex: Algorithmique, Base de données...', 
                      _specialiteController,
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildTextField(
                      context, 
                      'Poste / Fonction administrative', 
                      'Ex: Scolarité, Directeur des Études...', 
                      _adminPosteController,
                    ),
                  ],
                ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> options, String currentValue, ValueChanged<String?> onChanged) {
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
              value: currentValue,
              dropdownColor: colorScheme.surface,
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppTextStyles.bodyMedium),
                );
              }).toList(),
              onChanged: onChanged,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mot de passe temporaire', 
                style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
              ),
              TextButton.icon(
                onPressed: _generateRandomPassword,
                icon: const Icon(Icons.autorenew, size: 16, color: AppColors.amber),
                label: Text(
                  'Générer',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildTextField(
            context, 
            'Saisir ou modifier le mot de passe', 
            'Mot de passe', 
            _passwordController,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Forcer le changement au 1er login', 
                  style: AppTextStyles.bodyMedium,
                ),
              ),
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
      child: _buildToggleOption(
        context, 
        Icons.check_circle, 
        'Compte actif', 
        _accountActive, 
        (v) => setState(() => _accountActive = v), 
        colorScheme.primary,
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
            onPressed: _saveUser,
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
}
