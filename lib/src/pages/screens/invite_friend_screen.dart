part of screens;



class InviteFriend extends StatefulWidget {
  static const routeName = "invite-friend";
  const InviteFriend({Key? key}) : super(key: key);

  @override
  State<InviteFriend> createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        //backgroundColor: StyleAppTheme.nearlyWhite,
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 16),
              child: Image.asset('assets/images/inviteImage.png'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: const Text(
                'Invite Your Friends',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16),
              child: const Text(
                'Are you one of those who makes everything\n at the last moment?',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      color: Colors.blue,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
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
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 22,
                              ),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  'Share',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
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
