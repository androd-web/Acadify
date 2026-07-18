import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserRole role;

  const ProfileScreen({
    super.key,
    required this.role,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  final Box _userBox = Hive.box('userBox');
  
  String? _name;
  String? _matricule;
  String? _photoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _name = _userBox.get('name');
      _matricule = _userBox.get('matricule') ?? 'N/A';
      _photoUrl = _userBox.get('photoUrl');
    });
  }

  Future<void> _changePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 500,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      
      final String? newUrl = await _authService.updateProfilePhoto(File(image.path));
      
      if (mounted) {
        setState(() {
          _isUploading = false;
          if (newUrl != null) _photoUrl = newUrl;
        });

        if (newUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour !')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context),
            const SizedBox(height: 40),
            _buildInfoSection(context),
            const SizedBox(height: 32),
            _buildActionList(context),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary, width: 3),
                image: _photoUrl != null
                    ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                    : null,
                color: colorScheme.surfaceContainerHigh,
              ),
              child: _photoUrl == null
                  ? Icon(Icons.person, size: 60, color: colorScheme.onSurfaceVariant)
                  : null,
            ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _changePhoto,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(_name ?? 'Utilisateur', style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text('Matricule: $_matricule', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Filière', _userBox.get('filiere') ?? 'N/A'),
          Container(width: 1, height: 30, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          _buildStatItem('Niveau', _userBox.get('niveau') ?? 'N/A'),
          Container(width: 1, height: 30, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          _buildStatItem('Statut', 'Actif'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(context, Icons.person_outline, 'Informations personnelles', 'Nom, Prénom, Email...'),
        _buildActionTile(context, Icons.security_outlined, 'Sécurité', 'Mot de passe, Biométrie'),
        _buildActionTile(context, Icons.language_outlined, 'Langue', 'Français (Cameroun)'),
        _buildActionTile(context, Icons.help_outline, 'Aide & Support', 'FAQ, Contactez-nous'),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          await _authService.signOut();
          if (context.mounted) Navigator.of(context).pushReplacementNamed('/login');
        },
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
