import 'package:flutter_test/flutter_test.dart';

import 'package:knote/ui/auth/bloc/login_models.dart';

void main() {
  group('Email', () {
    test('pure email is empty and pure', () {
      const email = Email.pure();
      expect(email.value, '');
      expect(email.isPure, isTrue);
    });

    test('valid email returns no error', () {
      const email = Email.dirty('test@example.com');
      expect(email.isValid, isTrue);
      expect(email.error, isNull);
    });

    test('email with subdomain is valid', () {
      const email = Email.dirty('user@mail.example.com');
      expect(email.isValid, isTrue);
    });

    test('email with special chars in local part is valid', () {
      const email = Email.dirty('user.name+tag@example.com');
      expect(email.isValid, isTrue);
    });

    test('empty string is invalid', () {
      const email = Email.dirty('');
      expect(email.isValid, isFalse);
      expect(email.error, EmailValidationError.invalid);
    });

    test('string without @ is invalid', () {
      const email = Email.dirty('invalid');
      expect(email.isValid, isFalse);
      expect(email.error, EmailValidationError.invalid);
    });

    test('string without domain is invalid', () {
      const email = Email.dirty('test@');
      expect(email.isValid, isFalse);
      expect(email.error, EmailValidationError.invalid);
    });
  });

  group('Password', () {
    test('pure password is empty and pure', () {
      const password = Password.pure();
      expect(password.value, '');
      expect(password.isPure, isTrue);
    });

    test('valid password with letters and digits (8+ chars) returns no error',
        () {
      const password = Password.dirty('password1');
      expect(password.isValid, isTrue);
      expect(password.error, isNull);
    });

    test('password with only letters is invalid', () {
      const password = Password.dirty('abcdefgh');
      expect(password.isValid, isFalse);
      expect(password.error, PasswordValidationError.invalid);
    });

    test('password with only digits is invalid', () {
      const password = Password.dirty('12345678');
      expect(password.isValid, isFalse);
      expect(password.error, PasswordValidationError.invalid);
    });

    test('password shorter than 8 chars is invalid', () {
      const password = Password.dirty('abc1');
      expect(password.isValid, isFalse);
      expect(password.error, PasswordValidationError.invalid);
    });

    test('empty password is invalid', () {
      const password = Password.dirty('');
      expect(password.isValid, isFalse);
    });

    test('symbols, accents and spaces are allowed', () {
      for (final value in [
        'Mot2passe!',
        'p@ssw0rd#2026',
        'élève 2026',
        'Ab1-_.,;:'
      ]) {
        expect(Password.dirty(value).isValid, isTrue, reason: value);
      }
    });
  });

  group('LoginPassword', () {
    test('any non-empty password is accepted', () {
      for (final value in ['abc', 'motdepasse', '123456', 'p@ss!', ' ']) {
        expect(LoginPassword.dirty(value).isValid, isTrue, reason: value);
      }
    });

    test('an empty password is not', () {
      expect(const LoginPassword.dirty('').isValid, isFalse);
      expect(const LoginPassword.pure().isValid, isFalse);
    });
  });

  group('ConfirmedPassword', () {
    test('pure confirmed password is pure', () {
      const cp = ConfirmedPassword.pure();
      expect(cp.isPure, isTrue);
    });

    test('matching passwords return no error', () {
      const cp = ConfirmedPassword.dirty(
        password: 'password1',
        value: 'password1',
      );
      expect(cp.isValid, isTrue);
      expect(cp.error, isNull);
    });

    test('non-matching passwords return error', () {
      const cp = ConfirmedPassword.dirty(
        password: 'password1',
        value: 'different',
      );
      expect(cp.isValid, isFalse);
      expect(cp.error, ConfirmedPasswordValidationError.invalid);
    });

    test('empty confirmation with non-empty password returns error', () {
      const cp = ConfirmedPassword.dirty(
        password: 'password1',
        value: '',
      );
      expect(cp.isValid, isFalse);
    });
  });
}
