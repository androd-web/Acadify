import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminPersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic> adminData;
  final VoidCallback onUpdate;

  const AdminPersonalInfoScreen({
    super.key,
    required this.adminData,
    required this.onUpdate,
  });

  @override
  State<AdminPersonalInfoScreen> createState() => _AdminPersonalInfoScreenState();
}

class _AdminPersonalInfoScreenState extends State<AdminPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _posteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.adminData['name']);
    _posteController = TextEditingController(text: widget.adminData['poste'] ?? 'Administrateur');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _posteController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'poste': _posteController.text.trim(),
        });
        widget.onUpdate();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Informations mises à jour avec succès !', style: AppTextStyles.bodyMedium),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour : $e', style: AppTextStyles.bodyMedium),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informations Personnelles',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20, color: colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DÉTAILS DU COMPTE ADMIN',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              
              // Email (Non modifiable)
              Text('Adresse Email Académique', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: widget.adminData['email'] ?? 'admin@acadify.edu',
                enabled: false,
                style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nom Complet
              Text('Nom Complet', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.bodyMedium,
                validator: (value) => value == null || value.isEmpty ? 'Le nom ne peut pas être vide' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Poste / Direction
              Text('Poste / Direction Administrative', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _posteController,
                style: AppTextStyles.bodyMedium,
                validator: (value) => value == null || value.isEmpty ? 'Le poste ne peut pas être vide' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  prefixIcon: const Icon(Icons.work_outline, color: AppColors.primaryAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveData,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer les modifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
