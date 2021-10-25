library values;

import 'package:flutter/cupertino.dart';

import 'database/database_model.dart';

export 'values/strings.dart';
export 'values/styles.dart';
export '../res.dart';
export  'package:flutter_gen/gen_l10n/app_localizations.dart';


//final String imageLogoApp = Res.logo_2;


class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context,
      Widget child,
      AxisDirection axisDirection,
      ) {
    return child;
  }
}
