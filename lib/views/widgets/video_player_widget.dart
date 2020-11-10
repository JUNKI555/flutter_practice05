import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playout/multiaudio/HLSManifestLanguage.dart';
import 'package:flutter_playout/multiaudio/MultiAudioSupport.dart';
import 'package:flutter_playout/player_observer.dart';
import 'package:flutter_playout/player_state.dart';
import 'package:flutter_playout/video.dart';

import '../../entities/content.dart';
import '../../utils/get_manifest_languages.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key key, this.content}) : super(key: key);

  final Content content;

  bool get showPlayerControls => true;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with PlayerObserver, MultiAudioSupport {
  String _url = '';
  List<HLSManifestLanguage> _hlsLanguages = <HLSManifestLanguage>[];

  final PlayerState _desiredState = PlayerState.PAUSED;
  bool _landscape = false;

  @override
  void initState() {
    super.initState();
    _url = widget.content.source;
    Future.delayed(Duration.zero, _getHLSManifestLanguages);
  }

  // オブジェクトが破棄(dispose)された後になんらかのトリガで
  // setStateされるので mounted をみるようにする
  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _getHLSManifestLanguages() async {
    if (!Platform.isIOS && _url != null && _url.isNotEmpty) {
      _hlsLanguages = await getManifestLanguages(_url);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              /* player */
              SizedBox(
                height: !_landscape ? null : double.infinity,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Video(
                    autoPlay: true,
                    showControls: widget.showPlayerControls,
                    title: widget.content.title,
                    subtitle: widget.content.outline,
                    preferredAudioLanguage: 'ja',
                    isLiveStream: true,
                    position: 0,
                    url: _url,
                    onViewCreated: _onViewCreated,
                    desiredState: _desiredState,
                    preferredTextLanguage: 'ja',
                  ),
                ),
              ),
              /* hack fullscreen button */
              Positioned(
                top: 0,
                left: 0,
                child: Opacity(
                  opacity: 0,
                  child: IconButton(
                    iconSize: 50,
                    onPressed: _onPressedRotate,
                    color: Colors.white,
                    icon: const Icon(Icons.fit_screen),
                  ),
                ),
              ),
            ],
          ),
          /* multi language menu */
          _hlsLanguages.length < 2 && !Platform.isIOS
              ? Container()
              : Container(
                  child: Row(
                    children: _hlsLanguages
                        .map((e) => MaterialButton(
                              child: Text(
                                e.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: Colors.white),
                              ),
                              onPressed: () {
                                setPreferredAudioLanguage(e.code);
                              },
                            ))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }

  void _changeScreen() {
    switch (_landscape) {
      case false:
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
        break;
      case true:
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeRight]);
        break;
    }
  }

  void _onPressedRotate() {
    setState(() {
      _landscape = !_landscape;
    });

    _changeScreen();
  }

  void _onViewCreated(int viewId) {
    listenForVideoPlayerEvents(viewId);
    enableMultiAudioSupport(viewId);
  }

  @override
  void onPlay() {
    super.onPlay();

    setState(() {});
  }

  @override
  void onPause() {
    super.onPause();

    setState(() {
      _landscape = false;
    });

    _changeScreen();
  }

  @override
  Future<void> onComplete() async {
    super.onComplete();

    setState(() {
      _landscape = false;
    });

    _changeScreen();
  }

  @override
  Future<void> onTime(int position) async {
    // TODO: implement onTime
    super.onTime(position);
  }

  @override
  Future<void> onSeek(int position, double offset) async {
    // TODO: implement onSeek
    super.onSeek(position, offset);
  }

  @override
  Future<void> onDuration(int duration) async {
    // TODO: implement onDuration
    super.onDuration(duration);
  }

  @override
  Future<void> onError(String error) async {
    super.onError(error);

    setState(() {
      _landscape = false;
    });

    _changeScreen();
  }
}
