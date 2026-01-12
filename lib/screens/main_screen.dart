import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/main_screen_controller.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
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
      backgroundColor: Colors.grey.shade100,
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
        if (notesController.activeNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outlined, size: 150, color: Colors.amber),
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
                  backgroundColor: Colors.blue.shade800,
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
      backgroundColor: Colors.grey.shade100,
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
      title: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: SearchBar(
                  hintText: 'Search Ke...',
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Colors.white),
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
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.swap_vert),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            child: IconButton(onPressed: () {}, icon: Icon(Icons.person)),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _contextualAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: controller.clearSelection,
        icon: Icon(Icons.close),
      ),
      title: Obx(
        () => Text(
          controller.selectedIds.length.toString(),
          style: TextStyle(fontSize: 18),
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.push_pin_outlined)),
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none)),
        IconButton(onPressed: () {}, icon: Icon(Icons.color_lens_outlined)),
        IconButton(onPressed: () {}, icon: Icon(Icons.label_outline)),
        PopupMenuButton(
          color: Colors.grey.shade100,
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
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: notesController.activeNotes.length,
      itemBuilder: (context, index) {
        final note = notesController.activeNotes[index];
        return _noteCard(note);
      },
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: notesController.activeNotes.length,
      itemBuilder: (_, index) {
        final note = notesController.activeNotes[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _noteCard(note, isList: true),
        );
      },
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
                color: isSelected ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications, size: 14),
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
          backgroundColor: Color(0xFFC5F1F5),
          shape: StadiumBorder(),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.blue.shade800),
        label: Text(text, style: TextStyle(color: Colors.blue.shade800)),
      ),
    );
  }
}
