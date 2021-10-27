part of data.model;

enum SavingMode{cloud, local, cloudAndLocal}

abstract class DocumentModel {}

@Entity()
class NoteModel {
  @Id()
  int mid = 0;
  String noteId;
  String? title;
  String? text;
  @Property(type: PropertyType.date)
  DateTime? creationTime;
  @Property(type: PropertyType.date)
  DateTime? modificationTime ;
  bool isDeleted;
  @Property(type: PropertyType.date)
  DateTime? permanentDeleteDate;
  int colorValue;
  @Property(type: PropertyType.date)
  DateTime? reminderDate;
  String? email;
  bool isArchived;
  bool isLocked;
  int savingModeValue;
  //final bool isChecklist;


  NoteModel({
      required this.noteId,
      this.email,
      this.isLocked = false,
      this.isArchived = false,
      this.title,
      this.text,
      this.creationTime,
      this.modificationTime,
      this.isDeleted = false,
      this.permanentDeleteDate,
      Color color = Colors.cyan, //this.color,
      this.reminderDate,
      SavingMode savingMode = SavingMode.cloud,

  }) :  colorValue = color.value,
        savingModeValue = savingMode.index;

  /*:assert(isArchived == true && isDeleted == true,
  "cant be deleted and archived at same time")*/

  factory NoteModel.fromMap(Map<String, dynamic> map){
    return NoteModel(
      noteId                  : map['id'],
      title               : map['title'],
      text                : map['text'],
      creationTime        : (map['creation_time'] != null)? map['creation_time'].toDate() : null,
      modificationTime    : (map['last_time'] != null)? map['last_time'].toDate() : null,
      isDeleted           : map['is_deleted'],
      permanentDeleteDate : (map['permanent_delete_date'] != null)? map['permanent_delete_date'].toDate() : null,
      color               : Color(map['color']),
      reminderDate        : map['reminder_date']?.toDate(),
      email               : map['email'],
      isArchived          : map['is_archived'],
      isLocked            : map['is_locked'],
      savingMode          : SavingMode.values[map['saving_mode']],
      //x        : map[''],

    );
  }
  Map<String, dynamic> asMap() => {
    'id'                    : noteId,
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
    //'': this,
  };

  void toDisplay(){
    Log.i("*** \n${toString()}{");
    asMap().forEach((key, value) => Log.i("$key : $value,"));
    Log.i('} \n***');
  }
}

@Entity()
class TodoItem{
  @Id()
  int mid = 0;
  String text;
  bool isDone;

  TodoItem({required this.text, required this.isDone});

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
      //id: map['id'],
      text: map['text'],
      isDone : map['is_done'],
    );

  Map<String, dynamic>  asMap() => {
    //'id'      : id,
    'text'    : text,
    'is_done' : isDone,
  };

}

@Entity()
class Checklist extends DocumentModel{
  @Id()
  int mid = 0;
  String checklistId;
  String title;
  @Transient()
  List<TodoItem>? list;
  bool isAllChecked;
  @Property(type: PropertyType.date)
  DateTime? creationTime;
  @Property(type: PropertyType.date)
  DateTime? modificationTime;
  int savingModeValue;
  final boxTodoItems = ToMany<TodoItem>();


  Checklist({
    required this.checklistId,
    required this.title,
    this.list =  const <TodoItem>[],
    this.isAllChecked = false,
    this.creationTime,
    this.modificationTime,
    SavingMode savingMode = SavingMode.cloud,
  }):savingModeValue = savingMode.index;


  List<Map<String, dynamic>> get listMap {
    assert(list != null,  "todo item list can't be null");
    return list!.map((e) => e.asMap()).toList();
  }

  Map<String, dynamic> asMap() => {
    'id'              : checklistId,
    'title'           : title,
    'is_all_checked'  : isAllChecked,
    'list'            : listMap,
    'saving_mode'     : savingModeValue,
  };
  factory Checklist.fromMap(Map<String, dynamic> map) => Checklist(
    checklistId   : map['id'] as String,
    title         : map['title'] as String,
    isAllChecked  : map['is_all_checked'] as bool,
    savingMode    : SavingMode.values[map['saving_mode'] as int],
    list          : (map['list'] as List<Map<String, dynamic>>).map(
            (e) => TodoItem.fromMap(e)).toList(),
  );


}

