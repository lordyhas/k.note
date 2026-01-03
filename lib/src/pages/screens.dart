library pages;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knote/data/app_bloc.dart';
import 'package:knote/data/database/firebase_manager.dart';
import 'package:knote/data/database/database_model.dart';
import 'package:knote/data/value/styles.dart';
import 'package:knote/src/pages/old_text_editor_page.dart';
import 'package:knote/src/widgets/coming_soon.dart';

export 'pages/home_screen.dart';
export 'pages/task_screen.dart';

part 'pages/archived_note_screen.dart';
part 'pages/feedback_screen.dart';
part 'pages/help_screen.dart';
part 'pages/invite_friend_screen.dart';
part 'pages/offline_note_screen.dart';
