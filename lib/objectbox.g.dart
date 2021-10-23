// GENERATED CODE - DO NOT MODIFY BY HAND

// Currently loading model from "JSON" which always encodes with double quotes
// ignore_for_file: prefer_single_quotes
// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:objectbox/flatbuffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';

import 'data/database/database_model.dart';
import 'data/database/model/setting_data.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

ModelDefinition getObjectBoxModel() {
  final model = ModelInfo.fromMap({
    "entities": [
      {
        "id": "1:8175331469017076460",
        "lastPropertyId": "16:4380578224422780473",
        "name": "SettingAppData",
        "properties": [
          {
            "id": "1:3594412088171641125",
            "name": "isNotificationOn",
            "type": 1,
            "dartFieldType": "bool?"
          },
          {
            "id": "2:8873153873667721739",
            "name": "isSync",
            "type": 1,
            "dartFieldType": "bool?"
          },
          {
            "id": "3:4266171809429242412",
            "name": "isSyncWithMail",
            "type": 1,
            "dartFieldType": "bool?"
          },
          {
            "id": "4:454955420807872512",
            "name": "id",
            "type": 6,
            "flags": 1,
            "dartFieldType": "int"
          },
          {
            "id": "5:3314960300935785459",
            "name": "phoneName",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "6:4394953344467088139",
            "name": "userCode",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "7:1635472740910998754",
            "name": "phoneModel",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "8:2230500204649504064",
            "name": "os",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "9:7249253569172969744",
            "name": "osVersion",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "10:7548711779967776705",
            "name": "email",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "11:8932564770398771117",
            "name": "theme",
            "type": 6,
            "dartFieldType": "int"
          },
          {
            "id": "12:9103524480953129973",
            "name": "language",
            "type": 6,
            "dartFieldType": "int"
          },
          {
            "id": "13:7816500985377256333",
            "name": "userAuthState",
            "type": 6,
            "dartFieldType": "int?"
          },
          {
            "id": "14:7239286449520180989",
            "name": "lastAuthCheck",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "15:4063724568325656414",
            "name": "location",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "16:4380578224422780473",
            "name": "createAt",
            "type": 9,
            "dartFieldType": "String?"
          }
        ],
        "relations": [],
        "backlinks": [],
        "constructorParams": [
          "isNotificationOn named",
          "isSync named",
          "isSyncWithMail named",
          "createAt named",
          "phoneName named",
          "userCode named",
          "phoneModel named",
          "email named",
          "location named",
          "os named",
          "osVersion named",
          "theme named",
          "language named",
          "userAuthState named",
          "lastAuthCheck named"
        ],
        "nullSafetyEnabled": true
      },
      {
        "id": "2:3265389183101324807",
        "lastPropertyId": "6:2802784630817855932",
        "name": "Checklist",
        "properties": [
          {
            "id": "1:4004506091922287571",
            "name": "mid",
            "type": 6,
            "flags": 1,
            "dartFieldType": "int"
          },
          {
            "id": "2:7391057659426571880",
            "name": "checklistId",
            "type": 9,
            "dartFieldType": "String"
          },
          {
            "id": "3:796793005034814947",
            "name": "title",
            "type": 9,
            "dartFieldType": "String"
          },
          {
            "id": "4:7263970995352313742",
            "name": "isAllChecked",
            "type": 1,
            "dartFieldType": "bool"
          },
          {
            "id": "5:4586948625973527366",
            "name": "creationTime",
            "type": 10,
            "dartFieldType": "DateTime?"
          },
          {
            "id": "6:2802784630817855932",
            "name": "modificationTime",
            "type": 10,
            "dartFieldType": "DateTime?"
          }
        ],
        "relations": [
          {
            "id": "1:6523285735838232126",
            "name": "boxTodoItems",
            "targetId": "4:8740558880808005525",
            "targetName": "TodoItem"
          }
        ],
        "backlinks": [],
        "constructorParams": [
          "checklistId named",
          "title named",
          "list named",
          "isAllChecked named",
          "creationTime named",
          "modificationTime named"
        ],
        "nullSafetyEnabled": true
      },
      {
        "id": "3:6376091032844962044",
        "lastPropertyId": "14:8805746004675397437",
        "name": "NoteModel",
        "properties": [
          {
            "id": "1:9140676055489006734",
            "name": "id",
            "type": 6,
            "flags": 1,
            "dartFieldType": "int"
          },
          {
            "id": "2:7674178417351246055",
            "name": "noteId",
            "type": 9,
            "dartFieldType": "String"
          },
          {
            "id": "3:6116759217421153469",
            "name": "title",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "4:5146388033241371505",
            "name": "text",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "5:8492549617886715212",
            "name": "creationTime",
            "type": 10,
            "dartFieldType": "DateTime?"
          },
          {
            "id": "6:9219499176425066233",
            "name": "modificationTime",
            "type": 10,
            "dartFieldType": "DateTime?"
          },
          {
            "id": "7:8023750729590138559",
            "name": "isDeleted",
            "type": 1,
            "dartFieldType": "bool"
          },
          {
            "id": "8:8053013302908890703",
            "name": "permanentDeleteDate",
            "type": 10,
            "dartFieldType": "DateTime?"
          },
          {
            "id": "9:7969553037941141937",
            "name": "colorValue",
            "type": 6,
            "dartFieldType": "int"
          },
          {
            "id": "10:157023549637914141",
            "name": "reminderDate",
            "type": 10,
            "dartFieldType": "DateTime?"
          },
          {
            "id": "11:1481716318011901231",
            "name": "email",
            "type": 9,
            "dartFieldType": "String?"
          },
          {
            "id": "12:8899348411700159084",
            "name": "isArchived",
            "type": 1,
            "dartFieldType": "bool"
          },
          {
            "id": "13:6012117193916797619",
            "name": "isLocked",
            "type": 1,
            "dartFieldType": "bool"
          },
          {
            "id": "14:8805746004675397437",
            "name": "savingModeValue",
            "type": 6,
            "dartFieldType": "int"
          }
        ],
        "relations": [],
        "backlinks": [],
        "constructorParams": [
          "noteId named",
          "email named",
          "isLocked named",
          "isArchived named",
          "title named",
          "text named",
          "creationTime named",
          "modificationTime named",
          "isDeleted named",
          "permanentDeleteDate named",
          "color named",
          "reminderDate named",
          "savingMode named"
        ],
        "nullSafetyEnabled": true
      },
      {
        "id": "4:8740558880808005525",
        "lastPropertyId": "3:3000974977852023844",
        "name": "TodoItem",
        "properties": [
          {
            "id": "1:3194311990419884222",
            "name": "mid",
            "type": 6,
            "flags": 1,
            "dartFieldType": "int"
          },
          {
            "id": "2:2739185732194975635",
            "name": "text",
            "type": 9,
            "dartFieldType": "String"
          },
          {
            "id": "3:3000974977852023844",
            "name": "isDone",
            "type": 1,
            "dartFieldType": "bool"
          }
        ],
        "relations": [],
        "backlinks": [],
        "constructorParams": ["text named", "isDone named"],
        "nullSafetyEnabled": true
      }
    ],
    "lastEntityId": "4:8740558880808005525",
    "lastIndexId": "0:0",
    "lastRelationId": "1:6523285735838232126",
    "lastSequenceId": "0:0",
    "modelVersion": 5
  }, check: false);

  final bindings = <Type, EntityDefinition>{};
  bindings[SettingAppData] = EntityDefinition<SettingAppData>(
      model: model.getEntityByUid(8175331469017076460),
      toOneRelations: (SettingAppData object) => [],
      toManyRelations: (SettingAppData object) => {},
      getId: (SettingAppData object) => object.id,
      setId: (SettingAppData object, int id) {
        object.id = id;
      },
      objectToFB: (SettingAppData object, fb.Builder fbb) {
        final phoneNameOffset = object.phoneName == null
            ? null
            : fbb.writeString(object.phoneName!);
        final userCodeOffset =
            object.userCode == null ? null : fbb.writeString(object.userCode!);
        final phoneModelOffset = object.phoneModel == null
            ? null
            : fbb.writeString(object.phoneModel!);
        final osOffset = object.os == null ? null : fbb.writeString(object.os!);
        final osVersionOffset = object.osVersion == null
            ? null
            : fbb.writeString(object.osVersion!);
        final emailOffset =
            object.email == null ? null : fbb.writeString(object.email!);
        final lastAuthCheckOffset = object.lastAuthCheck == null
            ? null
            : fbb.writeString(object.lastAuthCheck!);
        final locationOffset =
            object.location == null ? null : fbb.writeString(object.location!);
        final createAtOffset =
            object.createAt == null ? null : fbb.writeString(object.createAt!);
        fbb.startTable(17);
        fbb.addBool(0, object.isNotificationOn);
        fbb.addBool(1, object.isSync);
        fbb.addBool(2, object.isSyncWithMail);
        fbb.addInt64(3, object.id);
        fbb.addOffset(4, phoneNameOffset);
        fbb.addOffset(5, userCodeOffset);
        fbb.addOffset(6, phoneModelOffset);
        fbb.addOffset(7, osOffset);
        fbb.addOffset(8, osVersionOffset);
        fbb.addOffset(9, emailOffset);
        fbb.addInt64(10, object.theme);
        fbb.addInt64(11, object.language);
        fbb.addInt64(12, object.userAuthState);
        fbb.addOffset(13, lastAuthCheckOffset);
        fbb.addOffset(14, locationOffset);
        fbb.addOffset(15, createAtOffset);
        fbb.finish(fbb.endTable());
        return object.id;
      },
      objectFromFB: (Store store, Uint8List fbData) {
        final buffer = fb.BufferContext.fromBytes(fbData);
        final rootOffset = buffer.derefObject(0);

        final object = SettingAppData(
            isNotificationOn:
                const fb.BoolReader().vTableGetNullable(buffer, rootOffset, 4),
            isSync:
                const fb.BoolReader().vTableGetNullable(buffer, rootOffset, 6),
            isSyncWithMail:
                const fb.BoolReader().vTableGetNullable(buffer, rootOffset, 8),
            createAt: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 34),
            phoneName: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 12),
            userCode: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 14),
            phoneModel: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 16),
            email: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 22),
            location: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 32),
            os: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 18),
            osVersion: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 20),
            theme: const fb.Int64Reader().vTableGet(buffer, rootOffset, 24, 0),
            language:
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 26, 0),
            userAuthState:
                const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 28),
            lastAuthCheck: const fb.StringReader().vTableGetNullable(buffer, rootOffset, 30))
          ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0);

        return object;
      });
  bindings[Checklist] = EntityDefinition<Checklist>(
      model: model.getEntityByUid(3265389183101324807),
      toOneRelations: (Checklist object) => [],
      toManyRelations: (Checklist object) =>
          {RelInfo<Checklist>.toMany(1, object.mid): object.boxTodoItems},
      getId: (Checklist object) => object.mid,
      setId: (Checklist object, int id) {
        object.mid = id;
      },
      objectToFB: (Checklist object, fb.Builder fbb) {
        final checklistIdOffset = fbb.writeString(object.checklistId);
        final titleOffset = fbb.writeString(object.title);
        fbb.startTable(7);
        fbb.addInt64(0, object.mid);
        fbb.addOffset(1, checklistIdOffset);
        fbb.addOffset(2, titleOffset);
        fbb.addBool(3, object.isAllChecked);
        fbb.addInt64(4, object.creationTime?.millisecondsSinceEpoch);
        fbb.addInt64(5, object.modificationTime?.millisecondsSinceEpoch);
        fbb.finish(fbb.endTable());
        return object.mid;
      },
      objectFromFB: (Store store, Uint8List fbData) {
        final buffer = fb.BufferContext.fromBytes(fbData);
        final rootOffset = buffer.derefObject(0);
        final creationTimeValue =
            const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 12);
        final modificationTimeValue =
            const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 14);
        final object = Checklist(
            checklistId:
                const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
            title: const fb.StringReader().vTableGet(buffer, rootOffset, 8, ''),
            isAllChecked:
                const fb.BoolReader().vTableGet(buffer, rootOffset, 10, false),
            creationTime: creationTimeValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(creationTimeValue),
            modificationTime: modificationTimeValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(modificationTimeValue))
          ..mid = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
        InternalToManyAccess.setRelInfo(object.boxTodoItems, store,
            RelInfo<Checklist>.toMany(1, object.mid), store.box<Checklist>());
        return object;
      });
  bindings[NoteModel] = EntityDefinition<NoteModel>(
      model: model.getEntityByUid(6376091032844962044),
      toOneRelations: (NoteModel object) => [],
      toManyRelations: (NoteModel object) => {},
      getId: (NoteModel object) => object.id,
      setId: (NoteModel object, int id) {
        object.id = id;
      },
      objectToFB: (NoteModel object, fb.Builder fbb) {
        final noteIdOffset = fbb.writeString(object.noteId);
        final titleOffset =
            object.title == null ? null : fbb.writeString(object.title!);
        final textOffset =
            object.text == null ? null : fbb.writeString(object.text!);
        final emailOffset =
            object.email == null ? null : fbb.writeString(object.email!);
        fbb.startTable(15);
        fbb.addInt64(0, object.id);
        fbb.addOffset(1, noteIdOffset);
        fbb.addOffset(2, titleOffset);
        fbb.addOffset(3, textOffset);
        fbb.addInt64(4, object.creationTime?.millisecondsSinceEpoch);
        fbb.addInt64(5, object.modificationTime?.millisecondsSinceEpoch);
        fbb.addBool(6, object.isDeleted);
        fbb.addInt64(7, object.permanentDeleteDate?.millisecondsSinceEpoch);
        fbb.addInt64(8, object.colorValue);
        fbb.addInt64(9, object.reminderDate?.millisecondsSinceEpoch);
        fbb.addOffset(10, emailOffset);
        fbb.addBool(11, object.isArchived);
        fbb.addBool(12, object.isLocked);
        fbb.addInt64(13, object.savingModeValue);
        fbb.finish(fbb.endTable());
        return object.id;
      },
      objectFromFB: (Store store, Uint8List fbData) {
        final buffer = fb.BufferContext.fromBytes(fbData);
        final rootOffset = buffer.derefObject(0);
        final creationTimeValue =
            const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 12);
        final modificationTimeValue =
            const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 14);
        final permanentDeleteDateValue =
            const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 18);
        final reminderDateValue =
            const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 22);
        final object = NoteModel(
            noteId:
                const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
            email: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 24),
            isLocked:
                const fb.BoolReader().vTableGet(buffer, rootOffset, 28, false),
            isArchived:
                const fb.BoolReader().vTableGet(buffer, rootOffset, 26, false),
            title: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 8),
            text: const fb.StringReader()
                .vTableGetNullable(buffer, rootOffset, 10),
            creationTime: creationTimeValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(creationTimeValue),
            modificationTime: modificationTimeValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(modificationTimeValue),
            isDeleted:
                const fb.BoolReader().vTableGet(buffer, rootOffset, 16, false),
            permanentDeleteDate: permanentDeleteDateValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(permanentDeleteDateValue),
            reminderDate: reminderDateValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(reminderDateValue))
          ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
          ..colorValue =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 20, 0)
          ..savingModeValue =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 30, 0);

        return object;
      });
  bindings[TodoItem] = EntityDefinition<TodoItem>(
      model: model.getEntityByUid(8740558880808005525),
      toOneRelations: (TodoItem object) => [],
      toManyRelations: (TodoItem object) => {},
      getId: (TodoItem object) => object.mid,
      setId: (TodoItem object, int id) {
        object.mid = id;
      },
      objectToFB: (TodoItem object, fb.Builder fbb) {
        final textOffset = fbb.writeString(object.text);
        fbb.startTable(4);
        fbb.addInt64(0, object.mid);
        fbb.addOffset(1, textOffset);
        fbb.addBool(2, object.isDone);
        fbb.finish(fbb.endTable());
        return object.mid;
      },
      objectFromFB: (Store store, Uint8List fbData) {
        final buffer = fb.BufferContext.fromBytes(fbData);
        final rootOffset = buffer.derefObject(0);

        final object = TodoItem(
            text: const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
            isDone:
                const fb.BoolReader().vTableGet(buffer, rootOffset, 8, false))
          ..mid = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

        return object;
      });

  return ModelDefinition(model, bindings);
}

class SettingAppData_ {
  static final isNotificationOn =
      QueryBooleanProperty(entityId: 1, propertyId: 1, obxType: 1);
  static final isSync =
      QueryBooleanProperty(entityId: 1, propertyId: 2, obxType: 1);
  static final isSyncWithMail =
      QueryBooleanProperty(entityId: 1, propertyId: 3, obxType: 1);
  static final id =
      QueryIntegerProperty(entityId: 1, propertyId: 4, obxType: 6);
  static final phoneName =
      QueryStringProperty(entityId: 1, propertyId: 5, obxType: 9);
  static final userCode =
      QueryStringProperty(entityId: 1, propertyId: 6, obxType: 9);
  static final phoneModel =
      QueryStringProperty(entityId: 1, propertyId: 7, obxType: 9);
  static final os = QueryStringProperty(entityId: 1, propertyId: 8, obxType: 9);
  static final osVersion =
      QueryStringProperty(entityId: 1, propertyId: 9, obxType: 9);
  static final email =
      QueryStringProperty(entityId: 1, propertyId: 10, obxType: 9);
  static final theme =
      QueryIntegerProperty(entityId: 1, propertyId: 11, obxType: 6);
  static final language =
      QueryIntegerProperty(entityId: 1, propertyId: 12, obxType: 6);
  static final userAuthState =
      QueryIntegerProperty(entityId: 1, propertyId: 13, obxType: 6);
  static final lastAuthCheck =
      QueryStringProperty(entityId: 1, propertyId: 14, obxType: 9);
  static final location =
      QueryStringProperty(entityId: 1, propertyId: 15, obxType: 9);
  static final createAt =
      QueryStringProperty(entityId: 1, propertyId: 16, obxType: 9);
}

class Checklist_ {
  static final mid =
      QueryIntegerProperty(entityId: 2, propertyId: 1, obxType: 6);
  static final checklistId =
      QueryStringProperty(entityId: 2, propertyId: 2, obxType: 9);
  static final title =
      QueryStringProperty(entityId: 2, propertyId: 3, obxType: 9);
  static final isAllChecked =
      QueryBooleanProperty(entityId: 2, propertyId: 4, obxType: 1);
  static final creationTime =
      QueryIntegerProperty(entityId: 2, propertyId: 5, obxType: 10);
  static final modificationTime =
      QueryIntegerProperty(entityId: 2, propertyId: 6, obxType: 10);
  static final boxTodoItems = QueryRelationMany<Checklist, TodoItem>(
      sourceEntityId: 2, targetEntityId: 4, relationId: 1);
}

class NoteModel_ {
  static final id =
      QueryIntegerProperty(entityId: 3, propertyId: 1, obxType: 6);
  static final noteId =
      QueryStringProperty(entityId: 3, propertyId: 2, obxType: 9);
  static final title =
      QueryStringProperty(entityId: 3, propertyId: 3, obxType: 9);
  static final text =
      QueryStringProperty(entityId: 3, propertyId: 4, obxType: 9);
  static final creationTime =
      QueryIntegerProperty(entityId: 3, propertyId: 5, obxType: 10);
  static final modificationTime =
      QueryIntegerProperty(entityId: 3, propertyId: 6, obxType: 10);
  static final isDeleted =
      QueryBooleanProperty(entityId: 3, propertyId: 7, obxType: 1);
  static final permanentDeleteDate =
      QueryIntegerProperty(entityId: 3, propertyId: 8, obxType: 10);
  static final colorValue =
      QueryIntegerProperty(entityId: 3, propertyId: 9, obxType: 6);
  static final reminderDate =
      QueryIntegerProperty(entityId: 3, propertyId: 10, obxType: 10);
  static final email =
      QueryStringProperty(entityId: 3, propertyId: 11, obxType: 9);
  static final isArchived =
      QueryBooleanProperty(entityId: 3, propertyId: 12, obxType: 1);
  static final isLocked =
      QueryBooleanProperty(entityId: 3, propertyId: 13, obxType: 1);
  static final savingModeValue =
      QueryIntegerProperty(entityId: 3, propertyId: 14, obxType: 6);
}

class TodoItem_ {
  static final mid =
      QueryIntegerProperty(entityId: 4, propertyId: 1, obxType: 6);
  static final text =
      QueryStringProperty(entityId: 4, propertyId: 2, obxType: 9);
  static final isDone =
      QueryBooleanProperty(entityId: 4, propertyId: 3, obxType: 1);
}
