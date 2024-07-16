import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoryPara extends StatefulWidget {
  const StoryPara({super.key, required this.rowIndex});
  final int rowIndex;

  @override
  _StoryParaState createState() => _StoryParaState();
}

class _StoryParaState extends State<StoryPara> {
  List<Map<String, dynamic>> storyDatas = [];
  Map<String, dynamic> story = {};
  late int storyIndex;
  int paraIndex = 0;
  final TextEditingController _controller = TextEditingController();

  Future<void> fetchStoryText() async {
    final jsonString = await rootBundle.loadString('assets/OBSTextData.json');
    setState(() {
      storyDatas = json.decode(jsonString).cast<Map<String, dynamic>>();
      storyIndex = widget.rowIndex;
    });
  }

  @override
  void initState() {
    fetchStoryText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String text =
        storyDatas[storyIndex]['story'][paraIndex]['url'].split('/').last;
    return SingleChildScrollView(
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
              child: Text(
                storyDatas[storyIndex]['story'][paraIndex]['text'],
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              storyIndex != 0
                  ? IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 35,
                      onPressed: () {
                        setState(() {
                          storyIndex = storyIndex > 0 ? storyIndex - 1 : 0;
                          paraIndex = 0;
                        });
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.skip_previous),
                      iconSize: 35,
                      color: Color.fromARGB(66, 168, 163, 163).withOpacity(0.5),
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
                        _controller.text = story['story'][paraIndex]['text'];
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.arrow_left_sharp),
                      iconSize: 35,
                      color: Color.fromARGB(66, 168, 163, 163).withOpacity(0.5),
                      onPressed: () {},
                    ),
              Text(storyDatas[storyIndex]['storyId'].toString()),
              const Text(":"),
              Text(storyDatas[storyIndex]['story'][paraIndex]['id'].toString()),
              paraIndex != storyDatas[storyIndex]['story'].length - 1
                  ? IconButton(
                      icon: Icon(Icons.arrow_right_sharp),
                      iconSize: 35,
                      onPressed: () {
                        setState(() {
                          paraIndex = paraIndex + 1;
                        });
                        _controller.text = story?['story']?[paraIndex]['text'];
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
                      color: Color.fromARGB(66, 168, 163, 163).withOpacity(0.5),
                      onPressed: () {},
                    ),
            ],
          ),
          // AudioRecordContext(
          //   story_number: storyIndex,
          //   para_number: paraIndex,
          // )
        ],
      ),
    );
  }
}
