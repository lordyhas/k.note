part of data.model;

class UserData extends DataToMap {
  final dynamic id;
  final dynamic name;
  final dynamic userCode;
  final dynamic phoneNumber;
  final dynamic email;
  final dynamic location;
  final dynamic lastConnection;

  UserData({
    this.id,
    this.name,
    this.userCode,
    this.phoneNumber,
    this.email,
    this.location,
    this.lastConnection,
  });

  final _table = "USERS";
  String get tableName => _table;

  UserData fromUser({required User user}) => UserData(
        id: user.uid,
        name: user.displayName,
        userCode: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
      );

  @override
  String toString() {
    return 'UserData{id: $id, name: $name, number: $phoneNumber, '
        'email: $email, location: $location}';
  }

  @override
  Map<String, dynamic> asMap() => {
        'id': id,
        'name': name,
        'user_code': userCode,
        'phone_number': phoneNumber,
        'email': email,
        'location': location,
        'last_location': lastConnection,
      };

  @override
  void toDisplay() {
    debugPrint(toString());
  }
}
