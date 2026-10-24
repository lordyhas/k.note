import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knote/data/services/firestore_service.dart';
import 'package:knote/ui/auth/bloc/authentication_bloc.dart';
import 'package:knote/ui/core/widgets/coming_soon.dart';

class OfflineNotesPage extends StatefulWidget {
  static const routeName = "offline";
  const OfflineNotesPage({super.key});

  @override
  State<OfflineNotesPage> createState() => _OfflineNotesPageState();
}

class _OfflineNotesPageState extends State<OfflineNotesPage> {
  late FirestoreService fbm;
  @override
  Widget build(BuildContext context) {
    FirestoreService.user(
        BlocProvider.of<AuthenticationBloc>(context).state.user);
    return Column(
      children: [
        const Spacer(),
        const ComingSoon(),
        const Spacer(),
      ],
    );
  }
}
