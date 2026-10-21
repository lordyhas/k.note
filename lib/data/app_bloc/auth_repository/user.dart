import 'package:equatable/equatable.dart';

/// {@template user}
/// User model
///
/// Mirrors the signed-in Firebase Auth user. Every field comes from the auth
/// token, so none of them can be tampered with by the client.
///
/// Account status (e.g. a blocked account) is deliberately not modelled here:
/// it is controlled by an admin in Firebase Auth and enforced by
/// `firestore.rules`.
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.email,
    required this.id,
    required this.name,
    required this.photoMail,
    this.creationDate,
    this.lastDate,
    this.phoneNumber,
    this.isAnonymous,
    this.isCheckMail,
  });

  /// The current user's email address, empty for anonymous accounts.
  final String email;

  /// The current user's id (Firebase Auth uid).
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photoMail;

  /// When the account was created.
  final DateTime? creationDate;

  /// When the user last signed in.
  final DateTime? lastDate;

  /// The phone number of user
  final String? phoneNumber;

  /// isCheckMail is an equivalent of [emailVerified]
  final bool? isCheckMail;

  /// Whether the user signed in anonymously.
  final bool? isAnonymous;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(email: '', id: '', name: null, photoMail: null);

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoMail,
    String? phoneNumber,
    bool? isAnonymous,
    bool? isCheckMail,
    DateTime? creationDate,
    DateTime? lastDate,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        photoMail: photoMail ?? this.photoMail,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        lastDate: lastDate ?? this.lastDate,
        creationDate: creationDate ?? this.creationDate,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        isCheckMail: isCheckMail ?? this.isCheckMail,
      );

  /// The profile document stored in Firestore.
  ///
  /// Keep it in sync with `profileKeys()` in `firestore.rules`, which rejects
  /// any other field.
  Map<String, dynamic> asMap() => {
        'id': id,
        'name': name,
        'email': email,
        'photo_mail': photoMail,
        'creation_time': creationDate,
        'last_login': lastDate,
      };

  @override
  List<Object?> get props => [email, id, name, photoMail];
}
