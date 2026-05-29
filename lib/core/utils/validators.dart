class Validators {
  static String? validateMatricule(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le matricule est requis';
    }
    // Simple regex for matricule like 22U123 (2 digits, 1 letter, 3 digits)
    // Adjust based on university's actual format if known
    final regExp = RegExp(r'^[0-9]{2}[A-Z]{1}[0-9]{3}$');
    if (!regExp.hasMatch(value.toUpperCase())) {
      // return 'Format de matricule invalide (ex: 22U123)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse email est requise';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Adresse email invalide';
    }
    return null;
  }
}
