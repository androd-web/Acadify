import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterTeacherScreen extends StatefulWidget {
  const RegisterTeacherScreen({super.key});

  @override
  State<RegisterTeacherScreen> createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    _emailController.dispose();
    _specialiteController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Inscription Enseignant',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildSection(
              children: [
                _buildTextField('NOM', 'Votre nom de famille', _nomController),
                const SizedBox(height: 24),
                _buildTextField('PRÉNOM', 'Votre prénom', _prenomController),
                const SizedBox(height: 24),
                _buildTextField('MATRICULE ENSEIGNANT', 'Ex: ENS-2024-001', _matriculeController),
                const SizedBox(height: 24),
                _buildTextField('ADRESSE EMAIL', 'votre@email.com', _emailController),
                const SizedBox(height: 24),
                _buildTextField('SPÉCIALITÉ / MATIÈRES', 'Ex: Mathématiques, Physique', _specialiteController),
              ],
            ),
            const SizedBox(height: 32),
            _buildVerificationSection(),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Créer votre mot de passe',
              children: [
                _buildPasswordField('MOT DE PASSE', '8 caractères minimum', _passwordController, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
                const SizedBox(height: 24),
                _buildPasswordField('CONFIRMER LE MOT DE PASSE', 'Répétez votre mot de passe', _confirmPasswordController, _obscurePassword, null),
              ],
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(context),
            const SizedBox(height: 16),
            _buildInfoNotice(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
        ],
        ...children,
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool obscure, VoidCallback? onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1614),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8A317).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFE8A317), size: 20),
              const SizedBox(width: 8),
              Text('Code de vérification enseignant', style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: const Color(0xFFE8A317))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ce code vous a été communiqué par l\'administration pour valider votre statut d\'enseignant.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _verificationCodeController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Entrez le code à 6 chiffres',
              filled: true,
              fillColor: AppColors.background.withValues(alpha: 0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8A317))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/teacher-dashboard'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 10,
          shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
        ),
        child: Text('Créer mon compte', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.background, fontSize: 18)),
      ),
    );
  }

  Widget _buildInfoNotice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('Votre compte sera validé par un administrateur', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
