import 'package:flutter/material.dart';

import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/core/widgets/app_icons.dart';

/// One change of the current release, as listed in "What's new".
typedef WhatsNewEntry = ({AppIcons icon, String title, String body});

/// The changes of the current release. Update them (and their text in the
/// `.arb` files) with each release that users should hear about.
List<WhatsNewEntry> whatsNewEntries(AppLocalizations l10n) => [
      (
        icon: AppIcons.folder,
        title: l10n.whatsNewFoldersTitle,
        body: l10n.whatsNewFoldersBody,
      ),
      (
        icon: AppIcons.edit,
        title: l10n.whatsNewEditorTitle,
        body: l10n.whatsNewEditorBody,
      ),
      (
        icon: AppIcons.grid,
        title: l10n.whatsNewIconsTitle,
        body: l10n.whatsNewIconsBody,
      ),
      (
        icon: AppIcons.user,
        title: l10n.whatsNewSettingsTitle,
        body: l10n.whatsNewSettingsBody,
      ),
    ];

/// Shows what changed in this release. The app shows it once after each
/// update (see `WhatsNewService`), and Settings > What's new shows it again.
Future<void> showWhatsNew(BuildContext context, {String? version}) {
  return showDialog<void>(
    context: context,
    builder: (context) => WhatsNewDialog(version: version),
  );
}

class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key, this.version});

  /// Shown under the title when known.
  final String? version;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    final version = this.version;
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
              for (final entry in whatsNewEntries(l10n))
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
