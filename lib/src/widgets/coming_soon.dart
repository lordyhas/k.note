
import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.emoji_emotions_outlined, size:100),
          Text("Coming Soon"),
        ],
      ),
    );
  }
}
