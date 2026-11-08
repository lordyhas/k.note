import 'package:flutter/material.dart';

import 'package:knote/config/assets.dart';

class BackgroundUI extends StatelessWidget {
  final Widget? child;
  final int index;

  BackgroundUI({super.key, this.child, this.index = 1})
      : assert(index > 0 && index <= 3);

  final List<String> path = [
    AppAssets.bgImage1,
    AppAssets.bgImage2,
    AppAssets.bgImage3,
  ];

  @override
  Widget build(BuildContext context) {

    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(path[index-1]),
              fit: BoxFit.fill
          ),
        ),
      ),
      Container(
          color: Colors.transparent,
          child: child
      ),

    ],);
  }
}
