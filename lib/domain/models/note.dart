import 'package:flutter/material.dart';

import 'package:knote/domain/models/document_model.dart';

enum SavingMode { cloud, local, cloudAndLocal }

class NoteModel implements DocumentModel {
  final dynamic id;
  String? title;
  String? text;
  //todo : add a new saving data mode
  final DateTime? creationTime;
  DateTime? modificationTime;
  bool isDeleted;
  final DateTime? permanentDeleteDate;
  int colorValue;
  DateTime? reminderDate;
  final String? email;
  bool isArchived;
  bool isLocked;
  int savingModeValue;

  final bool isExtraText;
  final dynamic data;

  NoteModel({
    this.email,
    this.isLocked = false,
    this.isArchived = false,
    this.id,
    this.title,
    this.text,
    this.creationTime,
    this.modificationTime,
    this.isDeleted = false,
    this.permanentDeleteDate,
    Color color = Colors.cyan, //this.color,
    this.reminderDate,
    this.data,
    this.isExtraText = false,
    SavingMode savingMode = SavingMode.cloud,
  })  : colorValue = color.toARGB32(),
        savingModeValue = savingMode.index;

  static NoteModel fromMap(Map<String, dynamic> map) {
    final rawSaving = map['saving_mode'];
    final savingIndex = rawSaving is int
        ? rawSaving.clamp(0, SavingMode.values.length - 1)
        : 0;
    final rawColor = map['color'];
    final colorArgb = rawColor is int
        ? rawColor
        : rawColor is num
            ? rawColor.toInt()
            : Colors.cyan.toARGB32();

    return NoteModel(
      id: map['id'],
      title: map['title'],
      text: map['text'],
      creationTime:
          (map['creation_time'] != null) ? map['creation_time'].toDate() : null,
      modificationTime:
          (map['last_time'] != null) ? map['last_time'].toDate() : null,
      isDeleted: map['is_deleted'] as bool? ?? false,
      permanentDeleteDate: (map['permanent_delete_date'] != null)
          ? map['permanent_delete_date'].toDate()
          : null,
      color: Color(colorArgb),
      reminderDate: map['reminder_date']?.toDate(),
      email: map['email'],
      isArchived: map['is_archived'] as bool? ?? false,
      isLocked: map['is_locked'] as bool? ?? false,
      savingMode: SavingMode.values[savingIndex],
    );
  }

  @override
  Map<String, dynamic> asMap() => {
        'id': id,
        'title': title,
        'text': text,
        'creation_time': creationTime,
        'last_time': modificationTime,
        'is_deleted': isDeleted,
        'permanent_delete_date': permanentDeleteDate,
        'color': colorValue,
        'reminder_date': reminderDate,
        'is_archived': isArchived,
        'email': email,
        'is_locked': isLocked,
        'saving_mode': savingModeValue,
      };

  @override
  toDisplay() {
    debugPrint("*** \n${toString()}{");
    asMap().forEach((key, value) => debugPrint("$key : $value,"));
    debugPrint('} \n***');
  }
}
