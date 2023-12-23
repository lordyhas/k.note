

import 'package:go_router/go_router.dart';
import 'package:knote/data/values.dart';
import 'package:knote/src/pages/screens.dart';

import '../../../data/app_bloc.dart';
import 'package:flutter/material.dart';
import '../../../data/authentication_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';

part 'signin_home.dart';
part 'login_page.dart';
part 'login_form.dart';
part 'signup_page.dart';
part 'signup_form.dart';
part 'button_login_widget.dart';



enum DefaultPage { login, signIn, modify }


