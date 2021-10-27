import 'package:flutter/material.dart';
import 'package:knote/res.dart';

class BackgroundUI extends StatelessWidget {
  final Widget? child;
  final int index;

   const BackgroundUI({Key? key, this.child, this.index = 2})
      : assert(index < 3), super(key: key);



  @override
  Widget build(BuildContext context) {
    final List<String> path = [
      Res.bg_image1,
      Res.bg_image2,
      Res.bg_image3,
    ];

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
