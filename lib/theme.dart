import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

ThemeData hirelensDarkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xffC69749),
    surface: Color(0xff181C14),
    tertiary: Color(0xff006874),
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      fontSize: 32,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    bodySmall: GoogleFonts.roboto(),
    bodyMedium: GoogleFonts.roboto(),
    bodyLarge: GoogleFonts.roboto(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(60, 255, 255, 255)),
    ),
    outlineBorder: BorderSide(color: Color.fromARGB(60, 255, 255, 255)),
    activeIndicatorBorder: BorderSide(
      color: Color.fromARGB(160, 255, 255, 255),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(220, 255, 255, 255)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(220, 255, 255, 255)),
    ),
  ),
);

ThemeData themeFromContext(BuildContext context) {
  return Theme.of(context);
}
