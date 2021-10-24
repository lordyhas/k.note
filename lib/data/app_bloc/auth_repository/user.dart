


import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {

  /// todo: resolved the probleme of email if is in facebook user
  /// {@macro user}
  const User({
    required this.email,
    required this.id,
    required this.name,
    required this.photoMail,
    this.photoCloud,
    this.creationDate,
    this.lastDate,
    this.phoneNumber,
    this.isAnonymous,
    this.isCheckMail,
    this.location,
    this.lastConnection,
    this.verifiedAccount = false,
    this.isDataCloud = false,
    this.isBlocked = false,
  })  : assert(email != null),
        assert(id != null);




  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photoMail;
  final photoCloud;

  ///
  final DateTime? creationDate;
  final DateTime? lastDate;
  final DateTime? lastConnection;

  /// The phone number of user
  final String? phoneNumber;



  /// isCheckMail is an equivalent of [emailVerified]
  final bool? isCheckMail;


  /// isAnonymous will be true if [isCheckMail] is false
  final bool? isAnonymous;

  /// The current location, mobile position
  final location;

  /// If all value is okay and verified in Database will be true, else false
  final bool verifiedAccount;

  /// It will be true if data from cloud else false
  final bool isDataCloud;

  /// [isBlocked] will be true if the [User] are not allowed to use this app
  final bool isBlocked;

  // The fix location like the home address
 // final homeLocation;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(email: '', id: '', name: null, photoMail: null);

  /// copyWith method, will help to get [UserData] saved in FireCloud
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoMail,
    photoCloud,
    String? phoneNumber,
    bool? isAnonymous,
    bool? isEmail,
    DateTime? creationTime,
    DateTime? lastConnection,
    DateTime? lastDate,
    location,
    bool? verifiedAccount,
    bool? isDataCloud,
    bool? isBlocked,

  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    photoMail: photoMail ?? this.photoMail,
    photoCloud: photoCloud ?? this.photoCloud,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    lastDate: lastDate ?? this.lastDate,
    creationDate: creationTime ?? this.creationDate,
    isAnonymous: isAnonymous ?? this.isAnonymous,
    isCheckMail: isEmail ?? this.isCheckMail,
    lastConnection: lastConnection ?? this.lastConnection,
    verifiedAccount: verifiedAccount ?? this.verifiedAccount,
    location: location ?? this.location,
    isDataCloud: isDataCloud ?? this.isDataCloud,
    isBlocked: isBlocked ?? this.isBlocked,

  );


  Map<String, dynamic> asMap() => {
    'id'                : this.id,
    'name'              : this.name,
    'email'             : this.email,
    'photo_profile'     : this.photoCloud,
    'photo_mail'        : this.photoMail,
    'phone_number'      : this.phoneNumber,
    'last_login'        : this.lastDate,
    'creation_time'     : this.creationDate,
    'last_connection'   : this.lastConnection ?? DateTime.now() ,
    'is_check_mail'     : this.isCheckMail,
    'verified_account'  : this.verifiedAccount,
    'location'          : this.location,
    'is_data_cloud'     : this.isDataCloud,
    'isBlocked'         : this.isBlocked,
    'field_field'       : null,
    //'':this,

  };

  @override
  List<Object?> get props => [email, id, name, photoMail];
}
