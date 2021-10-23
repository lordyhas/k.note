
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utils_component/utils_component.dart';
import '../app_database.dart';
import '../app_bloc/auth_repository/user.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'interface_model.dart';

class FirebaseManager implements InterfaceNoteModel {

  FirebaseManager(){
    //FirebaseFirestore.enablePersistence();
  }

  factory FirebaseManager.init(){
    FirebaseFirestore.instance.settings = const Settings(
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    return FirebaseManager();
  }

  void close(){}

  // Create a CollectionReference called K_NOTE that references the firestore collection
  CollectionReference<Map<String, dynamic>>  colG = FirebaseFirestore.instance.collection('K_NOTE');


  CollectionReference<Map<String, dynamic>>  users = FirebaseFirestore.instance
      .collection('K_NOTE')
      .doc('general_data')
      .collection('USERS');



  CollectionReference<Map<String, dynamic>>   collectionUserNote({required String userId}) => users.doc(userId).collection('notes');


  /// Update the all user information that has changed

  Future<void> updateUserAll({required User user}) async {
    //var docId = "";
    return users.doc(user.id).update(user.asMap());
  }

  /// Update image user that used as profile image

  Future<void> updateImageProfile(docId, Uint8List path) async {
    return users.doc(docId).update({'photo_profile': Blob(path)});
  }



  Future<void> updateLastModificationTime({
    required String docId, bool show = false,
  }) async {
    return users.doc(docId).update({'last_time': DateTime.now()});
  }

  ///this method will add [User] from [firebase_auth] in Cloud as [cloud_firestore]
  ///- if the [User] is already exist in cloud
  ///his information will be change by new [User] information
  ///- else will create an new [User]
  ///
  Future<void> addUserInCloud({required User user}) async {
    return users.doc(user.email).get()
        .then((DocumentSnapshot documentSnapshot) {
          if (!documentSnapshot.exists) {
            //print('Document exists on the database');
            return users.doc(user.id)
                .set(user.copyWith(isDataCloud:true).asMap())
                .then((value) => Log.i("User Added : " + user.toString()))
                .catchError((error) => Log.i("Failed to add user in cloud: $error"));
          }
        });

    /*return users.doc(user.id).set(user.asMap())
        .then((value) => print("User Added : " + user.toString()))
        .catchError((error) => print("Failed to add user in cloud: $error"));*/
  }

  Future<User> getUserInCloud({String? userId}) async {
    User user;
    var doc = (await users.doc(userId).get());
    if(!doc.exists) return User.empty;
    Map<String, dynamic> data = doc.data()!;
    user = User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      photoCloud: data['photo_profile'],
      photoMail: data['photo_mail'],
      creationDate: data['creation_time'].toDate(),
      lastDate: data['last_login'].toDate(),
      lastConnection: data['last_connection'].toDate(),
      phoneNumber: data['phone_number'],
      isCheckMail: data['is_check_mail'],
      verifiedAccount: data['verified_account'],
      location: data['location'],
      isDataCloud: data['is_data_cloud'] ?? false,
      isBlocked: data['isBlocked'],
      //photo: data[''],
    );

    return user;
  }

  /// Update data with map by {key : value}

  Future<void> updateUserInformation({
    required String userId,
    required String key,
    required String value}) async {
    return users.doc(userId).update({key:value});
  }

  /// Update [NoteData] text with map by {key : value}

  Future<void> updateNoteText ({
    required String userId,

    required String id,
    required String value}) async {
    String key = 'text';
    return collectionUserNote(userId: userId).doc(id).update({key:value})
        .then((v) => Log.i('Updated Text'))
        .catchError((error)=> Log.i("Failed to update: $error"));
  }

  /// Update [NoteData] title with map by {key : value}

  Future<void> updateNoteTitle({
    required String userId,
    required String id,
    required String value}) async {
    String key = 'title';
    return collectionUserNote(userId: userId).doc(id).update({key:value});
  }


  ///  getNoteInCloud
  Future<NoteModel?> getNoteInCloud({
    required String userId, required String noteId
  }) async {
    var docSnap = await collectionUserNote(userId: userId).doc(noteId).get();

    Map<String, dynamic> map = docSnap.data()!;
    //map['id'] = docSnap.reference.id;
    if(docSnap.exists) return NoteModel.fromMap(map);
    return null;
    /*.then((value){
      if(value.exists) map = value.data()!;
    });*/
    //return map;
  }

  @override
  Future<NoteModel?> getNote({required String userId, required String noteId}) {
    return getNoteInCloud(userId: userId, noteId: noteId);
  }

  /// get all note by mail


  Future<List<NoteModel>> getAllNoteInCloud({required User user}) async {
    var docSnap = await collectionUserNote(userId: user.id!,)
    //.where('email', isEqualTo: user.email)
        .where('is_deleted', isEqualTo: false)
        .where('is_archived', isEqualTo: false)
        .get();

    Log.i('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    Log.i(user.toString());

    List<Map<String, dynamic>> maps = docSnap.docs.map((e) => e.data()).toList();
    //List<Map<String, dynamic>> maps = docSnap.docs.map((e) => e.data()).toList();
    if(maps.isNotEmpty ) {
      return  maps.map((e) => NoteModel.fromMap(e)).toList();
    }
    return [];

  }

  @override
  Future<List<NoteModel>> getAllNote({required User user}) {
    return getAllNoteInCloud(user: user);
  }

  /// get all archived note by mail

  Future<List<NoteModel>?> getAllArchivedNoteInCloud(User user) async {
    var docSnap = await collectionUserNote(userId: user.id!,)
        .where('email', isEqualTo: user.email)
        .where('is_deleted', isEqualTo: false)
        .where('is_archived', isEqualTo: true)
        .get();

    //List<Map<String, dynamic>> maps = docSnap.docs.map((e) => e.data()).toList();
    return docSnap.docs.map((e)  => NoteModel.fromMap(e.data()) ).toList();

    /*return List<NoteModel>.generate(maps.length,
              (index) => NoteModel.fromMap(maps.elementAt(index)
          )
      );*/

  }

  @override
  Future<List<NoteModel>?> getAllArchivedNote({required User user}) {
    return getAllArchivedNoteInCloud(user);
  }

  /// get all deleted note by mail


  Future<List<NoteModel>?> getAllDeletedNoteInCloud(User user) async {
    var docSnap = await collectionUserNote(userId: user.id!,)
        .where('email', isEqualTo: user.email)
        .where('is_deleted', isEqualTo: true)
        .where('is_archived', isEqualTo: false)
        .get();
    //var id = docSnap.docs.forEach((e) {e.id});
    List<Map<String, dynamic>> maps = docSnap.docs.map((e) => e.data()).toList();
    return List<NoteModel>.generate(maps.length,
            (index) => NoteModel
            .fromMap(maps.elementAt(index)
        )
    );
    //return null;
    /*.then((value){
      if(value.exists) map = value.data()!;
    });*/
    //return map;
  }

  @override
  Future<List<NoteModel>?> getAllDeletedNote({required User user}) {
    return getAllDeletedNoteInCloud(user);
  }

  ///  this method will add [NoteData] in Cloud firebase
  ///
  ///
  Future<void> addNoteInCloud({required NoteModel note, required String userId}) {
    //note.creationTime = new DateTime.now();

    return collectionUserNote(userId: userId).doc(note.noteId).set(note.asMap())
        .then((value) {
      Log.i("Note Added : " + note.toString());
      return note.toDisplay();
    })
        .catchError((error) => Log.i("Failed to add note "
        ": $error"));
    //note.toString();
  }

  @override
  Future<void> addNote({required NoteModel note, required String userId}) {
    return addNoteInCloud(note: note, userId: userId);
  }

  ///  this method will set [NoteData] in Cloud firebase
  ///
  ///
  Future<void> setNoteInCloud(String userId,{required NoteModel note}) {
    //note.creationTime = new DateTime.now();
    return collectionUserNote(userId: userId,).doc(note.noteId).set(note.asMap());
  }


  @override
  Future<void> setNote({required String userId, required NoteModel note}) {
    return setNoteInCloud(userId, note: note);
  }

  //

  @override
  Future<void> permanentlyDeleteNote({required String userId, required String noteId}) {
    return collectionUserNote(userId: userId)
        .doc(noteId)
        .delete()
        .then((value) => Log.i("Note :$noteId Deleted"))
        .catchError((error) => Log.i("Failed to delete note: $error"));
  }

  @override
  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    String key = 'is_deleted';
    return collectionUserNote(userId: userId).doc(noteId).update({key:true})
        .then((v) => Log.i("Note : $noteId move in trash"))
        .catchError((error)=> Log.i("Failed to put in trash : $error"));
  }

  @override
  Future<void> restoreDeletedNote({
    required String userId,
    required String noteId,
  }) async {
    String key = 'is_deleted';
    return collectionUserNote(userId: userId).doc(noteId).update({key:false})
        .then((v) => Log.i('Restore from trash,'))
        .catchError((error) => Log.i("Failed to restore: $error"));
  }

  @override
  Future<void> archiveNote({
    required String userId,
    required String noteId,
    required bool archived,
  }) async {
    String key = 'is_archived';
    return collectionUserNote(userId: userId).doc(noteId).update({key:archived})
        .then((v) => Log.i('Restore from trash : $archived,'))
        .catchError((error) => Log.i("Failed to archive: $error"));
  }









}







