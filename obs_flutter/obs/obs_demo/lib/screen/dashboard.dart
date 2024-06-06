import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:obs_demo/editortext.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isDone = false;
  List<bool> isDoneList = [];

  Future<List<Map<String, dynamic>>> loadData() async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/OBSTextData.json');
    return json.decode(jsonString).cast<Map<String, dynamic>>();
  }

  String truncateTitle(String title) {
    if (title.length > 20) {
      return title.substring(0, 18) + '...';
    } else {
      return title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('OBS Dashboard'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var jsonData = snapshot.data!;
          isDoneList = List.generate(jsonData.length,
              (index) => false); // Ensure the isDoneList is correctly sized
          return ListView.builder(
            itemCount: jsonData.length, // Dynamically set the item count
            itemBuilder: (context, rowIndex) {
              String title = truncateTitle(jsonData[rowIndex]['title']);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex:
                          2, // Increase this flex value to allocate more space
                      child: GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditorTextLayout(
                                rowIndex: rowIndex,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewPage(
                                rowIndex: rowIndex,
                                previewData: jsonData[rowIndex],
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        isDoneList[rowIndex] ? 'Done' : 'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StoryPage extends StatelessWidget {
  final int rowIndex;
  final String title;

  StoryPage({required this.rowIndex, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Story for Row ${rowIndex + 1}'),
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  final int rowIndex;
  final Map<String, dynamic> previewData;

  const PreviewPage({
    required this.rowIndex,
    required this.previewData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> storyList = previewData['story'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              '${previewData['title']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: ListView(
                children: storyList
                    .map<Widget>((item) => StoryItem(item: item))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const StoryItem({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.containsKey('url'))
            Expanded(
              flex: 1, // Adjust flex value as needed
              child: Image.network(
                item['url'],
                width: 150,
                height: 80,
                loadingBuilder: (context, widget, event) {
                  if (event == null) {
                    return widget;
                  }
                  return CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return Text('Failed to load image');
                },
              ),
            ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                '${item['text']}',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
