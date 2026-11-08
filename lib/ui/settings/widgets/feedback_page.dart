import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:knote/config/assets.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/utils/save_in_background.dart';

/// Lets the user send a message to the K.Note team, stored in the
/// `feedback` collection (see [FirestoreService.sendFeedback]).
class FeedbackPage extends StatefulWidget {
  static const routeName = "feedback";

  /// Longest message accepted, as in `firestore.rules`.
  static const maxLength = 5000;

  const FeedbackPage({super.key, this.firebaseManager});

  /// Tests pass one backed by a fake Firestore.
  final FirestoreService? firebaseManager;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final message = _message.text.trim();
    if (message.isEmpty) return;
    final service = widget.firebaseManager ??
        FirestoreService.user(context.read<AuthenticationBloc>().state.user);
    String? version;
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      version = null;
    }
    // Sent in the background like every other write: Firestore only
    // completes it once the server has it, which waits while offline.
    saveInBackground(
      () => service.sendFeedback(
        message: message,
        appVersion: version,
        platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
        locale: l10n.localeName,
      ),
      failureMessage: l10n.feedbackFailed,
    );
    if (!mounted) return;
    _message.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.feedbackSent)));
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(l10n.sendFeedback),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Image.asset(AppAssets.feedbackImage),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feedbackTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.feedbackBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('__feedback_message__'),
                    controller: _message,
                    minLines: 4,
                    maxLines: 10,
                    maxLength: FeedbackPage.maxLength,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    cursorColor: colors.link,
                    decoration: InputDecoration(
                      hintText: l10n.feedbackHint,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const Key('__feedback_send__'),
                    onPressed: _message.text.trim().isEmpty ? null : _send,
                    icon: const Icon(Icons.send),
                    label: Text(l10n.send),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
