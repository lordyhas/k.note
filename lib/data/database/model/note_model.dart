part of data.model;

enum SavingMode{cloud, local, cloudAndLocal}

abstract class DocumentModel extends DataToMap {}

class NoteModel implements DocumentModel {
  final dynamic id;
  String? title;
  String? text;
  //todo : add a new saving data mode
  final DateTime? creationTime;
  DateTime? modificationTime ;
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
  }) :  colorValue = color.value,
        savingModeValue = savingMode.index;


  static NoteModel fromMap(Map<String, dynamic> map){
    return NoteModel(
      id                  : map['id'],
      title               : map['title'],
      text                : map['text'],
      creationTime        : (map['creation_time'] != null)
          ? map['creation_time'].toDate()
          : null,
      modificationTime    : (map['last_time'] != null)
          ? map['last_time'].toDate()
          : null,
      isDeleted           : map['is_deleted'],
      permanentDeleteDate : (map['permanent_delete_date'] != null)
          ? map['permanent_delete_date'].toDate()
          : null,
      color               : Color(map['color']),
      reminderDate        : map['reminder_date']?.toDate(),
      email               : map['email'],
      isArchived          : map['is_archived'],
      isLocked            : map['is_locked'],
      savingMode          : SavingMode.values[map['saving_mode'] ?? 0],
    );
  }
  @override
  Map<String, dynamic> asMap() => {
    'id'                    : id,
    'title'                 : title,
    'text'                  : text,
    'creation_time'         : creationTime,
    'last_time'             : modificationTime ,
    'is_deleted'            : isDeleted,
    'permanent_delete_date' : permanentDeleteDate,
    'color'                 : colorValue,
    'reminder_date'         : reminderDate,
    'is_archived'           : isArchived,
    'email'                 : email,
    'is_locked'             : isLocked,
    'saving_mode'           : savingModeValue,
  };

  @override
  toDisplay(){
    debugPrint("*** \n${toString()}{");
    asMap().forEach((key, value) => debugPrint("$key : $value,"));
    debugPrint('} \n***');
  }
}


class TodoItem implements DataToMap{
  final String text;
  final bool isDone;

  const TodoItem({required this.text, required this.isDone});

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
    text: map['text'],
    isDone : map['is_done'],
  );

  @override
  Map<String, dynamic>  asMap() => {
    'text'    : text,
    'is_done' : isDone,
  };

  @override
  void toDisplay() {

  }

}

class CheckList extends DocumentModel{
  final String title;
  final List<TodoItem> list;
  final bool isAllChecked;

  CheckList({
    required this.title,
    required this.list,
    this.isAllChecked = false,
  });

  List<Map<String, dynamic>> get listMap => list
      .map((e) => e.asMap())
      .toList();

  @override
  Map<String, dynamic> asMap() => {
    'title': title,
    'is_all_checked'  : isAllChecked,
    'list'            : listMap,
  };
  factory CheckList.fromMap(Map<String, dynamic> map) => CheckList(
    title: map['title'] as String,
    isAllChecked: map['is_all_checked'] as bool,
    list: (map['list'] as List<Map<String, dynamic>>)
        .map((e) => TodoItem.fromMap(e)).toList(),
  );

  @override
  void toDisplay() {
    debugPrint("*** \n${toString()}{");
    asMap().forEach((key, value) => debugPrint("$key : $value,"));
    debugPrint('} \n***');
  }


}

