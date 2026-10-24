import 'package:flutter/material.dart';

import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';

class InviteFriendPage extends StatefulWidget {
  static const routeName = "invite-friend";
  const InviteFriendPage({super.key});

  @override
  State<InviteFriendPage> createState() => _InviteFriendPageState();
}

class _InviteFriendPageState extends State<InviteFriendPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        //backgroundColor: StyleAppTheme.nearlyWhite,
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top, left: 16, right: 16),
              child: Image.asset('assets/images/inviteImage.png'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.inviteTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
              child: Text(
                l10n.inviteBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.link,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: colors.textMuted.withValues(alpha: 0.6),
                            offset: const Offset(4, 4),
                            blurRadius: 2.0),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          /*Share.share(
                              "Hey I'm using K.Note for writing and store my "
                                  "notes on my mobile phone, You can get your "
                                  "own customize note application. "
                                  "\nJust send your command to this mail : "
                                  "dev.haspro@gmail.com",
                              subject: 'Sharing my experience with K.Note'
                          );*/
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.share,
                                color: colors.text,
                                size: 22,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  l10n.share,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
