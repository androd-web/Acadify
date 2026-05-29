import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  String? _selectedSex;
  String? _selectedFiliere;
  String? _selectedPromotion;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Inscription Étudiant',
          style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildProgressBar(),
            const SizedBox(height: 32),
            _buildForm(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.onSurfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text('Étape 1 sur 1', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('NOM', 'Votre nom', _nomController),
        const SizedBox(height: 24),
        _buildTextField('PRÉNOM', 'Votre prénom', _prenomController),
        const SizedBox(height: 24),
        _buildTextField('MATRICULE', 'Ex: 24ABC123', _matriculeController),
        const SizedBox(height: 24),
        _buildTextField('ADRESSE EMAIL', 'votre@email.com', _emailController),
        const SizedBox(height: 24),
        _buildSexSelector(),
        const SizedBox(height: 24),
        _buildDropdown('FILIÈRE', 'Sélectionner une filière', ['ISN', 'CDN', 'INS'], _selectedFiliere, (v) => setState(() => _selectedFiliere = v)),
        const SizedBox(height: 24),
        _buildDropdown('PROMOTION', 'Sélectionner un niveau', ['L1', 'L2', 'L3', 'M1', 'M2'], _selectedPromotion, (v) => setState(() => _selectedPromotion = v)),
        const SizedBox(height: 24),
        _buildPasswordField('MOT DE PASSE', 'Créer un mot de passe', _passwordController),
        const SizedBox(height: 24),
        _buildPasswordField('CONFIRMER LE MOT DE PASSE', 'Répéter le mot de passe', _confirmPasswordController),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface, letterSpacing: 1.5)),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryContainer)),
          ),
        ),
      ],
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SEXE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSex,
              hint: Text('Sélectionner votre sexe', style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14)),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
              items: [
                DropdownMenuItem(
                  value: 'M',
                  child: Row(
                    children: [
                      const Icon(Icons.male, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Text('M', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'F',
                  child: Row(
                    children: [
                      const Icon(Icons.female, color: Colors.pink, size: 20),
                      const SizedBox(width: 12),
                      Text('F', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _selectedSex = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String hint, List<String> options, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14)),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
              items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryContainer)),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.onSurfaceVariant),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/student-dashboard'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 10,
          shadowColor: AppColors.primaryContainer.withValues(alpha: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Créer mon compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}
