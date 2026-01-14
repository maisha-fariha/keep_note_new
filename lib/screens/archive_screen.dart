import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/screens/text_notes_screen.dart';
import 'package:keep_note_new/widgets/keep_drawer.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final NotesController notesController = Get.find<NotesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAF2),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          toolbarHeight: 100,
          backgroundColor: Color(0xFFB5C99A),
          leading: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text('Archive'),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            Obx(() {
              final isGrid =
                  notesController.archiveViewMode.value == ArchiveViewMode.grid;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Icon(
                    isGrid ? Icons.view_agenda_outlined : Icons.grid_view,
                  ),
                  onPressed: () {
                    notesController.archiveViewMode.value =
                    isGrid ? ArchiveViewMode.list : ArchiveViewMode.grid;
                  },
                ),
              );
            }),
          ],
        ),
      ),
      drawer: KeepDrawer(),
      body: Obx(() {
        final archivedNotes = notesController.archivedNotes;
        final mode = notesController.archiveViewMode.value;

        if (archivedNotes.isEmpty) return _emptyArchive();

        if (mode == ArchiveViewMode.grid) {
          return MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: archivedNotes.length,
            itemBuilder: (_, i) =>
                _archiveGridCard(archivedNotes[i]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: archivedNotes.length,
          itemBuilder: (_, i) =>
              _archiveListCard(archivedNotes[i]),
        );
      }),
    );
  }

  Widget _emptyArchive() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive_outlined, size: 150, color: Color(0xFF8AA072)),
          SizedBox(height: 12),
          Text(
            'Your archived notes appear here',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }


  Widget _archiveGridCard(NotesModel note) {
    return GestureDetector(
      onTap: () => Get.to(() => TextNotesScreen(note: note)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(note.color ?? Colors.white.value),
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
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => SizedBox(),
                ),
              ),

            const SizedBox(height: 8),

            if (note.title.isNotEmpty)
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),


            if (note.content?.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(
                note.content!,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 8),


            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.unarchive_outlined),
                onPressed: () =>
                    notesController.unarchiveNotes({note.id}),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _archiveListCard(NotesModel note) {
    return Card(
      color: Color(note.color ?? Colors.white.value),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          note.title.isNotEmpty ? note.title : 'No Title',
        ),
        subtitle: note.content?.isNotEmpty == true
            ? Text(
          note.content!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.unarchive_outlined),
          onPressed: () =>
              notesController.unarchiveNotes({note.id}),
        ),
        onTap: () => Get.to(() => TextNotesScreen(note: note)),
      ),
    );
  }
}
