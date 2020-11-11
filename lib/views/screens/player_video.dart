import 'package:flutter/material.dart';
import '../../entities/content.dart';
import '../widgets/video_player_widget.dart';

class PlayerVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _content = ModalRoute.of(context).settings.arguments as Content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: VideoPlayerWidget(
          content: _content,
        ),
      ),
    );
  }
}
