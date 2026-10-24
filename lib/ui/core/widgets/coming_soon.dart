import 'package:flutter/material.dart';

import 'package:knote/ui/core/localization/l10n.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.emoji_emotions_outlined, size: 100),
          Text(context.l10n.comingSoon),
        ],
      ),
    );
  }
}
