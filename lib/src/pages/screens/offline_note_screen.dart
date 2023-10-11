part of screens;
class OfflineScreen extends StatefulWidget {
  @override
  _OfflineScreenState createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  FirebaseManager fbm = new FirebaseManager();
  @override
  Widget build(BuildContext context) {
    var user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    return Container(
        child: Column(

          children: [
            Spacer(),
            ComingSoon(),
            Spacer(),
          ],
        )
    );
  }
}
