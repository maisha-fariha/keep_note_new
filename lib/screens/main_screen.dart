import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/main_screen_controller.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/screens/search_screen.dart';
import 'package:keep_note_new/screens/text_notes_screen.dart';
import 'package:keep_note_new/widgets/keep_drawer.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MainScreenController controller = Get.find<MainScreenController>();
  final NotesController notesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAF2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          height: 120,
          decoration: BoxDecoration(color: Color(0xFFB5C99A)),
          child: Obx(() {
            return controller.selectionMode.value
                ? _contextualAppBar()
                : _normalAppBar();
          }),
        ),
      ),
      drawer: KeepDrawer(),
      body: Obx(() {
        if (notesController.activeNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outlined,
                  size: 150,
                  color: Color(0xFF8AA072),
                ),
                Text(
                  'Notes you add appear here',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Obx(() {
            return controller.view.value == NotesView.grid
                ? _buildGrid()
                : _buildList();
          }),
        );
      }),

      floatingActionButton: Obx(
        () => SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: AlignmentGeometry.bottomRight,
            children: [
              if (controller.isFabOpen.value) ...[
                // _fabItem(Icons.mic, 'Audio', 270, ),
                // _fabItem(Icons.image, 'Image', 220),
                // _fabItem(Icons.brush, 'Drawing', 170),
                // _fabItem(Icons.check_box, 'List', 120),
                _fabItem(
                  Icons.text_fields,
                  'Text',
                  70,
                  () => Get.to(() => TextNotesScreen()),
                ),
              ],
              Padding(
                padding: EdgeInsets.all(16),
                child: FloatingActionButton(
                  backgroundColor: Color(0xFF8AA072),
                  onPressed: () {
                    controller.toggleFab();
                  },
                  child: Icon(
                    controller.isFabOpen.value ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _normalAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Color(0xFFB5C99A),
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(Icons.menu),
          ),
        ),
      ),
      centerTitle: true,
      title: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 50, bottom: 40),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color(0xFFE6E6CC),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 3,
                    child: SearchBar(
                      onTap: () {
                        Get.to(() => SearchScreen());
                      },
                      hintText: 'Search Ke...',
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(Color(0xFFE6E6CC)),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Obx(
                    () => IconButton(
                      onPressed: controller.toggleView,
                      icon: Icon(
                        controller.view.value == NotesView.grid
                            ? Icons.view_agenda_outlined
                            : Icons.grid_view,
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: IconButton(
                //     onPressed: () {},
                //     icon: Icon(Icons.swap_vert),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.all(10.0),
      //     child: CircleAvatar(
      //       backgroundColor: Color(0xFFE6E6CC),
      //       child: IconButton(onPressed: () {}, icon: Icon(Icons.person)),
      //     ),
      //   ),
      // ],
    );
  }

  PreferredSizeWidget _contextualAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Color(0xFFB5C99A),
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IconButton(
          onPressed: controller.clearSelection,
          icon: Icon(Icons.close),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Text(
            controller.selectedIds.length.toString(),
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      actions: [
        Obx(() {
          final allPinned = notesController.areAllSelectedPinned(
            controller.selectedIds,
          );

          return IconButton(
            onPressed: () {
              notesController.togglePin(controller.selectedIds);
              controller.selectedIds;
            },
            icon: Icon(allPinned ? Icons.push_pin : Icons.push_pin_outlined),
          );
        }),
        // IconButton(onPressed: () {}, icon: Icon(Icons.add_alert_outlined)),
        // IconButton(onPressed: () {}, icon: Icon(Icons.color_lens_outlined)),
        // IconButton(onPressed: () {}, icon: Icon(Icons.label_outline)),
        PopupMenuButton(
          color: Color(0xFFF6FAF2),
          borderRadius: BorderRadius.circular(10),
          onSelected: (value) {
            final selectedIds = Set<String>.from(controller.selectedIds);
            if (value == 'Archive') {
              notesController.archiveNotes(selectedIds);
              controller.clearSelection();
            }
            if (value == 'Delete') {
              notesController.deleteNotes(selectedIds);
              controller.clearSelection();

              Get.snackbar(
                'Note deleted',
                'Notes in Recycle Bin are automatically deleted after 7 days',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 4),
                mainButton: TextButton(
                  onPressed: () {
                    notesController.restoreNotes(selectedIds);
                    Get.back();
                  },
                  child: Text('UNDO', style: TextStyle(color: Colors.white)),
                ),
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'Archive', child: Text('Archive')),
            PopupMenuItem(value: 'Delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final pinnedNotes = notesController.activeNotes
        .where((n) => n.isPinned && !n.isArchived)
        .toList();
    final otherNotes = notesController.activeNotes
        .where((n) => !n.isPinned && !n.isArchived)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pinnedNotes.isNotEmpty) ...[
            _sectionTitle('Pinned'),
            MasonryGridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: pinnedNotes.length,
              itemBuilder: (_, i) => _noteCard(pinnedNotes[i]),
            ),
          ],

          if (otherNotes.isNotEmpty) ...[
            _sectionTitle('Others'),
            MasonryGridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: otherNotes.length,
              itemBuilder: (_, i) => _noteCard(otherNotes[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    final pinnedNotes = notesController.activeNotes
        .where((n) => n.isPinned && !n.isArchived)
        .toList();
    final otherNotes = notesController.activeNotes
        .where((n) => !n.isPinned && !n.isArchived)
        .toList();
    return ListView(
      children: [
        if (pinnedNotes.isNotEmpty) ...[
          _sectionTitle('Pinned'),
          ...pinnedNotes.map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _noteCard(note, isList: true),
            ),
          ),
        ],

        if (otherNotes.isNotEmpty) ...[
          _sectionTitle('Others'),
          ...otherNotes.map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _noteCard(note, isList: true),
            ),
          ),
        ],
      ],
    );
  }

  Widget _noteCard(NotesModel note, {bool isList = false}) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(note.id);
      return GestureDetector(
        onLongPress: () => controller.onLongPressed(note.id),
        onTap: () {
          controller.selectionMode.value
              ? controller.onTap(note.id)
              : Get.to(() => TextNotesScreen(note: note));
        },
        child: Card(
          color: Color(note.color),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(note.color),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Color(0xFF8AA072) : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 8),
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: note.bold ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                if (note.title.isNotEmpty) SizedBox(height: 6),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: note.bold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: note.italic
                        ? FontStyle.italic
                        : FontStyle.normal,
                    decoration: note.underline
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
                if (note.reminderAt != null)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFE6E6CC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications,
                          size: 14,
                          color: Color(0xFF8AA072),
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat(
                              'EEE, MMM d • hh:mm a',
                            ).format(note.reminderAt!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _fabItem(
    IconData icon,
    String text,
    double bottom,
    VoidCallback onPressed,
  ) {
    return Positioned(
      right: 16,
      bottom: bottom,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE6E6CC),
          shape: StadiumBorder(),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Color(0xFF8AA072)),
        label: Text(text, style: TextStyle(color: Color(0xFF8AA072))),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8AA072),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
