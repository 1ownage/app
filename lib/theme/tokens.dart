import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// OwnAge design tokens — ported from colors_and_type.css.
/// Dark-first. Royalty × streetwear × battle-royale broadcast.
class OA {
  // Canvas
  static const bg0 = Color(0xFF0A0A0B);
  static const bg1 = Color(0xFF141416);
  static const bg2 = Color(0xFF1D1D21);
  static const bg3 = Color(0xFF26262B);

  // Ink
  static const fg1 = Color(0xFFF4F3EE);
  static const fg2 = Color(0xFF9A9AA2);
  static const fg3 = Color(0xFF55555C);
  static const fgInv = Color(0xFF0A0A0B);

  // Accents — ROYALTY
  static const gold1 = Color(0xFFE7B64B);
  static const gold2 = Color(0xFFF2D07A);
  static const gold3 = Color(0xFF7A5F1F);

  // COMPETITIVE
  static const blood1 = Color(0xFFE23D3D);
  static const blood2 = Color(0xFFFF6868);
  static const blood3 = Color(0xFF7A1A1A);

  // VIRAL
  static const electric1 = Color(0xFFC8F24B);
  static const electric2 = Color(0xFFE0FF7A);
  static const electric3 = Color(0xFF6E8E1C);

  // INFO
  static const ice1 = Color(0xFF6EC1FF);
  static const ice2 = Color(0xFFA1D8FF);
  static const ice3 = Color(0xFF1F5A8F);

  // Strokes
  static final stroke1 = Colors.white.withValues(alpha: 0.08);
  static final stroke2 = Colors.white.withValues(alpha: 0.14);
  static final stroke3 = Colors.white.withValues(alpha: 0.24);

  // Gradients
  static const gradGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold2, gold1, gold3],
    stops: [0.0, 0.6, 1.0],
  );
  static const gradBlood = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blood2, blood1, blood3],
    stops: [0.0, 0.6, 1.0],
  );

  // Spacing (4px base)
  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 24.0;
  static const space6 = 32.0;
  static const space7 = 48.0;
  static const space8 = 64.0;
  static const space9 = 96.0;

  // Radii
  static const radius1 = 4.0;
  static const radius2 = 8.0;
  static const radius3 = 12.0;
  static const radius4 = 20.0;
  static const radiusFull = 9999.0;

  // Shadows
  static const shadowCrown = [
    BoxShadow(color: Color(0x40E7B64B), blurRadius: 40, spreadRadius: 0),
    BoxShadow(color: Color(0x99E7B64B), blurRadius: 2, spreadRadius: 0),
  ];
  static const shadowBlood = [
    BoxShadow(color: Color(0x59E23D3D), blurRadius: 32, spreadRadius: 0),
  ];
  static const shadowRaise = [
    BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // ─── Typography ───────────────────────────────────────────────────────
  static TextStyle display({
    double size = 40,
    Color color = fg1,
    double letterSpacing = -0.01,
    double height = 0.9,
  }) =>
      GoogleFonts.bebasNeue(
        fontSize: size,
        color: color,
        height: height,
        letterSpacing: size * letterSpacing,
      );

  static TextStyle body({
    double size = 16,
    Color color = fg1,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle micro({Color color = fg2}) => GoogleFonts.inter(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 10,
      );

  static TextStyle mono({
    double size = 14,
    Color color = fg1,
    FontWeight weight = FontWeight.w500,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color,
        fontWeight: weight,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
