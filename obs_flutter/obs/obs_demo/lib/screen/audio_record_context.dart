import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:obs_demo/screen/story_para.dart';
import 'package:path_provider/path_provider.dart';
import 'package:obs_demo/utils/chat_bubble.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class AudioRecordContext extends StatefulWidget {
  @override
  _AudioRecordContextState createState() => _AudioRecordContextState();
}

class _AudioRecordContextState extends State<AudioRecordContext> {
  late final RecorderController recorderController;
  // final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;

  @override
  void initState() {
    _getDir();
    _initialiseControllers();
    super.initState();
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 24;
    recorderController.bitRate = 48000;
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      musicFile = result.files.single.path;
      setState(() {});
    } else {
      debugPrint("File not picked");
    }
  }

  // Future<void> _convertToWav(String inputPath) async {
  //   final outputPath = inputPath.replaceAll('.m4a', '.wav');
  //   await _flutterFFmpeg.execute('-i $inputPath $outputPath');
  //   path = outputPath;
  //   debugPrint('Converted to WAV: $outputPath');
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: [
                  StoryPara(),
                  if (isRecordingCompleted)
                    WaveBubble(
                      path: path!,
                      isSender: true,
                      appDirectory: appDirectory,
                    ),
                  const SizedBox(height: 20),
                  SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isRecording
                              ? AudioWaveforms(
                                  enableGesture: true,
                                  size: Size(
                                    MediaQuery.of(context).size.width / 2,
                                    50,
                                  ),
                                  recorderController: recorderController,
                                  waveStyle: const WaveStyle(
                                    waveColor: Colors.white,
                                    extendWaveform: true,
                                    showMiddleLine: false,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: const Color(0xFF1E1B26),
                                  ),
                                  padding: const EdgeInsets.only(left: 18),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                )
                              : const Text(""),
                        ),
                        if (isRecording)
                          IconButton(
                            onPressed: _refreshWave,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.black,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Center(
                          child: IconButton(
                            onPressed: _startOrStopRecording,
                            icon: Icon(isRecording ? Icons.stop : Icons.mic),
                            color: Colors.black,
                            iconSize: 28,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
        }
      } else {
        await recorderController.record(path: path); // Path is optional
        setState(() {
          isRecordingCompleted = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }
}
