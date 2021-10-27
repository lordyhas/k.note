

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:utils_component/utils_component.dart';
import 'package:knote/data/values.dart';
import 'package:flutter/material.dart';
import '../../../res.dart';

enum  DrawerIndex {
  home,
  feedBack,
  help,
  rate,
  about,
  invite,
  calendar,
  noteTrash,
  archived,
  offline,
  //Setting,

}

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    required this.screenIndex,
    required this.iconAnimationController,
    required this.callBackIndex,
    Key? key,

  }) : super(key: key);

  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList> drawerList = DrawerList.drawerList;
  @override
  void initState() {
    //setDrawerListArray();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade800, //StyleAppTheme.notWhite.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          BlocBuilder<AuthenticationBloc,AuthenticationState>(
            builder: (context, state) {
              return   Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AnimatedBuilder(
                          animation: widget.iconAnimationController,
                          builder: (context, child) {
                            return ScaleTransition(
                              scale: AlwaysStoppedAnimation<double>(1.0 - (widget.iconAnimationController.value) * 0.2),
                              child: RotationTransition(
                                turns: AlwaysStoppedAnimation<double>(Tween<double>(begin: 0.0, end: 24.0)
                                        .animate(CurvedAnimation(parent: widget.iconAnimationController, curve: Curves.fastOutSlowIn))
                                        .value /
                                    360),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(color: StyleAppTheme.grey.withOpacity(0.3), offset: const Offset(2.0, 4.0), blurRadius: 8),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                                    child: //(true) ?
                                    Image.asset(Res.IMG)
                                        //: Image.asset(Res.logo_2),//Image.network(state.user.photoMail!),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Chip(
                            avatar: ClipRRect(
                                borderRadius: const BorderRadius
                                    .all(Radius.circular(100.0)),
                                child: Image.asset(Res.logo_2)
                                //Image.network(state.user.photoMail.toString())
                            ) ,
                            label: Text(
                              state.user.name ?? 'K.Note User',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                //color: StyleAppTheme.grey,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              );
            }
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList[index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) => Column(
                children: <Widget>[

                   ListTile(
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: StyleAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: StyleAppTheme.darkText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    trailing: const Icon(
                      Icons.power_settings_new,
                      color: Colors.red,
                    ),
                    onTap:  () {
                      /*if(state.status == AuthenticationStatus.authenticated) {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(AuthenticationLogoutRequested());
                      }*/
                      showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              "Disconnect K.NOTE account",
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            content: RichText(
                              text:  TextSpan(
                                  text: "Do you want to sign out from this phone ?",
                                  children: [
                                    TextSpan(text: "\n\nThis action will disconnect "
                                        "this device from your mail account, all new"
                                        "backup not upload in cloud will be lost",
                                        style: TextStyle(
                                          color: Colors.red.shade400,
                                          fontSize: 12,
                                    )),
                                  ]
                              ),

                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("Cancel", style: TextStyle(color: Colors.red.shade900),),
                              ),

                              TextButton(
                                onPressed: () => _checkForBackup(),
                                child: const Text("Check for backup",  style: TextStyle(),),
                              ),
                              TextButton(
                                onPressed: () {
                                  if(state.status == AuthenticationStatus.authenticated) {
                                    BlocProvider.of<AuthenticationBloc>(context)
                                        .add(AuthenticationLogoutRequested());
                                  }
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Yes, I want",  style: TextStyle(color: Colors.green),),
                              ),
                            ],
                          ));


                    }
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
          ),


        ],
      ),
    );
  }

  void _checkForBackup(){
    Log.i('++++++++++ Backup SnackBar ++++++++++');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar( const SnackBar(
          backgroundColor: Colors.white,
          dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
          content: Text('All backup uploaded | CHECKED :) ',
          style: TextStyle(color: Colors.black),)
      )
      );

  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationToScreen(listData.index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 6.0,
                    height: 46.0,
                    // decoration: BoxDecoration(
                    //   color: widget.screenIndex == listData.index
                    //       ? Colors.blue
                    //       : Colors.transparent,
                    //   borderRadius: new BorderRadius.only(
                    //     topLeft: Radius.circular(0),
                    //     topRight: Radius.circular(16),
                    //     bottomLeft: Radius.circular(0),
                    //     bottomRight: Radius.circular(16),
                    //   ),
                    // ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index
                                  ? Theme.of(context).primaryColor : StyleAppTheme.nearlyBlack),
                        )
                      : (widget.screenIndex == listData.index)
                  ?Icon(listData.iconSelected.icon, color: Theme.of(context).primaryColor)
                  :Icon(listData.icon.icon, color : StyleAppTheme.nearlyBlack),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? Theme.of(context).primaryColor : StyleAppTheme.nearlyBlack,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: ( context,  child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context)
                                .size.width * 0.75) * (1.0 - widget
                                .iconAnimationController
                                .value - 1.0), 0.0, 0.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.15),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationToScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}



class DrawerList {
  DrawerList({
    required this.index,
    this.isAssetsImage = false,
    this.labelName = '',
    Icon? icon,
    Icon? iconSelected,
    this.imageName = '',
  }):   icon = icon ?? const Icon(null),
        iconSelected = iconSelected ?? icon ?? const Icon(null);

  String labelName;
  Icon icon;
  Icon iconSelected;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;

  static List<DrawerList> drawerList = <DrawerList>[
    DrawerList(
        index: DrawerIndex.home,
        labelName: 'Recent notes',
        iconSelected: const Icon(Icons.file_copy_outlined),
        icon: const Icon(Icons.file_copy,)
    ),
    DrawerList(
      index: DrawerIndex.offline,
      labelName: 'Offline notes',
      icon: const Icon(Icons.offline_pin_outlined),
      iconSelected: const Icon(Icons.offline_pin_rounded),
    ),
    DrawerList(
      index: DrawerIndex.archived,
      labelName: 'Archived notes',
      icon: const Icon(Icons.archive_outlined),
      iconSelected: const Icon(Icons.archive),
    ),
    DrawerList(
      index: DrawerIndex.calendar,
      labelName: 'Calendar',
      icon: const Icon(Icons.calendar_today_outlined),
      iconSelected: const Icon(Icons.calendar_today),
    ),
    DrawerList(
      index: DrawerIndex.noteTrash,
      labelName: 'Trash',
      icon: const Icon(Icons.delete_outline,),
      iconSelected: const Icon(Icons.delete,),
    ),
    DrawerList(
      index: DrawerIndex.feedBack,
      labelName: 'FeedBack',
      icon: const Icon(Icons.help_outline),
      iconSelected: const Icon(Icons.help),
    ),
    DrawerList(
      index: DrawerIndex.invite,
      labelName: 'Invite Friend',
      icon: const Icon(Icons.group_outlined),
      iconSelected: const Icon(Icons.group),
    ),
    DrawerList(
      index: DrawerIndex.rate,
      labelName: 'Rate the app',
      icon: const Icon(Icons.rate_review_outlined),
      iconSelected: const Icon(Icons.rate_review),
    ),
    DrawerList(
      index: DrawerIndex.about,
      labelName: 'About Us',
      icon: const Icon(Icons.info_outline_rounded),
      iconSelected: const Icon(Icons.info),
    ),
  ];

}


