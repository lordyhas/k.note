import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:knote/data/values.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../backgound_ui.dart';

class AboutPage extends StatefulWidget{
  static const routeName = "about";
  const AboutPage({Key? key, }) : super(key: key);


  static Route route({isSystemSet = false}) {
    return MaterialPageRoute<void>(builder: (_) => const AboutPage());
  }


  @override
  State<StatefulWidget> createState() {
    //throw UnimplementedError();
    return _AboutState();
  }
}

class _AboutState extends State<AboutPage>{
  late final text;
  var timeUpdate = DateTime.now();
  String appVersion = "0.2.0";

  Color get background2 => Theme.of(context).cardColor.withOpacity(.7);
  //Colors.grey[200]!.withOpacity(0.8);

  @override
  initState() {
    super.initState();
    initPlatformPackageInfo();
    text = BlocProvider.of<LanguageBloc>(context).state.strings;
  }


  initPlatformPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    //appVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
  }

  Future<bool> _willPop(){

    return Future.value(true);
  }


  @override
  Widget build(BuildContext context) {
    //text = widget.text;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: contentAbout(),

    );
  }


  Widget contentAbout(){
    var primaryTextStyle20 = Theme.of(context)
        .textTheme.bodyText2!
        .copyWith(fontSize: 17,);
    var textSettingsStyle = TextStyle(color: Colors.blue[600]);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 5.0, right: 5.0,),
      children: <Widget>[

        const SizedBox(height: 42.0,),
        Card(
          color: background2,
          child: Column(
            children: <Widget>[
              Column(children: [
                Container(
                  margin: const EdgeInsets.only(top: 32.0),
                  height: 150,
                  child: Image.asset(imageLogoApp),
                ),
                Text(
                  "K.NOTE",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24),
                ),
                const Text("@lordyhas7",),

              ],),
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
                title: Text("Version", style: primaryTextStyle20,),
                subtitle: Text("$appVersion (non-stable)",),

              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: Text(text['about_update'], style: primaryTextStyle20,),
                subtitle: Text("${DateTime(2021,5,4,21,0)}",
                ),
                //${timeUpdate.subtract(Duration(days: 35, hours: 1))}

              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text("Checking for update",style: primaryTextStyle20,),
              ),

              ListTile(
                leading: const Icon(Icons.turned_in_not),
                title: Text(text['about_licence'],style: primaryTextStyle20,),
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
                  title: Text(text['about_author'],style: textSettingsStyle,),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.user),
                title: Text("Hassan Kajila",style: primaryTextStyle20,),
                subtitle: const Text("dev.haspro@gmail.com",),

              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.googlePlay),
                title: Text("Play Store",style: primaryTextStyle20,),
              ),

              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text("Our team",style: primaryTextStyle20,),
              ),
            ],
          ),
        ),
        Card(
          color: background2,
          child: Column(
            children: <Widget>[

              ListTile(
                title: Text(text['about_company'],style: textSettingsStyle,),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: Text("KDynamic Inc.",style: primaryTextStyle20,),
                subtitle: const Text("Mobile App Developers ",),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(text['about_add'],style: primaryTextStyle20,),
                subtitle: const Text("None ",),
              ),

            ],
          ),
        ),
      ],
    );
  }
}