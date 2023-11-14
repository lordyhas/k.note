part of pages;

class OfflineScreen extends StatefulWidget {
  static const routeName = "offline";
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  late FirebaseManager fbm;
  @override
  Widget build(BuildContext context) {
    FirebaseManager.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user
    );
    return Column(

      children: [
        const Spacer(),
        ComingSoon(),
        const Spacer(),
      ],
    );
  }
}
