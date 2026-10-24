import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:knote/config/assets.dart';
import 'package:knote/ui/core/localization/l10n.dart';
import 'package:knote/ui/core/themes/app_colors.dart';

class AboutPage extends StatefulWidget {
  static const routeName = "about";

  /// Name of the copy of this route nested under the settings screen; route
  /// names must be unique in go_router.
  static const settingsRouteName = "settings-about";
  const AboutPage({super.key});

  static Route route({bool isSystemSet = false}) {
    return MaterialPageRoute<void>(builder: (_) => const AboutPage());
  }

  @override
  State<StatefulWidget> createState() {
    //throw UnimplementedError();
    return _AboutState();
  }
}

class _AboutState extends State<AboutPage> {
  var timeUpdate = DateTime.now();
  String appVersion = "0.2.0";

  Color get background2 => Theme.of(context).cardColor.withValues(alpha: .7);
  //Colors.grey[200]!.withValues(alpha: 0.8);

  @override
  initState() {
    super.initState();
    initPlatformPackageInfo();
  }

  Future<void> initPlatformPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    // //appVersion = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;
  }

  // Future<bool> _willPop() {
  //   return Future.value(true);
  // }

  @override
  Widget build(BuildContext context) {
    //text = widget.text;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: contentAbout(),
    );
  }

  Widget contentAbout() {
    final l10n = context.l10n;
    var primaryTextStyle20 = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 17,
        );
    var textSettingsStyle = TextStyle(color: AppColors.of(context).link);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 5.0,
        right: 5.0,
      ),
      children: <Widget>[
        const SizedBox(
          height: 42.0,
        ),
        Card(
          color: background2,
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 32.0),
                    height: 150,
                    child: Image.asset(imageLogoApp),
                  ),
                  Text(
                    "K.NOTE",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24),
                  ),
                  const Text(
                    "@lordyhas7",
                  ),
                ],
              ),
              /*ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage("assets/img/exploress_icon.png"),
                ),
                title: Text(
                  "Exploress",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),),
                subtitle: Text("@lordyhas7",style:  TextStyle(/*color: textWhiteColor54*/),),

              ),*/
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(
                  l10n.version,
                  style: primaryTextStyle20,
                ),
                subtitle: Text(l10n.versionUnstable(appVersion)),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: Text(
                  l10n.lastUpdate,
                  style: primaryTextStyle20,
                ),
                subtitle: Text(
                  MaterialLocalizations.of(context)
                      .formatFullDate(DateTime(2021, 5, 4)),
                ),
                //${timeUpdate.subtract(Duration(days: 35, hours: 1))}
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(
                  l10n.checkingForUpdates,
                  style: primaryTextStyle20,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.turned_in_not),
                title: Text(
                  l10n.licenses,
                  style: primaryTextStyle20,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationIcon: Image.asset(imageLogoApp),
                  applicationName: "K.NOTE",
                  applicationVersion: appVersion,
                ),
              ),
            ],
          ),
        ),
        Card(
          color: background2,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  l10n.author,
                  style: textSettingsStyle,
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.user),
                title: Text(
                  "Hassan Kajila",
                  style: primaryTextStyle20,
                ),
                subtitle: const Text(
                  "dev.haspro@gmail.com",
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.googlePlay),
                title: Text(
                  "Play Store",
                  style: primaryTextStyle20,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(
                  l10n.ourTeam,
                  style: primaryTextStyle20,
                ),
              ),
            ],
          ),
        ),
        Card(
          color: background2,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  l10n.company,
                  style: textSettingsStyle,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: Text(
                  "KDynamic Inc.",
                  style: primaryTextStyle20,
                ),
                subtitle: Text(l10n.companyTagline),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  l10n.address,
                  style: primaryTextStyle20,
                ),
                subtitle: Text(l10n.none),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
