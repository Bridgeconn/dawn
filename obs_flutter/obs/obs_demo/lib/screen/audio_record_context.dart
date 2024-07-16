import 'dart:convert';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:obs_demo/utils/chat_bubble.dart';

class AudioRecordContext extends StatefulWidget {
  const AudioRecordContext({super.key, required this.rowIndex});
  final int rowIndex;

  @override
  _AudioRecordContextState createState() => _AudioRecordContextState();
}

class _AudioRecordContextState extends State<AudioRecordContext> {
  //global variables
  late final RecorderController recorderController;
  late final PlayerController playerController;
  String? path;
  bool isRecording = false;
  bool isPaused = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  bool isPlaying = false;
  late Directory appDirectory;
  String _textFieldValue = "";

  List<Map<String, dynamic>> storyDatas = [];
  Map<String, dynamic> story = {};
  FocusNode _focusNode = FocusNode();
  late int storyIndex;
  int paraIndex = 0;
  final TextEditingController _controller = TextEditingController();
// this function for  fetching the story data  from  the json
  Future<void> fetchStoryText() async {
    final jsonString = await rootBundle.loadString('assets/OBSTextData.json');
    setState(() {
      storyDatas = json.decode(jsonString).cast<Map<String, dynamic>>();
      storyIndex = widget.rowIndex;
    });
  }

  @override
  void initState() {
    _getDir();
    fetchStoryText();
    fetchJson();
    _initialiseControllers();
    super.initState();
  }

//initiaize the directory
  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    String appDocPath = appDirectory.path;
    path = '$appDocPath/${storyIndex}.${paraIndex}.wav';
    isLoading = false;
    setState(() {});
  }

//initiaize controllerss value
  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 24;
    recorderController.bitRate = 48000;

    playerController = PlayerController();
  }

// for deleting the recording from the device path and also from  the json
  Future<void> deleteRecording(filepath) async {
    final file = File(filepath!);
    try {
      if (await file.exists()) {
        await file.delete();
        story['story'][paraIndex].remove('audio');
        writeJsonToFile(story);

        print('Recording deleted');
        print(path!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording deleted successfully')),
        );
        setState(() {
          isRecordingCompleted = false;
        });
      } else {
        print('File does not exist');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File does not exist')),
        );
      }
    } catch (e) {
      print('Error deleting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file')),
      );
    }
  }

//fetching the json data also writing the data
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

//reading the json file
  Future<Map<String, dynamic>> readJsonToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${storyIndex}.json');
    // Replace with your desired filename
    try {
      final jsonData = await file.readAsString();
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      _controller.text = data['story'][0]['text'];
      return data;
    } on FileSystemException {
      return <String, dynamic>{};
    } catch (e) {
      print("Error reading JSON file: $e");
      rethrow;
    }
  }

//writting into the json file
  Future<void> writeJsonToFile(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${storyIndex}.json');
    final jsonData = jsonEncode(data);
    await file.writeAsString(jsonData);
  }

  @override
  void dispose() {
    recorderController.dispose();
    playerController.dispose();
    super.dispose();
  }

//playing the audio through the path
  void _playAudio(audioPath) {
    // Ensure to provide the correct path to your audio file
    playerController.preparePlayer(path: audioPath);

    setState(() {
      isPlaying = true;
    });
    playerController.startPlayer(
      finishMode: FinishMode.pause,
    );
    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String text =
        storyDatas[storyIndex]['story'][paraIndex]['url'].split('/').last;
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/$text'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(8),
                color: const Color(0xF0FDFDFF).withOpacity(0.9),
                child: Column(
                  children: [
                    Text(
                      storyDatas[storyIndex]['story'][paraIndex]['text'],
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isPlaying
                        ? IconButton(
                            onPressed: () => {},
                            // _playAudio(story['story'][paraIndex]['audio']),
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.black,
                            ),
                          )
                        : IconButton(
                            onPressed: () =>
                                _playAudio(story['story'][paraIndex]['audio']),
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                          ),
                  ],
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                                _getDir();
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
                                _getDir();
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
                                _getDir();
                                _controller.text =
                                    story?['story']?[paraIndex]['text'];
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
                                _getDir();
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
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // Changes position of shadow
                            ),
                          ],
                          color: Colors
                              .white, // Background color for the text field
                          borderRadius:
                              BorderRadius.circular(5), // Rounded corners
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                              selectionColor:
                                  Colors.grey, // Color of the selected text
                              cursorColor: Colors
                                  .grey, // Color of the caret (text cursor)
                              selectionHandleColor:
                                  Colors.grey, // Color of the selection handles
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              setState(() {
                                _textFieldValue = value;
                              });
                            },
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: (_focusNode.hasFocus ||
                                      _textFieldValue.isNotEmpty)
                                  ? null
                                  : 'Start translating story',
                              labelStyle: TextStyle(
                                  color: Colors
                                      .grey), // Optional: changes label color to grey

                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: InputBorder
                                  .none, // Removes the default border
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 10.0), // Adjust padding as needed
                            ),
                            maxLines:
                                30, // Increases the height to accommodate up to 30 lines
                          ),
                        ),
                      ),
                    ),
                  ),
                  //for audio waves
                  if (story['story'][paraIndex]['audio'] != null)
                    WaveBubble(
                        path: story['story'][paraIndex]['audio'],
                        isSender: true,
                        appDirectory: appDirectory,
                        deleteRecording: deleteRecording),
                  if (!isRecording &&
                      story['story'][paraIndex]['audio'] == null)
                    WaveBubble(
                        path: '',
                        isSender: false,
                        appDirectory: appDirectory,
                        deleteRecording: deleteRecording),
                  Row(
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
                              )
                            : const Text(""),
                      ),
                      //start and stop recording
                      if (story['story'][paraIndex]['audio'] == null)
                        Center(
                          child: IconButton(
                            onPressed: () =>
                                _startOrStopRecording(storyIndex, paraIndex),
                            icon: Icon(isRecording ? Icons.stop : Icons.mic),
                            color: Colors.black,
                            iconSize: 28,
                          ),
                        ),
                      //pause reording
                      if (isRecording && !isPaused)
                        IconButton(
                          onPressed: _pauseRecording,
                          icon: const Icon(
                            Icons.pause,
                            color: Colors.black,
                          ),
                        ),
                      //resume recording
                      if (isPaused)
                        IconButton(
                          onPressed: _resumeRecording,
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// this function work for start and stop recording
  void _startOrStopRecording(storyNumber, paraNumber) async {
    isLoading = false;
    try {
      if (isRecording) {
        print(path);
        path = await recorderController.stop();
        setState(() {
          isPaused = false;
        });
        recorderController.reset();

        if (path != "") {
          isRecordingCompleted = true;
          debugPrint(path);
        }
        story['story'][paraNumber]['audio'] = path;
        writeJsonToFile(story);
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

// this function work for paue recording
  void _pauseRecording() async {
    try {
      await recorderController.pause();
      setState(() {
        isPaused = true;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
// this function work for resume recording

  void _resumeRecording() async {
    try {
      await recorderController.record();
      setState(() {
        isPaused = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//refresh the waves
  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }
}
