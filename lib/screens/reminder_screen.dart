import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
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
          IconButton(onPressed: () {}, icon: Icon(Icons.grid_view)),
        ],
      ),
      drawer: KeepDrawer(),
      body: Obx(() {
        final reminders = notesController.reminderNotes;

        if (reminders.isEmpty) {
          return _emptyReminder();
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (_, i) {
            final note = reminders[i];
            return _reminderCard(note);
          },
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
}
