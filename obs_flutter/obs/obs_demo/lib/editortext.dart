import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class EditorTextLayout extends StatefulWidget {
  const EditorTextLayout({required this.rowIndex});

  final int rowIndex;

  @override
  _EditorTextLayoutState createState() => _EditorTextLayoutState();
}

class _EditorTextLayoutState extends State<EditorTextLayout> {
  List<Map<String, dynamic>> storyDatas = [];
  late int storyIndex;
  int paraIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = "";
  String _textFieldValue = '';
  Future<void> fetchJson() async {
    final jsonString = await rootBundle.loadString('assets/OBSTextData.json');
    setState(() {
      storyDatas = json.decode(jsonString).cast<Map<String, dynamic>>();
      storyIndex = widget.rowIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchJson();
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
    print(_textFieldValue);
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
                          },
                          onSubmitted: (value) {
                            _saveData(value);
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData(String value) {
    // Here you can save the data to a database, file, or any other storage mechanism
    print('Data saved: $value');
    // You can perform saving operations here, like storing to a database, file, etc.
  }
}
