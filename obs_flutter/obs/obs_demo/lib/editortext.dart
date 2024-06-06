import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const EditorText());
}

class EditorText extends StatelessWidget {
  const EditorText({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class EditorTextLayout extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<EditorTextLayout> createState() => _EditorTextLayoutState();
}

class _EditorTextLayoutState extends State<EditorTextLayout> {
  List<Map<String, dynamic>> storyDatas = [];
  int storyIndex = 0;
  int paraIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = "";
  Future<void> fetchJson() async {
    final jsonString = await rootBundle.loadString('store/OBSTextData.json');
    setState(() {
      storyDatas = json.decode(jsonString).cast<Map<String, dynamic>>();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the EditorTextLayout object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adding some space between button and text
            Padding(
              padding: const EdgeInsets.all(10.0), // Padding on all sides
              child: Text(
                storyDatas[storyIndex]['story'][paraIndex]['text'],
                style: TextStyle(
                  fontSize: 14.5,
                ),
              ),
            ),
            // Adding some space between icon and text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                storyIndex != 0
                    ? IconButton(
                        icon: Icon(Icons.skip_previous),
                        iconSize: 35, // Adjust the size of the icon as needed
                        onPressed: () {
                          int num = storyIndex;
                          num == 0 ? 0 : num = num - 1;
                          setState(() {
                            storyIndex = num;
                          });
                        },
                      )
                    : Text(""),
                paraIndex != 0
                    ? IconButton(
                        icon: Icon(Icons.arrow_left_sharp),
                        iconSize: 35, // Adjust the size of the icon as needed
                        onPressed: () {
                          // Action when button is pressed
                          int num = paraIndex;
                          num == 0 ? 0 : num = num - 1;
                          setState(() {
                            paraIndex = num;
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
                        iconSize: 35, // Adjust the size of the icon as needed
                        onPressed: () {
                          // Action when button is pressed
                          setState(() {
                            paraIndex = paraIndex + 1;
                          });
                        },
                      )
                    : Text(''),
                storyIndex != storyDatas.length - 1
                    ? IconButton(
                        icon: Icon(Icons.skip_next),
                        iconSize: 35, // Adjust the size of the icon as needed
                        onPressed: () {
                          setState(() {
                            storyIndex = storyIndex + 1;
                          });
                        },
                      )
                    : Text(""),
              ],
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your text',
                errorText: _errorMessage,
              ),
            )
          ],
        ),
      ),
    );
  }
}
