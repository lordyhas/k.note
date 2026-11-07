import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:knote/data/repositories/auth_repository.dart';
import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/auth/widgets/logout_dialog.dart';
import 'package:knote/ui/auth/widgets/password_reset_dialog.dart';
import 'package:knote/ui/calendar/widgets/calendar_page.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';
import 'package:knote/ui/notes/widgets/archived_notes_page.dart';
import 'package:knote/ui/notes/widgets/trash_page.dart';
import 'package:knote/ui/settings/widgets/about_page.dart';
import 'package:knote/ui/settings/widgets/delete_account_dialog.dart';
import 'package:knote/ui/settings/widgets/feedback_page.dart';
import 'package:knote/ui/shell/side_navigation_scope.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = "user";
  final Function()? onMenuTap;

  /// Used to delete the user's data with their account; tests pass one
  /// backed by a fake Firestore.
  final FirestoreService? firebaseManager;

  const SettingsPage({
    super.key,
    this.onMenuTap,
    this.firebaseManager,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _deleteAccount() {
    final user = context.read<AuthenticationBloc>().state.user;
    showDeleteAccountDialog(
      context,
      firestoreService: widget.firebaseManager ?? FirestoreService.user(user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iconColor = AppColors.of(context).text;
    final mutedText = AppColors.of(context).text.withValues(alpha: 0.6);
    // The web side drawer already has Bin, Archived notes and Calendar.
    final sideNavigation = SideNavigationScope.of(context);
    final signedInWithPassword =
        context.read<AuthRepository>().signedInWithPassword;

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
            onPressed: () => confirmLogout(context),
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
                          color: Theme.of(context)
                              .cardColor
                              .withValues(alpha: 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(top: 108.0),
                            child: Column(
                              children: [
                                if (signedInWithPassword)
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
                                    onTap: () => showPasswordResetDialog(
                                      context,
                                      email: context
                                          .read<AuthenticationBloc>()
                                          .state
                                          .user
                                          .email,
                                    ),
                                  ),
                                if (!sideNavigation) ...[
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
                                    onTap: () => GoRouter.of(context)
                                        .goNamed(CalendarPage.routeName),
                                  ),
                                ],
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
                                  onTap: () => confirmLogout(context),
                                ),
                                ListTile(
                                  key: const Key('__settings_deleteAccount__'),
                                  leading: Icon(
                                    Icons.person_remove_outlined,
                                    color: AppColors.of(context).danger,
                                  ),
                                  title: Text(
                                    l10n.deleteAccount,
                                    style: TextStyle(
                                        color: AppColors.of(context).danger),
                                  ),
                                  onTap: _deleteAccount,
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
                            Icons.feedback_outlined,
                            color: iconColor,
                          ),
                          title: Text(l10n.sendFeedback),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: iconColor,
                          ),
                          onTap: () => GoRouter.of(context)
                              .goNamed(FeedbackPage.routeName),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: iconColor,
                          ),
                          title: Text(l10n.aboutApp),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: iconColor,
                          ),
                          onTap: () {
                            GoRouter.of(context)
                                .goNamed(AboutPage.settingsRouteName);
                          },
                        ),
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.launch_sharp,
                                    color: iconColor,
                                  ),
                                  title: Text(l10n.appVersion(
                                      snapshot.data?.version ?? '')),
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
