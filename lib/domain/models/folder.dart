import 'package:flutter/foundation.dart';

import 'package:knote/domain/models/document_model.dart';

/// A folder the user files notes in (`users/{uid}/folders/{id}`).
///
/// Folders are flat: a note is in one folder at most, through
/// `NoteModel.folderId`, and a folder holds no other folder.
@immutable
class NoteFolder implements DocumentModel {
  const NoteFolder({required this.id, required this.name, this.creationTime});

  /// Longest name the rules accept.
  static const maxNameLength = 100;

  final String id;
  final String name;
  final DateTime? creationTime;

  NoteFolder copyWith({String? name}) =>
      NoteFolder(id: id, name: name ?? this.name, creationTime: creationTime);

  /// Defensive about malformed documents, like the other models.
  static NoteFolder fromMap(Map<String, dynamic> map) {
    return NoteFolder(
      id: map['id'] is String ? map['id'] : '',
      name: map['name'] is String ? map['name'] : '',
      creationTime: _date(map['creation_time']),
    );
  }

  /// A Firestore `Timestamp` (or a `DateTime`, as tests may store), else null.
  static DateTime? _date(Object? value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic)?.toDate() as DateTime?;
    } on NoSuchMethodError {
      return null;
    }
  }

  @override
  Map<String, dynamic> asMap() => {
        'id': id,
        'name': name,
        'creation_time': creationTime,
      };

  @override
  void toDisplay() => debugPrint('NoteFolder${asMap()}');

  @override
  bool operator ==(Object other) =>
      other is NoteFolder &&
      other.id == id &&
      other.name == name &&
      other.creationTime == creationTime;

  @override
  int get hashCode => Object.hash(id, name, creationTime);
}
