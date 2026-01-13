import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/screens/text_notes_screen.dart';
import 'package:keep_note_new/widgets/keep_drawer.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final NotesController notesController = Get.find<NotesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
              ),
            );
          },
        ),
        title: Text('Reminder'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          Obx(() {
            final isGrid =
                notesController.reminderViewMode.value == ReminderViewMode.grid;
            return IconButton(
              onPressed: notesController.toggleReminderView,
              icon: Icon(isGrid ? Icons.view_agenda_outlined : Icons.grid_view),
            );
          }),
        ],
      ),
      drawer: KeepDrawer(),
      body: Obx(() {
        final notes = notesController.reminderNotes;
        final mode = notesController.reminderViewMode.value;

        if (notes.isEmpty) return _emptyReminder();

        if (mode == ReminderViewMode.grid) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: notes.length,
            itemBuilder: (_, i) => _reminderGridCard(notes[i]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notes.length,
          itemBuilder: (_, i) => _reminderCard(notes[i]),
        );
      }),
    );
  }

  Widget _emptyReminder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 150, color: Colors.amber),
          Text(
            'Your upcoming reminder notes appear here',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _reminderCard(NotesModel note) {
    String formatReminder(DateTime date) {
      return '${date.day}/${date.month}/${date.year} '
          '${TimeOfDay.fromDateTime(date).format(Get.context!)}';
    }

    return Card(
      color: Color(note.color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.notifications_active_outlined),
        title: Text(
          note.title.isEmpty ? 'No Title' : note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Reminds at ${formatReminder(note.reminderAt!)}'),
        trailing: IconButton(
          onPressed: () {
            notesController.removeReminder(note.id);
          },
          tooltip: 'Remove Reminder',
          icon: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _reminderGridCard(NotesModel note) {
    String formatReminder(DateTime date) {
      return '${date.day}/${date.month}/${date.year} '
          '${TimeOfDay.fromDateTime(date).format(Get.context!)}';
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => TextNotesScreen(note: note));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(note.color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(note.images.first),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>SizedBox(),
                ),
              ),
            SizedBox(height: 8,),
            /// TITLE
            Text(
              note.title.isEmpty ? 'No Title' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            /// REMINDER CHIP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active_outlined, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    formatReminder(note.reminderAt!),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 6),

                  /// CLOSE ICON
                  GestureDetector(
                    onTap: () {
                      notesController.removeReminder(note.id);
                    },
                    child: const Icon(Icons.close, size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
