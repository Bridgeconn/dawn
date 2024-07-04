import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late AudioPlayer audioPlayer;
  String? _filePath;
  bool _isRecording = false;
  bool _hasRecording = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    if (await Record().hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      _filePath = '${directory.path}/audio_recording.wav';
      await Record().start(
        path: _filePath,
        encoder: AudioEncoder.AAC,
        bitRate: 128000,
        samplingRate: 44100,
      );
      setState(() {
        _isRecording = true;
        _hasRecording = false;
      });
      print('Recording started: $_filePath');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  Future<void> _stopRecording() async {
    await Record().stop();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
    });
    print('Recording stopped: $_filePath');
  }

  Future<void> _playRecording() async {
    if (_filePath != null && File(_filePath!).existsSync()) {
      await audioPlayer.play(DeviceFileSource(_filePath!));
      print('Playing recording: $_filePath');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No recording found or file does not exist')),
      );
    }
  }

  @override
  void dispose() {
    if (_isRecording) {
      _stopRecording();
    }
    audioPlayer.dispose();
    super.dispose();
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
            Text(_isRecording ? 'Recording...' : 'Press the button to record'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            if (_filePath != null && !_isRecording && _hasRecording) ...[
              SizedBox(height: 20),
              Text('Recording saved at:'),
              Text(_filePath!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _playRecording,
                child: Text('Play Recording'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
