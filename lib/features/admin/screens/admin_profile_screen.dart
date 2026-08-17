import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'admin_personal_info_screen.dart';
import 'admin_security_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, dynamic>? _adminData;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _adminData = doc.data();
          });
        } else {
          setState(() {
            _adminData = {
              'name': user.displayName ?? 'Admin Principal',
              'email': user.email ?? 'admin@acadify.edu',
              'role': 'admin',
              'poste': 'Directeur des Systèmes d\'Information',
            };
          });
        }
      } else {
        setState(() {
          _adminData = {
            'name': 'Administrateur Acadify',
            'email': 'admin@acadify.edu',
            'role': 'admin',
            'poste': 'Super Administrateur / Scolarité',
          };
        });
      }
    } catch (e) {
      _showCustomSnackBar('Erreur de chargement : $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[900] : colorScheme.surface,
        duration: const Duration(seconds: 2),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? Colors.redAccent : AppColors.primaryAccent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : AppColors.primaryAccent,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isError ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close, 
                color: isError ? Colors.white70 : colorScheme.onSurfaceVariant, 
                size: 18,
              ),
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _adminData?['name'] ?? 'Administrateur';
    final email = _adminData?['email'] ?? 'admin@acadify.edu';
    final poste = _adminData?['poste'] ?? 'Super Administrateur';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mon Profil Admin',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20, color: colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar & Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCCOxKKLpHAVjSrjqm4h5iRLVRGOg7RoN-QBy004hXaEIEezVv3BkOUDiLm-XGj0-7ONMbv3OjnDV4yaxcS_cjOH_6GlYnEhkydfRNGzqWeenKHVwPixU3ZcQVtgkeWJWeH2lq0wChXwC7qU7y4sDmCFaHNWuzwjnaNbMUG3UtrllRgw4I1_8bDvrFKsJe5Tpr5FRKrczFbGBnzoNlrC1yNEvihL72HAMqtF3L71lGMlQGeImik6UWai3-IkNMkzUZ1y6E6Ue-dZNId',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ADMINISTRATEUR',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Section Informations de compte
            _buildSectionTitle('INFORMATIONS DE COMPTE'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.email_outlined, 'Email Académique', email),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.work_outline, 'Poste / Direction', poste),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Actions
            _buildSectionTitle('PARAMÈTRES & SÉCURITÉ'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _buildActionRow(
                    Icons.person_outline,
                    'Informations personnelles',
                    'Modifier votre nom et votre poste',
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminPersonalInfoScreen(
                            adminData: _adminData ?? {},
                            onUpdate: _loadAdminData,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildActionRow(
                    Icons.lock_outline,
                    'Sécurité & Mot de passe',
                    'Mettre à jour votre mot de passe',
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminSecurityScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryAccent, size: 22),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
