import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notes_controller.dart';
import '../models/notes_model.dart';
import '../utils/keep_colors.dart';

class KeepColorDialogBox {
  // Accept the note as a parameter
  static void showColorDialogForMultiple(BuildContext context, List<NotesModel> notes) {
    final NotesController notesController = Get.find<NotesController>();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFFF6FAF2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: KeepColors.palette.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final color = KeepColors.palette[index];

                return GestureDetector(
                  onTap: () {
                    // Update all selected notes
                    for (var note in notes) {
                      notesController.updateNoteColor(note.id, color);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
