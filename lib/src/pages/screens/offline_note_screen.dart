part of screens;
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  _OfflineScreenState createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  late final FirebaseManager fbm ;
  @override
  void initState() {
    super.initState();
    fbm = FirebaseManager(
        BlocProvider.of<AuthenticationBloc>(context).state.user
    );
  }
  @override
  Widget build(BuildContext context) {
    var user = BlocProvider.of<AuthenticationBloc>(context).state.user;
    return Column(
      children: [
        const Spacer(),
        ComingSoon(),
        const Spacer(),
      ],
    );
  }
}
