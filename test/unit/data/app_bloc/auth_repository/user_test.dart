import 'package:flutter_test/flutter_test.dart';
import 'package:knote/data/app_bloc/auth_repository/user.dart';

const _fullUser = User(
  id: 'uid-1',
  email: 'alice@example.com',
  name: 'Alice',
  photoMail: 'https://example.com/photo.png',
  phoneNumber: '+33600000000',
  isAnonymous: false,
  isCheckMail: true,
  verifiedAccount: true,
  isDataCloud: true,
  isBlocked: false,
);

void main() {
  group('User.empty', () {
    test('has empty id and email', () {
      expect(User.empty.id, '');
      expect(User.empty.email, '');
    });

    test('isEmpty returns true', () {
      expect(User.empty.isEmpty, isTrue);
    });

    test('isNotEmpty returns false', () {
      expect(User.empty.isNotEmpty, isFalse);
    });
  });

  group('User - isEmpty / isNotEmpty', () {
    test('non-empty user: isEmpty is false', () {
      expect(_fullUser.isEmpty, isFalse);
    });

    test('non-empty user: isNotEmpty is true', () {
      expect(_fullUser.isNotEmpty, isTrue);
    });
  });

  group('User - equality (Equatable)', () {
    test('two users with same id and email are equal', () {
      const u1 = User(id: 'uid-1', email: 'a@a.com', name: 'A', photoMail: null);
      const u2 = User(id: 'uid-1', email: 'a@a.com', name: 'A', photoMail: null);
      expect(u1, equals(u2));
    });

    test('users with different ids are not equal', () {
      const u1 = User(id: 'uid-1', email: 'a@a.com', name: null, photoMail: null);
      const u2 = User(id: 'uid-2', email: 'a@a.com', name: null, photoMail: null);
      expect(u1, isNot(equals(u2)));
    });

    test('users with different emails are not equal', () {
      const u1 = User(id: 'uid-1', email: 'a@a.com', name: null, photoMail: null);
      const u2 = User(id: 'uid-1', email: 'b@b.com', name: null, photoMail: null);
      expect(u1, isNot(equals(u2)));
    });

    test('props only includes email, id, name, photoMail', () {
      const u = User(
        id: 'uid-1',
        email: 'a@a.com',
        name: 'A',
        photoMail: 'url',
        isBlocked: true,
        verifiedAccount: true,
      );
      expect(u.props, ['a@a.com', 'uid-1', 'A', 'url']);
    });
  });

  group('User.copyWith', () {
    test('returns identical user when no fields are overridden', () {
      final copy = _fullUser.copyWith();
      expect(copy, equals(_fullUser));
    });

    test('overrides email', () {
      final copy = _fullUser.copyWith(email: 'bob@example.com');
      expect(copy.email, 'bob@example.com');
      expect(copy.id, _fullUser.id);
    });

    test('overrides id', () {
      final copy = _fullUser.copyWith(id: 'uid-99');
      expect(copy.id, 'uid-99');
    });

    test('overrides name', () {
      final copy = _fullUser.copyWith(name: 'Bob');
      expect(copy.name, 'Bob');
    });

    test('overrides isBlocked', () {
      final copy = _fullUser.copyWith(isBlocked: true);
      expect(copy.isBlocked, isTrue);
    });

    test('overrides isDataCloud', () {
      final copy = _fullUser.copyWith(isDataCloud: false);
      expect(copy.isDataCloud, isFalse);
    });

    test('overrides verifiedAccount', () {
      final copy = _fullUser.copyWith(verifiedAccount: false);
      expect(copy.verifiedAccount, isFalse);
    });

    test('does not mutate original', () {
      _fullUser.copyWith(name: 'X', isBlocked: true);
      expect(_fullUser.name, 'Alice');
      expect(_fullUser.isBlocked, isFalse);
    });
  });

  group('User.asMap', () {
    test('contains all expected keys', () {
      final map = _fullUser.asMap();
      expect(map.keys, containsAll([
        'id', 'name', 'email', 'photo_profile', 'photo_mail',
        'phone_number', 'last_login', 'creation_time', 'last_connection',
        'is_check_mail', 'verified_account', 'location', 'is_data_cloud',
        'isBlocked',
      ]));
    });

    test('maps id and email correctly', () {
      final map = _fullUser.asMap();
      expect(map['id'], 'uid-1');
      expect(map['email'], 'alice@example.com');
    });

    test('maps name correctly', () {
      expect(_fullUser.asMap()['name'], 'Alice');
    });

    test('maps phone_number correctly', () {
      expect(_fullUser.asMap()['phone_number'], '+33600000000');
    });

    test('maps boolean flags correctly', () {
      final map = _fullUser.asMap();
      expect(map['verified_account'], isTrue);
      expect(map['is_data_cloud'], isTrue);
      expect(map['isBlocked'], isFalse);
      expect(map['is_check_mail'], isTrue);
    });

    test('User.empty asMap has empty id and email', () {
      final map = User.empty.asMap();
      expect(map['id'], '');
      expect(map['email'], '');
    });
  });
}
