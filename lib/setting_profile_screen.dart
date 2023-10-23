import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knote/src/pages/about_page.dart';
import 'package:knote/src/pages/screens.dart';
import 'package:knote/src/pages/trash_can.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingProfileScreen extends StatefulWidget {
  static const routeName = "user";
  final Function()? onMenuTap;

  const SettingProfileScreen({
    super.key,
    this.onMenuTap,
  });

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  bool notification = false;
  bool mail = false;

  @override
  Widget build(BuildContext context) {
    //BlocProvider.of<NavigationController>(context).setState(NavigationScreen.setting);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 32.0, bottom: 64.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 910),
            child: Column(
              children: [
                SizedBox(
                  height: 560,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0).copyWith(top: 50.0),
                        child: Card(
                          color: Theme.of(context).cardColor.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: const Text("Modifier le profile"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: const Icon(Icons.password),
                                  title: const Text("Modifier le mot de passe"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete_outline),
                                  title: const Text("Trash"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () =>  GoRouter.of(context)
                                      .pushNamed(NoteTrash.routeName),
                                ),

                                ListTile(
                                  leading: const Icon(Icons.archive_outlined),
                                  title: const Text("Archived notes"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () =>  GoRouter.of(context)
                                      .pushNamed(ArchivedScreen.routeName),
                                ),

                                ListTile(
                                  leading: const Icon(Icons.calendar_today_outlined),
                                  title: const Text("Calendar"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {},
                                ),

                                ListTile(
                                  leading: const Icon(Icons.output),
                                  title: const Text("Se deconnecter"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: (){},
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Image.asset(
                                  "assets/avatar/avatar_image1.jpg" ,
                                  height: 100,
                                ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            const SelectableText("Unknown Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                )),
                            const SelectableText(
                              "guest-user@exploress.com",
                              style: TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).cardColor.withOpacity(0.7),
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.dark_mode),
                          title: const Text("Dark Mode"),
                          trailing: Switch(
                            value: true,
                            onChanged: (bool value) {},
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text("Notification"),
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
                          leading: const Icon(Icons.mail_rounded),
                          title: const Text("Avis via mail"),
                          subtitle: const Text("M'envoyer des avis par mail"),
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
                          leading: const Icon(Icons.more_horiz),
                          title: const Text("More"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).cardColor.withOpacity(0.7),
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          //leading: const Icon(Icons.dark_mode),
                          title: const Text("About Us"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                        ListTile(
                          //leading: const Icon(Icons.dark_mode),
                          title: const Text("About this app"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            GoRouter.of(context).pushNamed(AboutPage.routeName);
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
                                  leading: const Icon(Icons.launch_sharp),
                                  title: const Text("Last Update"),
                                  subtitle: Text(
                                      "version beta : ${snapshot.data?.version} "),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {},
                                );
                              }

                              return Container();
                            }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
