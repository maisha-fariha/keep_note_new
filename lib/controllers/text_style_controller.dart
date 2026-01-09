import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/models/notes_model.dart';

enum TextHeading { h1, h2, normal }

class TextStyleController extends GetxController {
  RxBool showToolbar = false.obs;

  RxBool bold = false.obs;
  RxBool italic = false.obs;
  RxBool underline = false.obs;
  Rx<TextHeading> heading = TextHeading.normal.obs;

  TextStyle get textStyle {
    double size = 16;
    if (heading.value == TextHeading.h1) size = 24;
    if (heading.value == TextHeading.h2) size = 20;

    return TextStyle(
      fontSize: size,
      fontWeight: bold.value ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic.value ? FontStyle.italic : FontStyle.normal,
      decoration: underline.value
          ? TextDecoration.underline
          : TextDecoration.none,
    );
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
  }

  void reset() {
    bold.value = false;
    italic.value = false;
    underline.value = false;
    heading.value = TextHeading.normal;
  }
}
