import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:obs_demo/editortext.dart';
import 'package:path_provider/path_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<int> textStatusList = []; // 0: none, 1: some, 2: all

  Future<List<Map<String, dynamic>>> loadData() async {
    try {
      // Load JSON file from assets
      String jsonString =
          await rootBundle.loadString('assets/OBSTextData.json');

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

      // Initialize textStatusList with 0 values
      textStatusList = List.generate(jsonData.length, (index) => 0);

      // Check JSON file existence and completeness for each row
      for (int i = 0; i < jsonData.length; i++) {
        textStatusList[i] = await checkJsonFileStatus(i);
      }

      return jsonData; // Return the modified data
    } catch (e) {
      // Handle error if the file does not exist or other errors occur
      print('Error loading JSON file: $e');
      return []; // Return an empty list if there is an error
    }
  }

  // Function to map online URL to local asset path
  String getLocalAssetPath(String url) {
    // Extract filename from URL
    String fileName = url.split('/').last;
    // Return the new path in assets
    return 'assets/images/$fileName';
  }

  Future<int> checkJsonFileStatus(int rowIndex) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$rowIndex.json');
    if (await file.exists()) {
      final jsonData = await file.readAsString();
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      if (data.containsKey('story')) {
        int filledCount = 0;
        int totalCount = data['story'].length;
        for (var item in data['story']) {
          if (item.containsKey('text') && item['text'].isNotEmpty) {
            filledCount++;
          }
        }
        if (filledCount == 0) return 0; // none
        if (filledCount == totalCount) return 2; // all
        return 1; // some
      }
    }
    return 0; // none
  }

  void updateTextAvailability(int index, bool hasText) {
    setState(() {
      textStatusList[index] = hasText ? 2 : 0;
    });
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
                            // Navigate to editing page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditorTextLayout(
                                  rowIndex: rowIndex,
                                  onUpdateTextAvailability: (hasText) {
                                    updateTextAvailability(rowIndex, hasText);
                                  },
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
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: textStatusList[rowIndex] > 0
                              ? () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PreviewPage(
                                        rowIndex: rowIndex,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                textStatusList[rowIndex] > 0
                                    ? Icons.visibility
                                    : Icons
                                        .visibility_off, // Use visibility_off when textStatusList is 0
                                color: textStatusList[rowIndex] > 0
                                    ? Colors.orange
                                    : Colors.grey, // Adjust color accordingly
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Icon(
                          textStatusList[rowIndex] == 2
                              ? Icons.check_circle
                              : (textStatusList[rowIndex] == 1
                                  ? Icons.published_with_changes
                                  : Icons.check_circle),
                          color: textStatusList[rowIndex] > 0
                              ? (textStatusList[rowIndex] == 2
                                  ? Colors.green
                                  : Colors.orange)
                              : Colors.grey,
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
    if (title.length > 25) {
      return title.substring(0, 22) + '...';
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

class PreviewPage extends StatefulWidget {
  const PreviewPage({required this.rowIndex, super.key});

  final int rowIndex;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  Map<String, dynamic> story = {};

  @override
  void initState() {
    super.initState();
    readJsonToFile();
  }

  Future<void> readJsonToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${widget.rowIndex}.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final data = jsonDecode(jsonData) as Map<String, dynamic>;

        setState(() {
          story = data;
        });
      } else {
        setState(() {
          story = {'title': 'No Data', 'story': []};
        });
      }
    } catch (e) {
      print('Error reading JSON file: $e');
      setState(() {
        story = {'title': 'Error', 'story': []};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        // centerTitle: true,
      ),
      body: story.isEmpty || story['story'] == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  '${story['title']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: ListView(
                    children: story['story']
                        .map<Widget>((item) => StoryItem(item: item))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class StoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const StoryItem({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    String text = item['url'].split('/').last;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.containsKey('url'))
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/images/$text',
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
                  item.containsKey('text') ? '${item['text']}' : '',
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
