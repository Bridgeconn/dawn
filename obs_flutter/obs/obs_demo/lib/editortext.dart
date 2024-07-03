import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class EditorTextLayout extends StatefulWidget {
  const EditorTextLayout({
    required this.rowIndex,
    required this.onUpdateTextAvailability,
  });

  final int rowIndex;
  final Function(bool hasText) onUpdateTextAvailability;

  @override
  _EditorTextLayoutState createState() => _EditorTextLayoutState();
}

class _EditorTextLayoutState extends State<EditorTextLayout> {
  List<Map<String, dynamic>> storyDatas = [];
  Map<String, dynamic> story = {};
  bool isCompleted = false;
  FocusNode _focusNode = FocusNode();
  late int storyIndex;
  int paraIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = "";
  String _textFieldValue = "";

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
    final file = File('${directory.path}/${storyIndex}.json');
    final jsonData = jsonEncode(data);
    await file.writeAsString(jsonData);
  }

  Future<Map<String, dynamic>> readJsonToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${storyIndex}.json');
    // Replace with your desired filename
    try {
      final jsonData = await file.readAsString();
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      _controller.text = data['story'][0]['text'];
      data['story'][0]['isEmpty'] = false;
      return data;
    } on FileSystemException {
      return <String, dynamic>{};
    } catch (e) {
      print("Error reading JSON file: $e");
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStoryText();
    fetchJson();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode.dispose();
    super.dispose();
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
        FocusScope.of(context).unfocus();
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
                padding: const EdgeInsets.all(8),
                color: const Color(0xF0FDFDFF).withOpacity(0.9),
                child: Text(
                  storyDatas[storyIndex]['story'][paraIndex]['text'],
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                                    paraIndex =
                                        paraIndex > 0 ? paraIndex - 1 : 0;
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
                                color: Colors.grey
                                    .withOpacity(0.5), // Shadow color
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
                                selectionHandleColor: Colors
                                    .grey, // Color of the selection handles
                              ),
                            ),
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: (value) {
                                setState(() {
                                  _textFieldValue = value;
                                });
                                saveData(_textFieldValue);
                              },
                              decoration: InputDecoration(
                                labelText: (_focusNode.hasFocus ||
                                        _textFieldValue.isNotEmpty)
                                    ? null
                                    : 'Start translating story',
                                labelStyle: TextStyle(
                                    color: Colors
                                        .grey), // Optional: changes label color to grey
                                errorText: _errorMessage.isNotEmpty
                                    ? _errorMessage
                                    : null,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: InputBorder
                                    .none, // Removes the default border
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal:
                                        10.0), // Adjust padding as needed
                              ),
                              maxLines:
                                  30, // Increases the height to accommodate up to 30 lines
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveData(String value) async {
    story['story'][paraIndex]['text'] = value;
    story['story'][paraIndex]['isEmpty'] = value.isEmpty;
    writeJsonToFile(story);
    widget.onUpdateTextAvailability(value.isNotEmpty);
    print('Data saved: $value');
    print(story['story'][paraIndex]);
  }
}
