import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextHeading { h1, h2, normal }

class TextStyleController extends GetxController {
  RxBool showToolbar = false.obs;

  RxBool bold = false.obs;
  RxBool italic = false.obs;
  RxBool underline = false.obs;
  Rx<TextHeading> heading = TextHeading.normal.obs;
  RxString fontFamily = 'Default'.obs;
  RxInt textColor = Colors.black.toARGB32().obs;

  static const List<String> availableFonts = <String>[
    'Default',
    'Roboto',
    'Lato',
    'Poppins',
    'Merriweather',
    'Source Sans Pro',
    'Fira Sans',
  ];

  TextStyle get textStyle {
    double size = 16;
    if (heading.value == TextHeading.h1) size = 24;
    if (heading.value == TextHeading.h2) size = 20;

    final base = TextStyle(
      fontSize: size,
      fontWeight: bold.value ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic.value ? FontStyle.italic : FontStyle.normal,
      decoration: underline.value
          ? TextDecoration.underline
          : TextDecoration.none,
      color: Color(textColor.value),
    );

    final family = fontFamily.value.trim();
    if (family.isEmpty || family == 'Default') return base;

    try {
      return GoogleFonts.getFont(family, textStyle: base);
    } catch (_) {
      // If a font name isn't supported for some reason, fall back gracefully.
      return base.copyWith(fontFamily: family);
    }
  }

  void toggleToolbar() => showToolbar.toggle();

  void hideToolbar() => showToolbar.value = false;

  void restoreFromNote(NotesModel note) {
    bold.value = note.bold;
    italic.value = note.italic;
    underline.value = note.underline;
    heading.value = TextHeading.values.firstWhere(
      (e) => e.name == note.heading,
      orElse: () => TextHeading.normal,
    );
    fontFamily.value = note.fontFamily;
    textColor.value = note.textColor;
  }

  void reset() {
    bold.value = false;
    italic.value = false;
    underline.value = false;
    heading.value = TextHeading.normal;
    fontFamily.value = 'Default';
    textColor.value = Colors.black.toARGB32();
  }
}
