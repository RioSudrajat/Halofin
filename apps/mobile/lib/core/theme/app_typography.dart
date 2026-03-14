import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w500),
    );
  }
}
