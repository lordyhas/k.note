import 'package:flutter/material.dart';

import 'package:knote/domain/models/note.dart';
import 'package:knote/ui/core/themes/app_theme.dart';
import 'package:knote/ui/notes/widgets/note_text.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.surfaceRadius),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  // Room on the right for the sync icon.
                  margin: const EdgeInsets.fromLTRB(10, 8, 36, 2),
                  child: Text(
                    note.title ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(
                height: 0.2,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 2, 10, 6),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        notePlainText(note.text),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ),
              Container(
                height: 3.0,
                color: color ?? Theme.of(context).primaryColor,
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
                margin: const EdgeInsets.only(right: 10.0, top: 6.0),
                child: Icon(
                  Icons.cloud_done_outlined,
                  size: 18,
                  color: color ?? Colors.lightBlueAccent.withValues(alpha: 0.7),
                )),
          ),
        ],
      ),
    ));
  }
}
