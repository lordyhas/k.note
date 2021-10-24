
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:knote/data/app_bloc/auth_repository/user.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utils_component/utils_component.dart';

import '../../objectbox.g.dart';
import '../values.dart';
import 'database_model.dart';
import 'interface_model.dart';
import 'model/setting_data.dart';


abstract class ObjectBoxManager{
  const ObjectBoxManager();
  Future<Store> openStoreBox();
}

class SettingBoxManager extends  ObjectBoxManager {

  Store? storeManager;

  SettingBoxManager.empty();
  SettingBoxManager.initStore(){
    //this.storeManager = storeBox;

    openStoreBox().then((store) {
      final box = store.box<SettingAppData>();
      if(box.isEmpty()){
        final settingAppData = SettingAppData(
            createAt: DateTime.now().toString(),
            os: Platform.operatingSystem,
            osVersion: Platform.operatingSystemVersion,
            phoneModel: 'SmartPhone not checked');
        final id = box.put(settingAppData);      // note: sets note.id and also returns it
        //Log.i("*** *** *** *** *** ***");
        Log.out("SettingBoxManager",'new setting got id=$id, which is the same as setting.id=${settingAppData.id}');
        Log.out("SettingBoxManager",'re-read note: ${box.get(id)}');
        Log.out("",'SettingAppData Added Once : ${box.get(id)?.toDisplay()} ###########');

      }
    });
  }

  @override
  Future<Store> openStoreBox() async {
    Directory dir = await getApplicationDocumentsDirectory();
    if(kIsWeb) {
      return Store(getObjectBoxModel());
    }
    return Store(getObjectBoxModel(), directory: dir.path + '/objectbox');
  }


  //Store? get storeManager => this._storeManager;


  Future<SettingAppData?> get getSettingDataBox async {
    Store store = await openStoreBox();
    //final box = store.box<SettingAppData>();
    final settingData = store.box<SettingAppData>()
        .query().build().findFirst();
    //settingData?..theme = themeState.index;
    //final id = box.put(settingData!, mode: PutMode.update);
    store.close();
    return settingData;
  }

  Future<bool> updateSettingData(SettingAppData settingAppData) async {
    bool value = false;
    Store store = await openStoreBox();
    final id = store.box<SettingAppData>()
        .put(settingAppData, mode: PutMode.update);
    if(id != settingAppData.id) value = true;
    store.close();
    return value;
  }


  Future<bool> updateTheme(ThemeState themeState) async {
    bool value = false;
    Store store = await openStoreBox();
    final box = store.box<SettingAppData>();
    final settingData = box.query().build().findFirst();
    settingData?..theme = themeState.index;
    final id = box.put(settingData!, mode: PutMode.update);
    if(id != settingData.id) value = true;

    store.close();
    return value;

  }

  Future<bool> updateLanguage(LangState langState) async {
    bool value = false;
    Store store = await openStoreBox();
    final box = store.box<SettingAppData>();
    final settingData = box.query(SettingAppData_.createAt.notNull())
        .build().findFirst();
    settingData?..language = langState.index;
    final id = box.put(settingData!, mode: PutMode.update);
    if(id != settingData.id) value = true;

    store.close();
    return value;

  }



}


class NoteBoxManager extends ObjectBoxManager implements InterfaceNoteModel {
  const NoteBoxManager.empty();
  const NoteBoxManager.initStore();

  @override
  Future<Store> openStoreBox() async {
    Directory dir = await getApplicationDocumentsDirectory();
    if(kIsWeb) {
    return Store(getObjectBoxModel());
    }
    return Store(getObjectBoxModel(), directory: dir.path + '/objectbox');
  }

  Future<bool> update_() async {
    bool value = false;
    Store store = await openStoreBox();

    store.close();
    return value;

  }


  @override
  Future<bool> addNote({required NoteModel note,}) async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    final i = box.put(note, mode: PutMode.update);
    store.close();
    return i is int;
  }

  @override
  Future<bool> setNote({required NoteModel note}) async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    final mi = box.put(note, mode: PutMode.update);

    store.close();

    return mi is int;
  }

  @override
  Future<NoteModel?> getNote({
    required String noteId,
    bool deleted = false,
    bool archived = true,
  }) async {

    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
     NoteModel? note = box.query(
       NoteModel_.noteId.equals(noteId)
           .and(NoteModel_.isArchived.equals(archived))
           .and(NoteModel_.isDeleted.equals(deleted))
     ).build().findFirst();

    store.close();

    return note;
  }




  @override
  Future<bool> archiveNote({
    required String noteId,
    required bool archived})
  async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    NoteModel? note = box.query(NoteModel_.noteId.equals(noteId))
        .build().findFirst();
    note!.isArchived = archived;
    final i = box.put(note, mode: PutMode.update);
    store.close();
    return i is int;
  }

  @override
  Future<bool> deleteNote({String? userId, required String noteId}) async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    NoteModel? note = box.query(NoteModel_.noteId.equals(noteId))
        .build().findFirst();
    note!.isDeleted = true;
    final i = box.put(note, mode: PutMode.update);
    store.close();
    return i is int;
  }

  @override
  Future<List<NoteModel>?> getAllArchivedNote() async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    List<NoteModel> notes = box.query(
        NoteModel_.isArchived.equals(true)
            .and(NoteModel_.isDeleted.equals(false))
    ).build().find();
    store.close();

    return notes;
  }

  @override
  Future<List<NoteModel>?> getAllDeletedNote() async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    List<NoteModel> notes = box.query(NoteModel_.isDeleted.equals(true))
        .build().find();
    store.close();

    return notes;
  }

  @override
  Future<List<NoteModel>> getAllNote() async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    List<NoteModel> notes = box.query(
        NoteModel_.isArchived.equals(false)
            .and(NoteModel_.isDeleted.equals(false))
    ).build().find();
    store.close();

    return notes;
  }

  @override
  Future<bool> permanentlyDeleteNote({required String noteId}) async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    NoteModel? note = box.query(NoteModel_.noteId.equals(noteId))
        .build().findFirst();
    note!.isDeleted = true;
    final id = box.put(note, mode: PutMode.update);
    final val = box.remove(id);
    store.close();
    return val;
  }

  @override
  Future<bool> restoreDeletedNote({required String noteId}) async {
    Store store = await openStoreBox();
    final box = store.box<NoteModel>();
    NoteModel? note = box.query(NoteModel_.noteId.equals(noteId))
        .build().findFirst();
    note!.isDeleted = false;
    final i = box.put(note, mode: PutMode.update);
    store.close();
    return i is int;
  }




}
