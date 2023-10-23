library data.model;
import 'dart:io';
import '../app_bloc/auth_repository/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'model/user_data.dart';
part 'model/note_model.dart';

part 'model/location_data.dart';

part 'model/app_data.dart';

//part '';
//part '';

abstract class DataToMap{
   Map<String, dynamic> asMap();
   void toDisplay();

   String autoGenerateUniqueId(String constantKey){
     final DateTime now = DateTime.now();
     /*final String unique = "${now.year}${now.month}${now.day}"
         "${now.hour}${now.minute}${now.second}${now.millisecond}"
         "${now.microsecond}";*/
     final String formatted = DateFormat('yyyyMMddHms').format(now);
     print(formatted); // something like 2013-04-20
     return constantKey.trim()+formatted;
   }
}



