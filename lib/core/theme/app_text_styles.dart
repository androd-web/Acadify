import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headline Styles (Hanken Grotesk)
  static TextStyle headlineLarge = GoogleFonts.hankenGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.hankenGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Body Styles (Inter)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.55,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.43,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
  
  // Display Styles (Cormorant Garamond - from Cahier des Charges)
  static TextStyle displayLarge = GoogleFonts.cormorantGaramond(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.1,
  );
}
