import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/screens/text_notes_screen.dart';
import 'package:keep_note_new/widgets/keep_rich_text_preview.dart';

import '../models/notes_model.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final NotesController notesController = Get.find();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAF2),
      appBar: AppBar(
        backgroundColor: Color(0xFFB5C99A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            notesController.clearSearch();
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: searchController,
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            onChanged: notesController.updateSearch,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              hintText: 'Search Keep Note',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFE6E6CC),
            ),
          ),
        ),
        actions: [
          Obx(
            () => notesController.searchQuery.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      searchController.clear();
                      notesController.clearSearch();
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final results = notesController.searchedNotes;

        if (notesController.searchQuery.isEmpty) {
          return Center(
            child: Text(
              'Search your notes',
              style: TextStyle(color: Colors.grey.shade900, fontSize: 24),
            ),
          );
        }

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.search, color: Color(0xFF8AA072), size: 150),
                Text(
                  'No matching found',
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 24),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final note = results[index];
            return _noteCard(note);
          },
        );
      }),
    );
  }

  Widget _noteCard(NotesModel note) {
    return GestureDetector(
      onTap: () {
        Get.to(() => TextNotesScreen(note: note));
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(note.color),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.isPinned)
              Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.push_pin, size: 16),
              ),
            Text(
              note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 6),
            KeepRichTextPreview(content: note.content, maxLines: 5),
          ],
        ),
      ),
    );
  }
}
