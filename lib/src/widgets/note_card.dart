import 'package:flutter/material.dart';
import 'package:knote/data/app_database.dart';

class NoteCard extends StatelessWidget {
  final Color? color;
  final bool changeInList;
  final NoteModel note;


  NoteCard({
    required this.note,
    this.color,
    this.changeInList = false,
  }) ;

  //NoteModel get noteData => note;

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.grey.shade100,
      elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      child: Text(note.title ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        //textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  const SizedBox(height: 0.2,),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                          child: Text(note.text ?? "",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,)
                      ),
                    ),
                  ),
                  /*Container(
                    height: 20,
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        Container(
                          child: Text(""),
                        ),

                      ],
                    ),
                  ),*/
                  Container(
                    height: 4.0,
                    color: color ?? Theme.of(context).primaryColor,
                  ),

                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0, top: 2.0),
                    child: Icon(Icons.cloud_done_sharp,
                      color: color ?? Colors.lightBlueAccent.withOpacity(0.7), )
                ),
              ),
            ],
          ),
        )
    );
  }
}
