
import 'package:flutter/material.dart';
import 'package:knote/widgets.dart';


class CalendarScreen {


  static Future<void> calendar(context){
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),

    ).then((value) {});
  }

  /*

  @override
  Widget build(BuildContext context) {


    return Container(
      child: Column(
        children: [
          Spacer(),
          ComingSoon(),
          Spacer(),
        ],
      )
    );
  }*/
}
