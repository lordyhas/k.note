import 'package:flutter/material.dart';

import 'package:knote/config/whats_new_releases.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/app_icons.dart';

/// One change of a release, as listed in "What's new".
typedef WhatsNewEntry = ({AppIcons icon, String title, String body});

/// The icon and texts of the change [key] of [whatsNewReleases], or null for
/// a key this function doesn't know (a test checks there is none).
WhatsNewEntry? whatsNewEntry(AppLocalizations l10n, String key) {
  return switch (key) {
    'whatsNewFolders' => (
        icon: AppIcons.folder,
        title: l10n.whatsNewFoldersTitle,
        body: l10n.whatsNewFoldersBody,
      ),
    'whatsNewEditor' => (
        icon: AppIcons.edit,
        title: l10n.whatsNewEditorTitle,
        body: l10n.whatsNewEditorBody,
      ),
    'whatsNewIcons' => (
        icon: AppIcons.grid,
        title: l10n.whatsNewIconsTitle,
        body: l10n.whatsNewIconsBody,
      ),
    'whatsNewSettings' => (
        icon: AppIcons.user,
        title: l10n.whatsNewSettingsTitle,
        body: l10n.whatsNewSettingsBody,
      ),
    _ => null,
  };
}

/// Shows the changes [keys] (see [whatsNewReleases]); without [keys], those
/// of the newest release up to [version]. The app shows it after an update
/// (see `WhatsNewService`), and Settings > What's new shows it again.
Future<void> showWhatsNew(BuildContext context,
    {String? version, List<String>? keys}) {
  return showDialog<void>(
    context: context,
    builder: (context) => WhatsNewDialog(version: version, keys: keys),
  );
}

class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key, this.version, this.keys});

  /// Shown under the title when known.
  final String? version;

  /// The changes to list; by default those of the newest release up to
  /// [version] (or the newest release when it is unknown).
  final List<String>? keys;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final version = this.version;
    final keys = this.keys ??
        whatsNewKeys(current: version ?? whatsNewReleases.first.version);
    return AlertDialog(
      icon: AppIcon(AppIcons.gift, size: 32, color: colors.accent),
      title: Column(
        children: [
          Text(l10n.whatsNewTitle),
          if (version != null && version.isNotEmpty)
            Text(
              l10n.whatsNewVersion(version),
              style: TextStyle(fontSize: 14, color: colors.textMuted),
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry
                  in keys.map((key) => whatsNewEntry(l10n, key)).nonNulls)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIcon(entry.icon, size: 24, color: colors.accent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(entry.body,
                                style: TextStyle(color: colors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          key: const Key('__whatsNew_continue__'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.whatsNewContinue),
        ),
      ],
    );
  }
}
