import 'package:flutter/material.dart';
import 'package:obs_demo/editortext.dart';
import 'package:obs_demo/screen/dashboard.dart';
import 'package:obs_demo/user_profile.dart';

class BottomNavigationBarExample extends StatefulWidget {
  final UserProfile userProfile;
  final int initialIndex;

  const BottomNavigationBarExample(this.userProfile,
      {Key? key, this.initialIndex = 1})
      : super(key: key);

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  void onUpdateTextAvailability(bool hasText) {
    // Implement your logic here based on text availability update
    print('Text availability updated: $hasText');
    // You can update state or perform any other actions based on this callback
  }

  List<Widget> _widgetOptions(BuildContext context, UserProfile userProfile) {
    return [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 150,
          ),
          SizedBox(height: 20),
          Text(
            '${userProfile.userName}',
            style: optionStyle,
          ),
          Text(
            '${userProfile.language ?? 'None'}',
            style: optionStyle,
          ),
        ],
      ),
      Dashboard(), // Replace this with your dashboard page widget
      EditorTextLayout(
        rowIndex: 0,
        onUpdateTextAvailability: onUpdateTextAvailability,
      ),
      // Text(
      //   'Audio',
      //   style: optionStyle,
      // ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Open',
            style: optionStyle,
          ),
          Text(
            'Export',
            style: optionStyle,
          ),
          Text(
            'Change Source Language',
            style: optionStyle,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BottomNavigationBarExample(widget.userProfile)),
              );
            },
            child: Text(
              'Close',
              style: optionStyle,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBS Translator'),
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions(context, widget.userProfile)
            .elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.audiotrack_outlined),
          //   label: 'Audio',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
