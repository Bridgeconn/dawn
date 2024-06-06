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
    String text =
        storyDatas[storyIndex]['story'][paraIndex]['url'].split('/').last;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(storyDatas[storyIndex]['title']),
      ),
      body: Center(
        child: storyDatas.isEmpty
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Container(
                    width: 400,
                    height: 140,
                    padding: EdgeInsets.all(12), // Example padding
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/obs-images/${text}'),
                      fit: BoxFit.cover,
                    )),
                    child: Container(
                      padding: EdgeInsets.all(8), // Example padding
                      color: Color(0xF0FDFDFF).withOpacity(0.5),
                      child: Text(
                        storyDatas[storyIndex]['story'][paraIndex]['text'],
                        style: TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.bold),
                      ), // Example background color
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      storyIndex != 0
                          ? IconButton(
                              icon: Icon(Icons.skip_previous),
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  storyIndex =
                                      storyIndex > 0 ? storyIndex - 1 : 0;
                                  paraIndex = 0;
                                });
                              },
                            )
                          : Text(""),
                      paraIndex != 0
                          ? IconButton(
                              icon: Icon(Icons.arrow_left_sharp),
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  paraIndex = paraIndex > 0 ? paraIndex - 1 : 0;
                                });
                              },
                            )
                          : Text(""),
                      Text(storyDatas[storyIndex]['storyId'].toString()),
                      Text(":"),
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
                          : Text(''),
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
                          : Text(""),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: 400,
                        height: 110,
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your text',
                            errorText:
                                _errorMessage.isNotEmpty ? _errorMessage : null,
                          ),
                          maxLines:
                              20, // Increases the height to accommodate up to 5 lines
                          minLines: 10,
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
