class NotesModel {
  final String id;
  final String title;
  final String content;
  final int color;

  final bool bold;
  final bool italic;
  final bool underline;
  final String heading;

  final bool isDeleted;
  final bool isArchived;
  final int? deletedAt;
  final DateTime? reminderAt;

  NotesModel({
    required this.id,
    required this.title,
    required this.content,
    int? color,
    required this.bold,
    required this.italic,
    required this.underline,
    required this.heading,
    this.isDeleted = false,
    this.isArchived = false,
    this.deletedAt,
    this.reminderAt,
  }) : color = color ?? 0xFFFFFFFF;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'bold': bold ? 1 : 0,
      'italic': italic ? 1 : 0,
      'underline': underline ? 1 : 0,
      'heading': heading,
      'isDeleted': isDeleted ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'deletedAt': deletedAt,
      'reminderAt': reminderAt?.millisecondsSinceEpoch,
    };
  }

  factory NotesModel.fromMap(Map<String, dynamic> map) {
    return NotesModel(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: map['color'] ?? 0xFFFFFFFF,
      bold: (map['bold'] ?? 0) == 1,
      italic: (map['italic'] ?? 0) == 1,
      underline: (map['underline'] ?? 0) == 1,
      heading: map['heading'] ?? 'normal',
      isDeleted: (map['isDeleted'] ?? 0) == 1,
      isArchived: (map['isArchived'] ?? 0) == 1,
      deletedAt: map['deletedAt'],
      reminderAt: map['reminderAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderAt'])
          : null,
    );
  }

  NotesModel copyWith({
    String? title,
    String? content,
    int? color,
    bool? bold,
    bool? italic,
    bool? underline,
    String? heading,
    bool? isDeleted,
    bool? isArchived,
    int? deletedAt,
    DateTime? reminderAt,
  }) {
    return NotesModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      heading: heading ?? this.heading,
      isDeleted: isDeleted ?? this.isDeleted,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      reminderAt: reminderAt ?? this.reminderAt,
    );
  }
}
