library data.model;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'model/user_data.dart';
part 'model/note_model.dart';

part 'model/location_data.dart';

part 'model/app_data.dart';

//part '';
//part '';

abstract class DataToMap {
  Map<String, dynamic> asMap();
  void toDisplay();

  /*String autoGenerateUniqueId(String constantKey){
     final DateTime now = DateTime.now();
     final String formatted = DateFormat('yyyyMMddHms').format(now);
     print(formatted); // something like 2013-04-20
     return constantKey.trim()+formatted;
   }*/
}
