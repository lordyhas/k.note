part of data.model;


class AppData extends DataToMap{
  DateTime now = DateTime.now();
  final id;
  final int? isFirstUse;
  final String? phoneName;
  final String? userCode;
  final String? phoneModel;
  final String? os;
  final String? osVersion;
  final String? email;
  final int theme;
  final int language;
  final userAuthState;
  final lastAuthCheck;
  final location;
  final createAt;

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
  String toString() {
    return super.toString();
  }
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
    print(toString());
  }

  AppData copyWith({
    id,
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
    lastAuthCheck,
    location,}) {
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