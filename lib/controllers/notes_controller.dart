import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/services/reminder_services.dart';

enum ReminderViewMode { grid, list }
enum ArchiveViewMode {grid, list}

class NotesController extends GetxController {
  final RxList<NotesModel> notes = <NotesModel>[].obs;
  final GetStorage _box = GetStorage();
  final Rx<ReminderViewMode> reminderViewMode = ReminderViewMode.list.obs;
  final Rx<ArchiveViewMode> archiveViewMode = ArchiveViewMode.list.obs;


  static String _storageKey = 'notes';

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadNotes();
    autoDeleteExpiredNotes();
    saveNotes();
  }

  List<NotesModel> get activeNotes =>
      notes.where((n) => !n.isDeleted && !n.isArchived).toList();

  List<NotesModel> get deletedNotes => notes.where((n) => n.isDeleted).toList();

  List<NotesModel> get archivedNotes =>
      notes.where((n) => n.isArchived && !n.isDeleted).toList();

  List<NotesModel> get reminderNotes {
    final list = notes
        .where((n) => n.reminderAt != null && !n.isDeleted)
        .toList();

    list.sort((a, b) => a.reminderAt!.compareTo(b.reminderAt!));
    return list;
  }

  void toggleReminderView() {
    reminderViewMode.value = reminderViewMode.value == ReminderViewMode.list
        ? ReminderViewMode.grid
        : ReminderViewMode.list;
  }

  void loadNotes() {
    final storedNotes = _box.read<List>(_storageKey);
    print(GetStorage().read('notes'));

    if (storedNotes != null && storedNotes.isNotEmpty) {
      notes.assignAll(
        storedNotes.map(
          (e) => NotesModel.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    }
  }

  void addNotes(NotesModel note) {
    notes.add(note);
    saveNotes();
    notes.refresh();
  }

  void updateNote(NotesModel note) {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      saveNotes();
      notes.refresh();
    }
  }

  void saveNotes() {
    _box.write(_storageKey, notes.map((e) => e.toMap()).toList());
  }

  void deleteNotes(Set<String> ids) {
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isDeleted: true, deletedAt: now);
      }
    }
    saveNotes();
  }

  void archiveNotes(Set<String> ids) {
    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isArchived: true);
      }
    }
    saveNotes();
    notes.refresh();
  }

  void unarchiveNotes(Set<String> ids) {
    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isArchived: false);
      }
    }
    saveNotes();
    notes.refresh();
  }

  void archiveNote(NotesModel note) {
    final updated = note.copyWith(isArchived: true);
    updateNote(updated);
  }
  void restoreNotes(Set<String> ids) {
    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isDeleted: false, deletedAt: null);
      }
    }
    saveNotes();
  }

  void autoDeleteExpiredNotes() {
    final now = DateTime.now().millisecondsSinceEpoch;
    const sevenDays = 7 * 24 * 60 * 60 * 1000;

    notes.removeWhere((note) {
      if (!note.isDeleted || note.deletedAt == null) return false;
      return now - note.deletedAt! >= sevenDays;
    });
  }

  void emptyBin() {
    notes.removeWhere((note) => note.isDeleted);
    saveNotes();
    notes.refresh();
  }

  void setReminder(String noteId, DateTime time) {
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    final note = notes[index];

    notes[index] = note.copyWith(reminderAt: time);
    saveNotes();
    notes.refresh();

    ReminderServices.schedule(
      noteId: note.id,
      title: note.title,
      body: note.content,
      time: time,
    );
  }

  void removeReminder(String noteId) {
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    notes[index] = notes[index].copyWith(reminderAt: null);

    ReminderServices.cancel(noteId);

    saveNotes();
    notes.refresh();
  }
}
