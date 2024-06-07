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
    // Load JSON file from assets
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/OBSTextData.json');

    // Parse JSON
    List<Map<String, dynamic>> jsonData =
        json.decode(jsonString).cast<Map<String, dynamic>>();

    // Modify the `url` field to local asset paths
    for (var story in jsonData) {
      if (story.containsKey('story')) {
        for (var image in story['story']) {
          if (image.containsKey('url')) {
            // Replace with local asset path
            image['url'] = getLocalAssetPath(image['url']);
          }
        }
      }
    }

    return jsonData; // Return the modified data
  }

  // Function to map online URL to local asset path
  String getLocalAssetPath(String url) {
    // Extract filename from URL
    String fileName = url.split('/').last;
    // Return the new path in assets
    return 'assets/images/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadData(), // Reference to the async function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            var jsonData = snapshot.data!;
            isDoneList = List.generate(jsonData.length, (index) => false);

            return ListView.builder(
              itemCount: jsonData.length,
              itemBuilder: (context, rowIndex) {
                String title = truncateTitle(jsonData[rowIndex]['title']);
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                        flex: 4,
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
                              Icon(
                                Icons.create,
                                color: Colors.orange[400],
                              ),
                              // Text(
                              //   'Open',
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.grey[700],
                              //   ),
                              // ),
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
                              Icon(
                                Icons.remove_red_eye_sharp,
                                // color: Colors.green[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: isDoneList[rowIndex]
                            ? const Icon(
                                Icons.check_box,
                              )
                            : const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String truncateTitle(String title) {
    if (title.length > 20) {
      return title.substring(0, 18) + '...';
    } else {
      return title;
    }
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Border decoration
          borderRadius:
              BorderRadius.circular(8.0), // Optional: adds rounded corners
        ),
        padding: const EdgeInsets.all(8.0), // Padding around the Row
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.containsKey('url'))
              Expanded(
                flex: 1, // Adjust flex value as needed
                child: Image.asset(
                  item['url'], // Use the local asset path
                  width: 150,
                  height: 80,
                  fit: BoxFit.cover,
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
      ),
    );
  }
}
