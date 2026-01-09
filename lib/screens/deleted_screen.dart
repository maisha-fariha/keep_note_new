import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../controllers/main_screen_controller.dart';
import '../controllers/notes_controller.dart';
import '../models/notes_model.dart';
import '../widgets/keep_drawer.dart';

class DeletedScreen extends StatefulWidget {
  @override
  State<DeletedScreen> createState() => _DeletedScreenState();
}

class _DeletedScreenState extends State<DeletedScreen> {
  final NotesController notesController = Get.find();

  final MainScreenController controller = Get.find<MainScreenController>();

  void _showEmptyBinDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Empty Recycle bin?'),
        content: Text(
          'All notes in the Recycle Bin will be permanently deleted',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notesController.emptyBin();
              controller.clearSelection();
              Get.back();
            },
            child: const Text(
              'Empty bin',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return controller.selectionMode.value
              ? _contextualAppBar()
              : _normalAppBar();
        }),
      ),
      drawer: KeepDrawer(),
      body: Obx(() {
        final deletedNotes = notesController.deletedNotes;

        if (deletedNotes.isEmpty) {
          return _emptyState();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: deletedNotes.length,
            itemBuilder: (_, index) {
              return _noteCard(deletedNotes[index]);
            },
          ),
        );
      }),
    );
  }

  // ───────── APP BARS ─────────
  PreferredSizeWidget _normalAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('Deleted'),
      actions: [
        PopupMenuButton(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade100,
          itemBuilder: (_) => [
            PopupMenuItem(value: 'empty', child: Text('Empty bin')),
          ],
          onSelected: (value) {
            if (value == 'empty') {
              _showEmptyBinDialog();
            }
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _contextualAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: controller.clearSelection,
      ),
      title: Obx(() => Text('${controller.selectedIds.length}')),
      actions: [
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: () {
            notesController.restoreNotes(
              Set<String>.from(controller.selectedIds),
            );

            controller.clearSelection();
          },
        ),
      ],
    );
  }

  // ───────── NOTE CARD ─────────
  Widget _noteCard(NotesModel note) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(note.id);
      return GestureDetector(
        onLongPress: () => controller.onLongPressed(note.id),
        onTap: () =>
            controller.selectionMode.value ? controller.onTap(note.id) : null,
        child: Card(
          color: Color(note.color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(note.content),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ───────── EMPTY STATE ─────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.delete, size: 150, color: Colors.amber),
          SizedBox(height: 16),
          Text('No Notes in Recycle Bin'),
        ],
      ),
    );
  }
}
