part of '../database_model.dart';


class AppData extends DataToMap{
  DateTime now = DateTime.now();
  final dynamic id;
  final int? isFirstUse;
  final String? phoneName;
  final String? userCode;
  final String? phoneModel;
  final String? os;
  final String? osVersion;
  final String? email;
  final int theme;
  final int language;
  final dynamic userAuthState;
  final dynamic lastAuthCheck;
  final dynamic location;
  final dynamic createAt;

  AppData({
    this.createAt,
    this.id ,
    this.isFirstUse,
    this.phoneName ,
    this.userCode,
    this.phoneModel = "",
    this.email,
    this.location,
    this.os,
    this.osVersion,
    this.theme = 1,
    this.language = 1,
    this.userAuthState = 0,
    this.lastAuthCheck,
  }) ;



  final _table = "APPDATA";
  String get tableName => _table;

  static String getTableName = "APPDATA";

  @override
  Map<String, dynamic> asMap() => {
    'id': id,
    'first': isFirstUse,
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

  @override
  void toDisplay() {
    debugPrint(toString());
  }

  AppData copyWith({
    dynamic id,
    int? isFirstUse,
    String? phoneName,
    String? userCode,
    String? phoneModel,
    String? os,
    String? osVersion,
    String? email,
    int? theme,
    int? language,
    int? userAuthState,
    dynamic lastAuthCheck,
    dynamic location,}) {
    return  AppData(
      id: id ?? this.id,
      isFirstUse: isFirstUse ?? this.isFirstUse,
      phoneName: phoneName ?? this.phoneName,
      userCode: userCode?? this.userCode,
      phoneModel: phoneModel ?? this.phoneModel,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      email: email ?? this.email,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      userAuthState: userAuthState ?? this.userAuthState,
      lastAuthCheck: lastAuthCheck ?? this.lastAuthCheck,
      location: location ?? this.location,
    );
  }



}