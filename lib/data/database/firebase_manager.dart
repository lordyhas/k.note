
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utils_component/utils_component.dart';
import '../app_database.dart';
import '../app_bloc/auth_repository/user.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FirebaseManager {
  final User user;
  FirebaseManager._(this.user);
  FirebaseManager.empty() : this._(User.empty);
  FirebaseManager.user(User user) : this._(user);

  factory FirebaseManager.init([User? user]){
    /*FirebaseFirestore.instance.settings = const Settings(
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );*/
    return user == null ? FirebaseManager.empty() : FirebaseManager.user(user);
  }

  close(){}

  // Create a CollectionReference called users that references the firestore collection
  CollectionReference<Map<String, dynamic>>  users = FirebaseFirestore.instance
      .collection('K_NOTE')
      .doc('general_data')
      .collection('USERS');
  CollectionReference<Map<String, dynamic>>  colG = FirebaseFirestore.instance
      .collection('K_NOTE');

  ///CollectionReference get collectionUser => colG.doc('general_data').collection('USERS');
  ///CollectionReference get collectionNote => colG.doc('general_data').collection('NOTES');


  CollectionReference<Map<String, dynamic>> get collectionUserNote => users
      .doc(user.id).collection('notes');

  /*DocumentReference getDoc({required String docName }){
    return colG.doc(docName);
  }*/

  Future<NoteModel?> getNoteInCloud({
    required String noteId
  }) async {
    var docSnap = await collectionUserNote.doc(noteId).get();

    Map<String, dynamic> map = docSnap.data()!;

    if(docSnap.exists) return NoteModel.fromMap(map);
    return null;
  }

  /// get all note by mail


  Future<List<NoteModel>> getAllNoteInCloud() async {
    var docSnap = await collectionUserNote
        //.where('email', isEqualTo: user.email)
        .where('is_deleted', isEqualTo: false)
        .where('is_archived', isEqualTo: false)
        .get();

    debugPrint("All Note for User => [$user]");

    final maps = docSnap.docs.map((e) => e.data()).toList();
    if(maps.isNotEmpty ) {
      return  maps.map((e) => NoteModel.fromMap(e)).toList();
    }
    return [];
  }

  /// get all archived note by mail


  Future<List<NoteModel>?> getAllArchivedNoteInCloud() async {
    var docSnap = await collectionUserNote
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

  /// get all deleted note by mail


  Future<List<NoteModel>?> getAllDeletedNoteInCloud() async {
    var docSnap = await collectionUserNote
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
  }

  ///  this method will add [NoteData] in Cloud firebase
  ///
  ///
  Future<void> addNoteInCloud({required NoteModel note,}) {
    //note.creationTime = new DateTime.now();
    //todo: use own firebase id
    return collectionUserNote.doc(note.id).set(note.asMap())
        .then((value) {
            Log.i("Note Added : $note");
            return note.toDisplay();
        })
        .catchError((error) => Log.i("Failed to add note "
        ": $error"));
    //note.toString();
  }

  ///  this method will set [NoteData] in Cloud firebase
  ///
  ///
  Future<void> setNoteInCloud(String userId,{required NoteModel note}) {
    //note.creationTime = new DateTime.now();
    return collectionUserNote.doc(note.id).set(note.id);
  }

  //

  Future<void> permanentlyDeleteNote({required String noteId}) {
    return collectionUserNote
        .doc(noteId)
        .delete()
        .then((value) => Log.i("Note :$noteId Deleted"))
        .catchError((error) => Log.i("Failed to delete note: $error"));
  }

  Future<void> deleteNote({
    required String noteId,
  }) async {
    String key = 'is_deleted';
    return collectionUserNote.doc(noteId).update({key:true})
        .then((v) => Log.i("Note : $noteId move in trash"))
        .catchError((error)=> Log.i("Failed to put in trash : $error"));
  }

  Future<void> restoreDeletedNote({
    required String noteId,
  }) async {
    String key = 'is_deleted';
    return collectionUserNote.doc(noteId).update({key:false})
        .then((v) => Log.i('Restore from trash,'))
        .catchError((error) => Log.i("Failed to restore: $error"));
  }

  Future<void> archiveNote({
    required String noteId,
    required bool archived,
  }) async {
    String key = 'is_archived';
    return collectionUserNote.doc(noteId).update({key:archived})
        .then((v) => Log.i('Restore from trash : $archived,'))
        .catchError((error) => Log.i("Failed to archive: $error"));
  }

  /// Update [NoteData] text with map by {key : value}

  Future<void> updateNoteText({
    required String userId,
    required String id,
    required String value}) async {
    String key = 'text';
    return collectionUserNote.doc(id).update({key:value})
        .then((v) => Log.i('Updated Text'))
        .catchError((error)=> Log.i("Failed to update: $error"));
  }

  /// Update [NoteData] title with map by {key : value}

  Future<void> updateNoteTitle({
    required String userId,
    required String id,
    required String value}) async {
    String key = 'title';
    return collectionUserNote.doc(id).update({key:value});
  }

  /// Update data with map by {key : value}

  Future<void> updateUserInformation({
    required String key,
    required String value}) async {
    return users.doc(user.id).update({key:value});
  }


  /// Update the all user information that has changed

  Future<void> updateUser({required User user}) async {
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

  Future<void> updateLastLogin() async {
    return users.doc(user.id).update({'last_login': DateTime.now()});
  }

  Future<void> addData({required Map<String, dynamic> dataAsMap, collection}){
    return collection.add(dataAsMap)
        .then((value) => debugPrint("Data Added "))
        .catchError((error) => debugPrint("Failed to add data: $error"));

  }


  Future<void> updateUserLocation(userId,GeoPoint location) {
    return users
        .doc(userId)
        .update({'location': const GeoPoint(53.483959, -2.244644)})
        .then((value) => debugPrint("User Location Updated"))
        .catchError((error) => debugPrint("Failed to update location user: $error"));
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
                .then((value) => Log.i("User Added : $user"))
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

  ///  this method will add [User] in Cloud firebase
  ///
  ///
  Future<void> addUserData({required UserData userData}) {
    return users.add(userData.asMap())
        .then((value) => debugPrint("User Added : $userData"))
        .catchError((error) => debugPrint("Failed to add user: $error"));
  }



  Future<DocumentSnapshot> getUser(documentId){
    return  users.doc(documentId).get();
    /**
     * is used in a [FutureBuilder<DocumentSnapshot>] Widget with

     FutureBuilder<DocumentSnapshot>(
        /// put [getUser] here
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          return Text("Full Name: ${data['full_name']} ${data['last_name']}");
        }

        return Text("loading");
      },
    );*/
  }
  /// Call as stream of a [StreamBuilder] Widget
  Stream get collectionNoteStream => colG.snapshots();



}







