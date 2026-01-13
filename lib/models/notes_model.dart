class NotesModel {
  final String id;
  final String title;
  final String content;
  final int color;

  final bool bold;
  final bool italic;
  final bool underline;
  final String heading;

  final List<String> images;

  final bool isPinned;
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
    this.isPinned = false,
    this.isDeleted = false,
    this.isArchived = false,
    this.deletedAt,
    this.reminderAt,
    List<String>? images,
  }) : color = color ?? 0xFFFFFFFF,
       images = images ?? [];

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
      'isPinned': isPinned ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'deletedAt': deletedAt,
      'reminderAt': reminderAt?.millisecondsSinceEpoch,
      'images': images.isNotEmpty ? images.join('|') : '',
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
      isPinned: map['isPinned'] == 1,
      isDeleted: map['isDeleted'] == 1,
      isArchived: map['isArchived'] == 1,
      deletedAt: map['deletedAt'],
      reminderAt: map['reminderAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderAt'])
          : null,
      images: map['images'] != null && map['images'].toString().isNotEmpty
          ? map['images'].toString().split('|')
          : [],
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
    List<String>? images,
    bool? isPinned,
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
      images: images ?? this.images,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      reminderAt: reminderAt ?? this.reminderAt,
    );
  }
}
