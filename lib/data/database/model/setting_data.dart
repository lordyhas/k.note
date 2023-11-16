
import 'package:flutter/foundation.dart';

class SettingAppData {
  bool? isNotificationOn;
  bool? isSync;
  bool? isSyncWithMail;
  DateTime now = DateTime.now();
  int id = 0;
  String? phoneName;
  String? userCode;
  String? phoneModel;
  String? os;
  String? osVersion;
  String? email;
  int theme;
  int language;
  int? userAuthState;
  String? lastAuthCheck;
  String? location;
  String? createAt;

  SettingAppData({
    this.isNotificationOn = true,
    this.isSync = false,
    this.isSyncWithMail = false,
    this.createAt,
    this.phoneName,
    this.userCode,
    this.phoneModel = "",
    this.email,
    this.location,
    this.os,
    this.osVersion,
    this.theme = 0,
    this.language = 1,
    this.userAuthState = 0,
    this.lastAuthCheck,
  });


  toDisplay() {
    var map = {
      'id': id,
      'user_code': userCode,
      'email': email,
      'phone_name': phoneName,
      'phone_model': phoneModel,
      'operatingSystem': os,
      'operatingSystemVersion': osVersion,
      'theme': theme,
      'language': language,
      'user_auth_state': userAuthState,
      'last_auth_check': lastAuthCheck,
      'location': location,
      'create_at': createAt,
    };
    debugPrint("*** \n${toString()}{");
    map.forEach((key, value) => debugPrint("$key : $value,"));
    debugPrint('} \n***');
  }
}




