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
        backgroundColor: Color(0xFFF6FAF2),
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
      backgroundColor: Color(0xFFF6FAF2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
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


  PreferredSizeWidget _normalAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Color(0xFFB5C99A),
      title: const Text('Deleted'),
      actions: [
        PopupMenuButton(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFF6FAF2),
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
      toolbarHeight: 100,
      backgroundColor: Color(0xFFB5C99A),
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
              color: isSelected ? Color(0xFF8AA072) : Colors.grey.shade300,
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
          Icon(CupertinoIcons.delete, size: 150, color: Color(0xFF8AA072)),
          SizedBox(height: 16),
          Text('No Notes in Recycle Bin'),
        ],
      ),
    );
  }
}
