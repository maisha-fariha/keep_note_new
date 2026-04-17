import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:keep_note_new/controllers/color_controller.dart';
import 'package:keep_note_new/controllers/main_screen_controller.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/controllers/text_style_controller.dart';
import 'package:keep_note_new/screens/main_screen.dart';
import 'package:keep_note_new/services/notes_database.dart';
import 'package:keep_note_new/services/reminder_services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await NotesDatabase.instance.init();
  await ReminderServices.init();

  // Preload the fonts we expose in the editor toolbar so that Quill's
  // `font` attribute (fontFamily string) renders immediately in all places
  // (editor + previews) without custom style builders.
  GoogleFonts.config.allowRuntimeFetching = true;
  for (final f in const <String>[
    'Roboto',
    'Lato',
    'Poppins',
    'Merriweather',
    'Source Sans Pro',
    'Fira Sans',
  ]) {
    try {
      GoogleFonts.getFont(f);
    } catch (_) {}
  }

  Get.put(ColorController(), permanent: true);
  Get.put(NotesController(), permanent: true);
  Get.put(TextStyleController(), permanent: true);
  Get.put(MainScreenController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Encoder Keep Note',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainScreen(),
    );
  }
}

