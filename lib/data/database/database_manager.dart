//ignore_for_file : owercase_with_underscores
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

//import '../../objectbox.g.dart';
import '../../objectbox.g.dart';
import '../values.dart';
import 'database_model.dart';
import 'model/SettingData.dart';

class ObjectBoxManager {

  Store? storeManager;

  ObjectBoxManager.empty();
  ObjectBoxManager.initStore(){
    //this.storeManager = storeBox;

    this.openStoreBox().then((store) {
      final box = store.box<SettingAppData>();
      if(box.isEmpty()){
        final settingAppData = SettingAppData(
            createAt: new DateTime.now().toString(),
            os: Platform.operatingSystem,
            osVersion: Platform.operatingSystemVersion,
            phoneModel: 'SmartPhone not checked');
        final id = box.put(settingAppData);      // note: sets note.id and also returns it
        print("*** *** *** *** *** ***");
        print('new note got id=$id, which is the same as note.id=${settingAppData.id}');
        print('re-read note: ${box.get(id)}');
        print('Set tingAppData Added Once : ${box.get(id)?.toDisplay()} ###########');

      }
    });
  }

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

  /*Future<bool> update_() async {
    bool value = false;
    Store store = await openStoreBox();

    store.close();
    return value;

  }
  Future<bool> add() async {
    bool value = false;
    Store store = await openStoreBox();

    store.close();
    return value;

  }
  Future<void> get_() async {
    bool value = false;
    Store store = await openStoreBox();

    store.close();


  }*/

}
