library data.model;
import 'dart:ffi';
import 'dart:io';
import 'package:objectbox/objectbox.dart';
import 'package:utils_component/utils_component.dart';

import '../app_bloc/auth_repository/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'model/note_model.dart';

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



