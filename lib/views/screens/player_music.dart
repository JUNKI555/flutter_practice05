import 'package:flutter/material.dart';
import '../../entities/content.dart';
import '../widgets/music_player_widget.dart';

class PlayerMusic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _content = ModalRoute.of(context).settings.arguments as Content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Center(child: MusicPlayerWidget(content: _content)),
    );
  }
}
