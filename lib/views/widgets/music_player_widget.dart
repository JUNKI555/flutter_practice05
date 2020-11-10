import 'package:flutter/material.dart';
import 'package:flutter_playout/audio.dart';
import 'package:flutter_playout/player_observer.dart';
import 'package:flutter_playout/player_state.dart';
import '../../entities/content.dart';

class MusicPlayerWidget extends StatefulWidget {
  const MusicPlayerWidget({Key key, this.content}) : super(key: key);

  final Content content;

  String get url => content.source;

  // Audio track title. this will also be displayed in lock screen controls
  String get title => content.title;

  // Audio track subtitle. this will also be displayed in lock screen controls
  String get subtitle => content.outline;

  @override
  _MusicPlayerWidget createState() => _MusicPlayerWidget();
}

class _MusicPlayerWidget extends State<MusicPlayerWidget> with PlayerObserver {
  Audio _audioPlayer;
  PlayerState audioPlayerState = PlayerState.STOPPED;
  bool _loading = false;
  bool _isLive = false;

  Duration duration = const Duration(milliseconds: 1);
  Duration currentPlaybackPosition = Duration.zero;

  bool get isPlaying => audioPlayerState == PlayerState.PLAYING;
  bool get isPaused =>
      audioPlayerState == PlayerState.PAUSED ||
      audioPlayerState == PlayerState.STOPPED;

  String get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  String get positionText => currentPlaybackPosition != null
      ? currentPlaybackPosition.toString().split('.').first
      : '';

  @override
  void initState() {
    super.initState();

    // Init audio player with a callback to handle events
    _audioPlayer = Audio.instance();

    // Listen for audio player events
    listenForAudioPlayerEvents();
  }

  @override
  void didUpdateWidget(MusicPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // オブジェクトが破棄(dispose)された後になんらかのトリガで
  // setStateされるので mounted をみるようにする
  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void onPlay() {
    setState(() {
      audioPlayerState = PlayerState.PLAYING;
      _loading = false;
    });
  }

  @override
  void onPause() {
    setState(() {
      audioPlayerState = PlayerState.PAUSED;
    });
  }

  @override
  void onComplete() {
    setState(() {
      audioPlayerState = PlayerState.PAUSED;
      currentPlaybackPosition = Duration.zero;
    });
  }

  @override
  void onTime(int position) {
    setState(() {
      currentPlaybackPosition = Duration(seconds: position);
    });
  }

  @override
  Future<void> onSeek(int position, double offset) async {
    super.onSeek(position, offset);
  }

  @override
  void onDuration(int duration) {
    if (duration <= 0) {
      setState(() {
        _isLive = true;
      });
    } else {
      setState(() {
        _isLive = false;
        this.duration = Duration(milliseconds: duration);
      });
    }
  }

  @override
  Future<void> onError(String error) async {
    super.onError(error);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: _buildPlayerControls(),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                margin: const EdgeInsets.all(7),
                child: Stack(
                  children: <Widget>[
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      splashColor: Colors.transparent,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white,
                        size: 47,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          pause();
                        } else {
                          play();
                        }
                      },
                    ),
                    _loading
                        ? const Positioned.fill(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(7, 11, 5, 3),
                      child: Text(widget.title,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[100])),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(7, 0, 5, 0),
                      child: Text(widget.subtitle,
                          style: const TextStyle(
                              fontSize: 19, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 15,
          ),
          _isLive
              ? Container(
                  child: Center(
                    child: MaterialButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: <Widget>[
                          const Icon(
                            Icons.fiber_smart_record,
                            color: Colors.redAccent,
                          ),
                          const Text(
                            ' LIVE',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ),
                )
              : Slider(
                  activeColor: Colors.white,
                  value: currentPlaybackPosition?.inMilliseconds?.toDouble() ??
                      0.0,
                  onChanged: (double value) {
                    seekTo(value);
                  },
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                ),
          _isLive
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                      child: Text(
                        _playbackPositionString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }

  String _playbackPositionString() {
    final currentPosition = Duration(
        seconds: duration.inSeconds - currentPlaybackPosition.inSeconds);

    return currentPosition.toString().split('.').first;
  }

  // Request audio play
  Future<void> play() async {
    setState(() {
      _loading = true;
    });
    // here we send position in case user has scrubbed already before hitting
    // play in which case we want playback to start from where user has
    // requested
    await _audioPlayer.play(widget.url,
        title: widget.title,
        subtitle: widget.subtitle,
        position: currentPlaybackPosition,
        isLiveStream: false);
  }

  // Request audio pause
  Future<void> pause() async {
    await _audioPlayer.pause();
    setState(() => audioPlayerState = PlayerState.PAUSED);
  }

  // Request audio stop. this will also clear lock screen controls
  Future<void> stop() async {
    await _audioPlayer.reset();

    setState(() {
      audioPlayerState = PlayerState.STOPPED;
      currentPlaybackPosition = Duration.zero;
    });
  }

  // Seek to a point in seconds
  Future<void> seekTo(double milliseconds) async {
    setState(() {
      currentPlaybackPosition = Duration(milliseconds: milliseconds.toInt());
    });

    await _audioPlayer.seekTo(milliseconds / 1000);
  }

  @override
  void dispose() {
    if (!mounted) {
      return;
    }

    _audioPlayer.dispose();
    super.dispose();
  }
}
