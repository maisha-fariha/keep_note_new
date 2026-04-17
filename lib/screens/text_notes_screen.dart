import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/controllers/color_controller.dart';
import 'package:keep_note_new/controllers/notes_controller.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/services/reminder_services.dart';
import 'package:keep_note_new/widgets/keep_rich_text_toolbar.dart';
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
  final NotesController notesController = Get.find();
  final ColorController colorController = Get.put(ColorController());
  final TextStyleController styleController = Get.find<TextStyleController>();

  Color selectedColor = Colors.white;

  final FocusNode titleFocus = FocusNode();
  final FocusNode noteFocus = FocusNode();

  late final QuillController _quillController;
  final ScrollController _quillScrollController = ScrollController();

  List<String> _images = [];
  bool _isTitleFocused = false;
  bool isPinned = false;

  @override
  void initState() {
    super.initState();

    isPinned = widget.note?.isPinned ?? false;

    _quillController = QuillController(
      document: _loadDocument(widget.note?.content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      styleController.restoreFromNote(widget.note!);

      colorController.selectedColor.value = Color(widget.note!.color);

      _images = List.from(widget.note?.images ?? []);
    }

    titleFocus.addListener(() {
      setState(() {
        _isTitleFocused = titleFocus.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Show keyboard automatically when opening the editor.
      // For a new note: jump straight to the note field.
      // For an existing note: focus the note field if user is continuing writing.
      FocusScope.of(context).requestFocus(noteFocus);
    });
  }

  Document _loadDocument(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return Document();
    }

    // Backward compatible:
    // - If content is Quill Delta JSON -> load it
    // - Else treat it as plain text
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return Document.fromJson(List<Map<String, dynamic>>.from(decoded));
      }
      return Document()..insert(0, raw);
    } catch (_) {
      return Document()..insert(0, raw);
    }
  }

  String _serializeDelta() {
    return jsonEncode(_quillController.document.toDelta().toJson());
  }

  String _plainEditorText() {
    return _quillController.document.toPlainText().trim();
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
    final plain = _plainEditorText();

    if (title.isEmpty && plain.isEmpty && _images.isEmpty) {
      Get.back();
      return;
    }

    final style = Get.find<TextStyleController>();
    final note = NotesModel(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      content: _serializeDelta(),
      color: colorController.selectedColor.value.value,
      bold: style.bold.value,
      italic: style.italic.value,
      underline: style.underline.value,
      heading: style.heading.value.name,
      fontFamily: style.fontFamily.value,
      textColor: style.textColor.value,

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

  Future<void> showAddBoxBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
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
      content: _serializeDelta(),
      color: colorController.selectedColor.value.value,
      bold: styleController.bold.value,
      italic: styleController.italic.value,
      underline: styleController.underline.value,
      heading: styleController.heading.value.name,
      fontFamily: styleController.fontFamily.value,
      textColor: styleController.textColor.value,
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
      body: _plainEditorText(),
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
        appBar: AppBar(
          backgroundColor: Color(0xFFB5C99A),
          leading: IconButton(
            onPressed: _saveAndBack,
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
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
              icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            ),
            IconButton(
              onPressed: () {
                showReminderBottomSheet(context);
              },
              icon: Icon(Icons.add_alert_outlined),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  final style = Get.find<TextStyleController>();

                  final note = NotesModel(
                    id:
                        widget.note?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    content: _serializeDelta(),
                    color: colorController.selectedColor.value.value,
                    bold: style.bold.value,
                    italic: style.italic.value,
                    underline: style.underline.value,
                    heading: style.heading.value.name,
                    fontFamily: style.fontFamily.value,
                    textColor: style.textColor.value,
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
                icon: Icon(Icons.archive_outlined),
              ),
            ),
          ],
        ),
        body: Obx(
          () => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // Keep keypad always available while on this screen.
              FocusScope.of(context).requestFocus(noteFocus);
            },
            child: Container(
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
                                      FocusScope.of(context)
                                          .requestFocus(noteFocus);
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
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 140),
                        child: QuillEditor(
                          controller: _quillController,
                          focusNode: noteFocus,
                          scrollController: _quillScrollController,
                          config: QuillEditorConfig(
                            padding: EdgeInsets.zero,
                            expands: false,
                            placeholder: 'Notes',
                          ),
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
                if (style.showToolbar.value)
                  KeepRichTextToolbar(controller: _quillController),

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
                        onPressed: () async {
                          await showAddBoxBottomSheet(context);
                          if (!context.mounted) return;
                          FocusScope.of(context).requestFocus(noteFocus);
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
                          Future.microtask(
                            () => FocusScope.of(context).requestFocus(noteFocus),
                          );
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
