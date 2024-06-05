import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  Map tempMap = Map();
  List<Map<String, dynamic>> storyData = [];
  Future<void> fetchdata() async {
    final url =
        'https://raw.githubusercontent.com/Bridgeconn/vachancontentrepository/master/obs/eng/content/01.md';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = response.body;
      final jsonData = parseMarkdownToJson(data);
      setState(() {
        tempMap = jsonData;
      });
      setState(() {
        storyData = tempMap['story'];
      });
    } else {
      print('Failed to load markdown data');
    }
  }

  Map<String, dynamic> parseMarkdownToJson(String data) {
    List<Map<String, dynamic>> story = [];
    int id = 0;
    final allLines = data.split(RegExp(r'\r\n|\n'));
    String title = "";
    String end = "";
    String error = "";

    try {
      for (var line in allLines) {
        if (line.isNotEmpty) {
          if (line.startsWith('# ')) {
            title = line.substring(2).trim();
          } else if (line.startsWith('_')) {
            end = line.substring(1, line.length - 1).trim();
          } else if (line.startsWith('!')) {
            id += 1;
            final imgUrl = RegExp(r'\((.*)\)').firstMatch(line);
            if (imgUrl != null) {
              story.add({'id': id, 'url': imgUrl.group(1), 'text': ""});
            }
          } else {
            if (story.isNotEmpty) {
              story[id - 1]['text'] = line.trim();
            }
          }
        }
      }
    } catch (e) {
      error = "Error parsing OBS md file text";
      title = "";
      end = "";
      story = [];
    }

    return {'title': title, 'story': story, 'end': end, 'error': error};
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchdata();
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
      body: ListView.builder(
        itemCount: storyData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(storyData[index]['text']),
            subtitle: Image.network(storyData[index]['url']),
          );
        },
      ),
    );
  }
}
