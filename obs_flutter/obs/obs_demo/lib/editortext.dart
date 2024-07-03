import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:obs_demo/audio_bubble.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class EditorTextLayout extends StatefulWidget {
  const EditorTextLayout({required this.rowIndex});

  final int rowIndex;

  @override
  _EditorTextLayoutState createState() => _EditorTextLayoutState();
}

class _EditorTextLayoutState extends State<EditorTextLayout> {
  List<Map<String, dynamic>> storyDatas = [];
  Map<String, dynamic> story = {};

  late int storyIndex;
  int paraIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = "";
  String _textFieldValue = "";
  bool isRecording = false;
  bool isPlaying = false;
  int currentPositionInSeconds = 0;

  late final RecorderController recorderController;
  late final PlayerController playerController;

  String? _recordedFilePath;

  Future<void> fetchStoryText() async {
    final jsonString = await rootBundle.loadString('assets/OBSTextData.json');
    setState(() {
      storyDatas = json.decode(jsonString).cast<Map<String, dynamic>>();
      storyIndex = widget.rowIndex;
    });
  }

  Future<void> fetchJson() async {
    Map<String, dynamic> data = await readJsonToFile();
    if (data.isEmpty) {
      final obsJson = await rootBundle.loadString('assets/OBSData.json');
      var obsData = json.decode(obsJson).cast<Map<String, dynamic>>();
      writeJsonToFile(obsData[storyIndex]);
      setState(() {
        story = obsData[storyIndex];
      });
    } else {
      setState(() {
        story = data;
      });
    }
  }

  Future<void> writeJsonToFile(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/${storyIndex}.json'); // Replace with your desired filename
    final jsonData = jsonEncode(data);
    print(jsonData);
    await file.writeAsString(jsonData);
  }

  Future<Map<String, dynamic>> readJsonToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/${storyIndex}.json'); // Replace with your desired filename
    try {
      final jsonData = await file.readAsString();
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      _controller.text = data['story'][0]['text'];
      return data;
    } on FileSystemException {
      // Handle the case where the file doesn't exist or can't be read
      return <String, dynamic>{}; // Return an empty map or handle differently
    } catch (e) {
      // Handle other exceptions
      print("Error reading JSON file: $e");
      rethrow; // Re-throw for further handling if needed
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStoryText();
    fetchJson();
    _initialiseControllers();
    _preparePaths();
  }

  void _initialiseControllers() async {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;

    playerController = PlayerController();

    // Prepare path for recording and audio playback
    await _preparePaths();
  }

  Future<void> _preparePaths() async {
    Directory directory = await getApplicationDocumentsDirectory();
    int storyId = storyDatas[storyIndex]['storyId'];
    int paraId = storyDatas[storyIndex]['story'][paraIndex]['id'];

    _recordedFilePath = '${directory.path}/OBS_${storyId}_$paraId.wav';

    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (await file.exists()) {
        await playerController.preparePlayer(
          path: _recordedFilePath!,
          shouldExtractWaveform: true,
        );
      } else {
        print('File does not exist: $_recordedFilePath');
      }
    } else {
      print('Recorded file path is null.');
    }
  }

  void _startRecording() async {
    int storyId = storyDatas[storyIndex]['storyId'];
    int paraId = storyDatas[storyIndex]['story'][paraIndex]['id'];

    _recordedFilePath =
        '${(await getApplicationDocumentsDirectory()).path}/OBS_${storyId}_$paraId.wav';

    if (story['story'][paraIndex]['audio'] == null) {
      try {
        setState(() {
          isRecording = true; // Start recording, update state
        });
        await recorderController.record(path: _recordedFilePath!);
      } catch (e) {
        print('Error recording: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Audio already recorded'),
          content: Text('Do you want to re-record the audio?'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _startNewRecording();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _startNewRecording() async {
    try {
      setState(() {
        isRecording = true; // Start new recording, update state
      });
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
          print('Deleted old recorded file: $_recordedFilePath');
        }
      }

      final path = await recorderController.record(path: _recordedFilePath!);
      setState(() {
        story['story'][paraIndex]['audio'] = _recordedFilePath;
      });
    } catch (e) {
      print('Error starting new recording: $e');
    }
  }

  void _stopRecording() async {
    try {
      final path = await recorderController.stop();
      setState(() {
        _recordedFilePath = path;
        story['story'][paraIndex]['audio'] = _recordedFilePath;
        isRecording = false;
      });
      writeJsonToFile(story);
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _startPlayback() async {
    String? playbackPath = _recordedFilePath;

    if (playbackPath != null) {
      final file = File(playbackPath);
      if (await file.exists()) {
        try {
          await playerController.preparePlayer(
            path: playbackPath,
            shouldExtractWaveform: true,
          );

          // Start playback
          await playerController.startPlayer();

          // Update playback state
          setState(() {
            isPlaying = true;
          });

          playerController.onPlayerStateChanged.listen((state) {
            if (state == PlayerState.stopped) {
              _stopPlayback(); // Stop playback when it completes
            }
          });
          // Manually track playback position using a Timer
          Timer? timer;
          timer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              currentPositionInSeconds++;
            });

            // Example: Stop playback after 10 seconds (adjust as needed)
            if (currentPositionInSeconds >= 2) {
              _stopPlayback();
              timer?.cancel();
            }
          });
        } catch (e) {
          print('Error starting playback: $e');
        }
      } else {
        print('Audio file does not exist at path: $playbackPath');
      }
    } else {
      print('Audio file path is null. Cannot start playback.');
    }
  }

  void _stopPlayback() async {
    try {
      await playerController.stopPlayer();
      setState(() {
        isPlaying = false;
        currentPositionInSeconds = 0; // Reset position on stop
      });
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    recorderController.dispose();
    playerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (storyDatas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String text =
        storyDatas[storyIndex]['story'][paraIndex]['url'].split('/').last;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Close the keyboard when tapping outside
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(storyDatas[storyIndex]['title']),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/$text'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(8), // Example padding
                color: const Color(0xF0FDFDFF).withOpacity(0.9),
                child: Text(
                  storyDatas[storyIndex]['story'][paraIndex]['text'],
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ), // Example background color
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      storyIndex != 0
                          ? IconButton(
                              icon: const Icon(Icons.skip_previous),
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  storyIndex =
                                      storyIndex > 0 ? storyIndex - 1 : 0;
                                  paraIndex = 0;
                                });
                                fetchJson();
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.skip_previous),
                              iconSize: 35,
                              color: Color.fromARGB(66, 168, 163, 163)
                                  .withOpacity(0.5),
                              onPressed: () {},
                            ),
                      paraIndex != 0
                          ? IconButton(
                              icon: Icon(Icons.arrow_left_sharp),
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  paraIndex = paraIndex > 0 ? paraIndex - 1 : 0;
                                });
                                _controller.text =
                                    story['story'][paraIndex]['text'];
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.arrow_left_sharp),
                              iconSize: 35,
                              color: Color.fromARGB(66, 168, 163, 163)
                                  .withOpacity(0.5),
                              onPressed: () {},
                            ),
                      Text(storyDatas[storyIndex]['storyId'].toString()),
                      const Text(":"),
                      Text(storyDatas[storyIndex]['story'][paraIndex]['id']
                          .toString()),
                      paraIndex != storyDatas[storyIndex]['story'].length - 1
                          ? IconButton(
                              icon: Icon(Icons.arrow_right_sharp),
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  paraIndex = paraIndex + 1;
                                });
                                _controller.text =
                                    story['story'][paraIndex]['text'];
                                _recordedFilePath =
                                    story['story'][paraIndex]['audio'];
                                _preparePaths(); // Prepare audio path for playback
                                if (_recordedFilePath == null) {
                                  _startRecording(); // Start recording if audio path is null
                                }
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.arrow_right_sharp),
                              iconSize: 35,
                              color: Colors.black26.withOpacity(0.5),
                              onPressed: () {},
                            ),
                      storyIndex != storyDatas.length - 1
                          ? IconButton(
                              icon: Icon(Icons.skip_next),
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  storyIndex = storyIndex + 1;
                                  paraIndex = 0;
                                });
                                fetchJson();
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.skip_next),
                              iconSize: 35,
                              color: Color.fromARGB(66, 168, 163, 163)
                                  .withOpacity(0.5),
                              onPressed: () {},
                            ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: 200,
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {
                            _textFieldValue = value;
                          });
                          saveData(_textFieldValue);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter your text',
                          errorText:
                              _errorMessage.isNotEmpty ? _errorMessage : null,
                        ),
                        maxLines:
                            30, // Increases the height to accommodate up to 30 lines
                      ),
                    ),
                  ),
                  AudioBubble(
                    recordedFilePath: _recordedFilePath,
                    recorderController: recorderController,
                    playerController: playerController,
                    currentPositionInSeconds: currentPositionInSeconds,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.mic),
                        iconSize: 50,
                        onPressed: isRecording ? null : _startRecording,
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        iconSize: 50,
                        onPressed: isRecording ? _stopRecording : null,
                      ),
                      SizedBox(width: 20),
                      if (!isPlaying)
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          iconSize: 50,
                          onPressed: (_recordedFilePath != null &&
                                  _recordedFilePath!.isNotEmpty)
                              ? _startPlayback
                              : null,
                          color: (_recordedFilePath != null &&
                                  _recordedFilePath!.isNotEmpty)
                              ? Colors.green
                              : Colors.grey,
                          disabledColor: Colors.grey,
                        ),
                      if (isPlaying)
                        IconButton(
                          icon: Icon(Icons.stop_circle),
                          iconSize: 50,
                          onPressed: _stopPlayback,
                        ),
                      // if (playerController.playerState == PlayerState.playing)
                      //   const Text('Playing...'),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveData(String value) async {
    story['story'][paraIndex]['text'] = value;
    if (_recordedFilePath != null) {
      story['story'][paraIndex]['audio'] = _recordedFilePath;
    }

    // Save updated data to JSON file
    writeJsonToFile(story);

    print('Data saved: $value');
// You can perform saving operations here, like storing to a database, file, etc.
  }
}
