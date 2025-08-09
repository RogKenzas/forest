import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // Couleurs principales
  static const Color primaryGreen = Color(0xFF2DDF16);// #ff2ddf16
  static const Color primaryBlack = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFF2A2A2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9E9E9E);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF1FBF0F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: white,
  );
  
  static TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: white,
  );
  
  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: white,
  );
  
  static TextStyle get captionStyle => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textGrey,
  );
  
  // Dimensions
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double borderRadius = 12.0;
  static const double bigBorderRadius = 20.0;
  static const double fullBorderRadius = 50.0;
  static const double buttonHeight = 50.0;
  
  // App Info
  static const String appName = "BoisTech";
  static const String appVersion = "1.0.0";
} 