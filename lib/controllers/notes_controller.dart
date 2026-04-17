import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keep_note_new/models/notes_model.dart';
import 'package:keep_note_new/services/notes_database.dart';
import 'package:keep_note_new/services/reminder_services.dart';
import 'dart:async';

enum ReminderViewMode { grid, list }

enum ArchiveViewMode { grid, list }

class NotesController extends GetxController {
  final RxList<NotesModel> notes = <NotesModel>[].obs;
  final Rx<ReminderViewMode> reminderViewMode = ReminderViewMode.list.obs;
  final Rx<ArchiveViewMode> archiveViewMode = ArchiveViewMode.list.obs;
  RxString searchQuery = ''.obs;
  final NotesDatabase _db = NotesDatabase.instance;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    unawaited(loadNotes());
    autoDeleteExpiredNotes();
    unawaited(saveNotes());
  }

  List<NotesModel> get searchedNotes {
    final q = searchQuery.value.toLowerCase();
    
    return notes.where((note) {
      if (q.isEmpty) return false;

      return note.title.toLowerCase().contains(q) ||
          note.plainContent.toLowerCase().contains(q);
    }).toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchQuery.value = '';
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

  void togglePin(Set<String> ids) {
    final allPinned = areAllSelectedPinned(ids);

    notes.assignAll(
      notes.map((note) {
        if (!ids.contains(note.id)) return note;

        return note.copyWith(isPinned: !allPinned);
      }).toList(),
    );

    saveNotes();
  }

  bool areAllSelectedPinned(Set<String> selectedIds) {
    if (selectedIds.isEmpty) return false;

    final selectedNotes = activeNotes
        .where((n) => selectedIds.contains(n.id))
        .toList();

    return selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);
  }

  Future<void> loadNotes() async {
    final storedNotes = await _db.getAllNotes();
    notes.assignAll(storedNotes);
  }

  void addNotes(NotesModel note) {
    notes.add(note);
    unawaited(_db.upsert(note));
    notes.refresh();
  }

  void updateNote(NotesModel note) {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      unawaited(_db.upsert(note));
      notes.refresh();
    }
  }

  Future<void> saveNotes() async {
    await _db.upsertMany(notes);
  }

  void deleteNotes(Set<String> ids) {
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isDeleted: true, deletedAt: now);
        unawaited(_db.upsert(notes[i]));
      }
    }
  }

  void archiveNotes(Set<String> ids) {
    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isArchived: true);
        unawaited(_db.upsert(notes[i]));
      }
    }
    notes.refresh();
  }

  void unarchiveNotes(Set<String> ids) {
    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isArchived: false);
        unawaited(_db.upsert(notes[i]));
      }
    }
    notes.refresh();
  }

  void archiveNote(NotesModel note) {
    final updated = note.copyWith(isArchived: true, isPinned: false);
    updateNote(updated);
  }

  void restoreNotes(Set<String> ids) {
    for (int i = 0; i < notes.length; i++) {
      if (ids.contains(notes[i].id)) {
        notes[i] = notes[i].copyWith(isDeleted: false, deletedAt: null);
        unawaited(_db.upsert(notes[i]));
      }
    }
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
    final ids = notes.where((n) => n.isDeleted).map((e) => e.id).toSet();
    notes.removeWhere((note) => note.isDeleted);
    unawaited(_db.deleteByIds(ids));
    notes.refresh();
  }

  void setReminder(String noteId, DateTime time) {
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    final note = notes[index];

    notes[index] = note.copyWith(reminderAt: time);
    unawaited(_db.upsert(notes[index]));
    notes.refresh();

    ReminderServices.schedule(
      noteId: note.id,
      title: note.title,
      body: note.plainContent,
      time: time,
    );
  }

  void removeReminder(String noteId) {
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    notes[index] = notes[index].copyWith(reminderAt: null);
    unawaited(_db.upsert(notes[index]));

    ReminderServices.cancel(noteId);

    notes.refresh();
  }

  void updateNoteColor(String noteId, Color color) {
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      notes[index] = notes[index].copyWith(color: color.value);
      unawaited(_db.upsert(notes[index])); // persist change
      notes.refresh(); // update UI
    }
  }
}
