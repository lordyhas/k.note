import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/widgets/login_page.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/about_page.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = "user";
  final Function()? onMenuTap;

  const SettingsPage({
    super.key,
    this.onMenuTap,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notification = false;
  bool mail = false;

  void logoutDialogView() {
    final l10n = context.l10n;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(context).danger),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context).logout();
                    //GoRouter.of(context).pop();
                    GoRouter.of(context).goNamed(LoginPage.routeName);
                  },
                  icon: const Icon(CupertinoIcons.square_arrow_right),
                  label: Text(l10n.logOut),
                ),
                TextButton(
                  onPressed: GoRouter.of(context).pop,
                  child: Text(l10n.cancel),
                )
              ],
              title: Text(l10n.logOut),
              content: Text(l10n.logOutQuestion),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iconColor = AppColors.of(context).text;
    final mutedText = AppColors.of(context).text.withValues(alpha: 0.6);

    //BlocProvider.of<NavigationController>(context).setState(NavigationScreen.setting);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            tooltip: l10n.logOut,
            onPressed: () => logoutDialogView(),
            icon: const Icon(CupertinoIcons.square_arrow_right),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 32.0, bottom: 42.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 910),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                SizedBox(
                  //height: 560,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(top: 50.0),
                        child: Card(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(top: 108.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.person,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.editProfile),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.password,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.changePassword),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.delete_outline,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.binTitle),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () => GoRouter.of(context)
                                      .goNamed(TrashPage.routeName),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.archive_outlined,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.archiveTitle),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () => GoRouter.of(context)
                                      .goNamed(ArchivedNotesPage.routeName),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.calendar_today_outlined,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.calendar),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.output,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.logOut),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () => logoutDialogView(),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            BlocBuilder<AuthenticationBloc, AuthState>(
                                builder: (_, state) {
                              switch (state.status) {
                                case AuthenticationStatus.authenticated:
                                  return Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: _ProfilePhoto(
                                            url: state.user.photoMail),
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                      SelectableText("${state.user.name}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          )),
                                      SelectableText(
                                        state.user.email,
                                        style: TextStyle(color: mutedText),
                                      ),
                                    ],
                                  );
                                case AuthenticationStatus.unauthenticated:
                                  return Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Image.asset(
                                          "assets/avatar/avatar_image1.jpg",
                                          height: 100,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                      SelectableText(l10n.unknownName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          )),
                                      SelectableText(
                                        "guest-user@k8note.com",
                                        style: TextStyle(color: mutedText),
                                      ),
                                    ],
                                  );
                              }
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.dark_mode,
                            color: iconColor,
                          ),
                          title: Text(l10n.darkMode),
                          trailing: Switch(
                            value: true,
                            onChanged: (bool value) {},
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: iconColor,
                          ),
                          title: Text(l10n.notifications),
                          trailing: Switch(
                            value: notification,
                            onChanged: (bool value) {
                              setState(() {
                                notification = value;
                              });
                            },
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.mail_rounded,
                            color: iconColor,
                          ),
                          title: Text(l10n.emailUpdates),
                          subtitle: Text(l10n.emailUpdatesSubtitle),
                          trailing: Switch(
                            value: mail,
                            onChanged: (bool value) {
                              setState(() {
                                mail = value;
                              });
                            },
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.more_horiz,
                            color: iconColor,
                          ),
                          title: Text(l10n.more),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: iconColor,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          //leading: const Icon(Icons.dark_mode),
                          title: Text(l10n.aboutUs),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: iconColor,
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          //leading: const Icon(Icons.dark_mode),
                          title: Text(l10n.aboutApp),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: iconColor,
                          ),
                          onTap: () {
                            GoRouter.of(context).goNamed(AboutPage.settingsRouteName);
                          },
                        ),

                        /*ListTile(
                          //leading: const Icon(Icons.dark_mode),
                          title: const Text("Help"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),*/
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.launch_sharp,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.lastUpdate),
                                  subtitle: Text(l10n.betaVersion(
                                      snapshot.data?.version ?? '')),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: iconColor,
                                  ),
                                  onTap: () {},
                                );
                              }

                              return Container();
                            }),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The user's Google profile photo, or a placeholder when the account has no
/// photo or it cannot be downloaded (e.g. offline).
class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.url});

  final String? url;

  static const double _size = 100;

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(Icons.account_circle, size: _size);
    final url = this.url;
    if (url == null || url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      height: _size,
      width: _size,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
