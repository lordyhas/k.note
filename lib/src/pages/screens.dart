
library screens;
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/app_database.dart';
import 'package:knote/data/authentication_repository.dart';
import 'package:knote/data/values.dart';
import 'package:share/share.dart';


import 'package:flutter/material.dart';

import '../../widgets.dart';
import 'package:knote/src/pages/text_editor_page.dart';



export  'screens/home_screen.dart';


part 'screens/archived_note_screen.dart';
part 'screens/feedback_screen.dart';
part 'screens/help_screen.dart';

part 'screens/invite_friend_screen.dart';
part 'screens/offline_note_screen.dart';
//export 'screens/';
