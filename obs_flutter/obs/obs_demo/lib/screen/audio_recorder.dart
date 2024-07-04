import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:general_audio_waveforms/general_audio_waveforms.dart';

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  String _audioFilePath = '';
  bool _isRecording = false;
  bool _hasRecording = false;
  Duration elapsedTime = const Duration(seconds: 0);
  Duration maxDuration = const Duration(seconds: 150);

  @override
  void initState() {
    audioRecord = Record();
    audioPlayer = AudioPlayer();
    _requestPermissions();

    super.initState();
  }

  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start(samplingRate: 21, bitRate: 48000);
        setState(() {
          _isRecording = true;
          _hasRecording = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        _isRecording = false;
        _audioFilePath = path!;
        _hasRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> playRecording() async {
    try {
      Source urlSource = UrlSource(_audioFilePath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Audio Recorder'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRecording ? 'Recording...' : 'Press the button to record',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isRecording ? stopRecording : startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            if (_hasRecording)
              ElevatedButton(
                onPressed: playRecording,
                child: Text('Play Recording'),
              ),
            PlayerWidget(player: audioPlayer)
          ],
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;

  const PlayerWidget({
    required this.player,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
          ],
        ),
        Slider(
          onChanged: (value) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = value * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
