import 'package:flutter/material.dart';
import 'package:knote/res.dart';

class BackgroundUI extends StatelessWidget {
  final Widget? child;
  final int index;

  BackgroundUI({super.key, this.child, this.index = 2})
      : assert(index < 3);

  final List<String> path = [
    Res.bgImage1,
    Res.bgImage2,
    Res.bgImage3,
  ];

  @override
  Widget build(BuildContext context) {

    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(path[index]),
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
