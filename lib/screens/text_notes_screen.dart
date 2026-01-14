import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/color_controller.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/services/reminder_services.dart';
import 'package:keep_note_new/widgets/keep_tool_text_bar.dart';
import 'package:intl/intl.dart';
import '../controllers/text_style_controller.dart';
import '../widgets/keep_color_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

class TextNotesScreen extends StatefulWidget {
  final NotesModel? note;

  const TextNotesScreen({super.key, this.note});

  @override
  State<TextNotesScreen> createState() => _TextNotesScreenState();
}

class _TextNotesScreenState extends State<TextNotesScreen> {
  final ImagePicker _picker = ImagePicker();
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  final NotesController notesController = Get.find();
  final ColorController colorController = Get.put(ColorController());
  final TextStyleController styleController = Get.find<TextStyleController>();

  Color selectedColor = Colors.white;

  final FocusNode titleFocus = FocusNode();
  final FocusNode noteFocus = FocusNode();

  List<String> _images = [];
  bool _isTitleFocused = false;
  bool _isNoteFocused = false;
  bool isPinned = false;

  @override
  void initState() {
    super.initState();

    isPinned = widget.note?.isPinned ?? false;
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      noteController.text = widget.note!.content;

      styleController.restoreFromNote(widget.note!);

      colorController.selectedColor.value = Color(widget.note!.color);

      _images = List.from(widget.note?.images ?? []);
    }

    titleFocus.addListener(() {
      setState(() {
        _isTitleFocused = titleFocus.hasFocus;
      });
    });

    noteFocus.addListener(() {
      setState(() {
        _isNoteFocused = noteFocus.hasFocus;
      });
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _images.add(image.path);
    });
  }

  Future<void> _pickImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() {
      _images.addAll(images.map((e) => e.path));
    });
  }

  void _saveAndBack() {
    final title = titleController.text.trim();
    final content = noteController.text.trim();

    if (title.isEmpty && content.isEmpty && _images.isEmpty) {
      Get.back();
      return;
    }

    final style = Get.find<TextStyleController>();
    final note = NotesModel(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      content: noteController.text,
      color: colorController.selectedColor.value.value,
      bold: style.bold.value,
      italic: style.italic.value,
      underline: style.underline.value,
      heading: style.heading.value.name,

      isPinned: isPinned,
      images: _images,
      reminderAt: widget.note?.reminderAt,
      isDeleted: widget.note?.isDeleted ?? false,
      isArchived: widget.note?.isArchived ?? false,
      deletedAt: widget.note?.deletedAt,
    );

    if (widget.note == null) {
      notesController.addNotes(note);
    } else {
      notesController.updateNote(note);
    }

    style.reset();
    colorController.reset();
    Get.back();
  }

  void showReminderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6FAF2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFF6FAF2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.notifications_active_outlined),
                title: Text(
                  'Remind me later',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Your reminders are saved in Google Tasks'),
              ),
              Divider(),
              _reminderTile(
                icon: Icons.access_time,
                title: 'Later today',
                time: '6:00 pm',
                onTap: () {
                  _applyReminder(DateTime.now().copyWith(hour: 18, minute: 0));
                },
              ),
              _reminderTile(
                icon: Icons.access_time,
                title: 'Tomorrow morning',
                time: '8:00 am',
                onTap: () {
                  _applyReminder(
                    DateTime.now()
                        .add(Duration(days: 1))
                        .copyWith(hour: 8, minute: 0),
                  );
                },
              ),
              _reminderTile(
                icon: Icons.access_time,
                title: 'Next monday',
                time: '8:00 am',
                onTap: () {
                  final now = DateTime.now();
                  final monday = now
                      .add(Duration(days: 8 - now.weekday % 7))
                      .copyWith(hour: 8, minute: 0);
                  _applyReminder(monday);
                },
              ),
              _reminderTile(
                icon: Icons.access_time,
                title: 'Choose a date & time',
                onTap: () {
                  Navigator.pop(context);
                  _pickCustomDateTime(context);
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showAddBoxBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6FAF2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.photo_camera_sharp),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.image_outlined),
                title: Text('Add Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              // SizedBox(height: 10),
              // ListTile(
              //   leading: Icon(Icons.brush_outlined),
              //   title: Text('Drawing'),
              // ),
              // SizedBox(height: 10),
              // ListTile(leading: Icon(Icons.mic), title: Text('Recording')),
              // SizedBox(height: 10),
              // ListTile(
              //   leading: Icon(Icons.check_box_outlined),
              //   title: Text('Tick Boxes'),
              // ),
              SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  // void showMoreBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: false,
  //     builder: (_) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Color(0xFFF6FAF2),
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(height: 10),
  //             ListTile(
  //               title: Text(
  //                 'Edited at 6:00 pm',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //             SizedBox(height: 5),
  //             ListTile(
  //               leading: Icon(CupertinoIcons.delete),
  //               title: Text('Delete'),
  //               onTap: () {},
  //             ),
  //             SizedBox(height: 5),
  //             ListTile(
  //               leading: Icon(Icons.copy_rounded),
  //               title: Text('Make a copy'),
  //             ),
  //             SizedBox(height: 5),
  //             ListTile(
  //               leading: Icon(Icons.share_outlined),
  //               title: Text('Send'),
  //             ),
  //             SizedBox(height: 5),
  //             ListTile(
  //               leading: Icon(Icons.person_add_alt_1),
  //               title: Text('Collaborators'),
  //             ),
  //             SizedBox(height: 5),
  //             ListTile(
  //               leading: Icon(Icons.label_outline),
  //               title: Text('Labels'),
  //             ),
  //             SizedBox(height: 5),
  //             ListTile(
  //               leading: Icon(Icons.help_outline_outlined),
  //               title: Text('Help & feedback'),
  //             ),
  //             SizedBox(height: 50),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _pickCustomDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final reminderTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    _applyReminder(reminderTime);
  }

  void _applyReminder(DateTime time) {
    final existingId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final updatedNote = NotesModel(
      id: existingId,
      title: titleController.text,
      content: noteController.text,
      color: colorController.selectedColor.value.value,
      bold: styleController.bold.value,
      italic: styleController.italic.value,
      underline: styleController.underline.value,
      heading: styleController.heading.value.name,
      reminderAt: time,
    );

    if (widget.note == null) {
      notesController.addNotes(updatedNote);
    } else {
      notesController.updateNote(updatedNote);
    }

    ReminderServices.schedule(
      noteId: existingId,
      title: updatedNote.title,
      body: updatedNote.content,
      time: time,
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveAndBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF6FAF2),
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(
            toolbarHeight: 100,
            backgroundColor: Color(0xFFB5C99A),
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                onPressed: _saveAndBack,
                icon: Icon(Icons.arrow_back),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPinned = !isPinned;
                  });

                  if (widget.note != null) {
                    final updated = widget.note!.copyWith(isPinned: isPinned);
                    notesController.updateNote(updated);
                  }

                  Get.snackbar(
                    isPinned ? 'Note Pinned' : 'Note unpinned',
                    '',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 1),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Color(0xFFE6E6CC),
                ),
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 25,
                ),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  showReminderBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Color(0xFFE6E6CC),
                ),
                child: Icon(Icons.add_alert_outlined, size: 25),
              ),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    final style = Get.find<TextStyleController>();

                    final note = NotesModel(
                      id:
                          widget.note?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      content: noteController.text,
                      color: colorController.selectedColor.value.value,
                      bold: style.bold.value,
                      italic: style.italic.value,
                      underline: style.underline.value,
                      heading: style.heading.value.name,
                      reminderAt: widget.note?.reminderAt,
                      isArchived: true,
                    );

                    if (widget.note == null) {
                      notesController.addNotes(note);
                    } else {
                      notesController.updateNote(note);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    backgroundColor: Color(0xFFE6E6CC),
                  ),
                  child: Icon(Icons.archive_outlined, size: 25),
                ),
              ),
            ],
          ),
        ),
        body: Obx(
          () => Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: colorController.selectedColor.value,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_images.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          _images.length,
                          (index) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_images[index]),
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => SizedBox(),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      maxLines: null,
                      minLines: 1,
                      controller: titleController,
                      focusNode: titleFocus,
                      style: TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        hintText: _isTitleFocused ? '' : 'Title',
                        labelStyle: TextStyle(fontSize: 24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      maxLines: null,
                      minLines: 1,
                      controller: noteController,
                      focusNode: noteFocus,
                      style: styleController.textStyle,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: _isNoteFocused ? '' : 'Notes',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  if (widget.note?.reminderAt != null)
                    _reminderChip(widget.note!),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Obx(() {
          final style = Get.find<TextStyleController>();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (style.showToolbar.value) KeepToolTextBar(),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: colorController.selectedColor.value,
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: Color(0xFFE6E6CC),
                        ),
                        onPressed: () {
                          showAddBoxBottomSheet(context);
                        },
                        child: Icon(Icons.add_box_outlined),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: Color(0xFFE6E6CC),
                        ),
                        onPressed: () {
                          KeepColorBottomSheet.show(context);
                        },
                        child: Icon(Icons.color_lens_outlined),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: Color(0xFFE6E6CC),
                        ),
                        onPressed: () {
                          style.toggleToolbar();
                          FocusScope.of(context).requestFocus(noteFocus);
                        },
                        child: Icon(Icons.text_format),
                      ),
                      Spacer(),
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     shape: StadiumBorder(),
                      //     backgroundColor: Color(0xFFE6E6CC),
                      //   ),
                      //   onPressed: () {
                      //     showMoreBottomSheet(context);
                      //   },
                      //   child: Icon(Icons.more_vert),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _reminderTile({
    required IconData icon,
    required String title,
    String? time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: time != null
          ? Text(time, style: TextStyle(fontWeight: FontWeight.w500))
          : null,
      onTap: onTap,
    );
  }

  Widget _reminderChip(NotesModel note) {
    if (note.reminderAt == null) return SizedBox();

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications, color: Color(0xFF8AA072),),
          SizedBox(width: 6),
          Text(
            DateFormat('EEE, MMM d • hh:mm a').format(note.reminderAt!),
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              notesController.removeReminder(note.id);
            },
            child: Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }
}
