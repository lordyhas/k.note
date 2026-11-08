import 'package:flutter/material.dart';

import 'package:knote/domain/models/user.dart';
import 'package:knote/ui/core/themes/app_colors.dart';

/// The user's photo, or their initials when they have none or it cannot be
/// downloaded (e.g. offline).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 100});

  final User user;
  final double size;

  /// Up to two letters from the name ("Hassan Kajila" -> "HK"), or the
  /// first letter of the email; "?" when there is neither.
  static String initialsOf(User user) {
    final words = (user.name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isNotEmpty) {
      final first = words.first.characters.first;
      final last = words.length > 1 ? words.last.characters.first : '';
      return (first + last).toUpperCase();
    }
    final email = user.email.trim();
    return email.isEmpty ? '?' : email.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final initials = ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
        ),
        child: Text(
          initialsOf(user),
          style: TextStyle(
            color: colors.text,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    final url = user.photoMail;
    if (url == null || url.isEmpty || url == 'null') return initials;
    return ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => initials,
      ),
    );
  }
}
