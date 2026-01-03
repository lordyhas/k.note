import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:knote/data/app_database.dart';

class NoteCard extends StatelessWidget {
  final Color? color;
  final bool changeInList;
  final NoteModel note;

  const NoteCard({
    super.key,
    required this.note,
    this.color,
    this.changeInList = false,
  });

  //NoteModel get noteData => note;

  String _previewText(String? content) {
    if (content == null || content.isEmpty) {
      return "";
    }
    try {
      final json = jsonDecode(content);
      // Quill adds a newline at the end of the document, trim it for preview
      return Document.fromJson(json).toPlainText().trim();
    } catch (e) {
      // If it's not JSON (legacy text), return as is
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        //color: Colors.grey.shade700,
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
                      child: Text(
                        note.title ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        //textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 0.2,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _previewText(note.text),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                  ),
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
                    child: Icon(
                      Icons.cloud_done_sharp,
                      color: color ?? Colors.lightBlueAccent.withOpacity(0.7),
                    )),
              ),
            ],
          ),
        ));
  }
}
