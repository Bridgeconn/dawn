import 'package:flutter/material.dart';
import 'profile.dart';

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  bool _isDoneClicked = false;  // State variable for tracking the "Done" section click

  static const TextStyle optionStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  // Method to handle "Done" section click
  void _onDoneClicked() {
    setState(() {
      _isDoneClicked = !_isDoneClicked;
    });
  }

  static List<Widget> _widgetOptions(BuildContext context, bool isDoneClicked, void Function() onDoneClicked) {
    return [
      Text(
        ' Profile',
        style: optionStyle,
      ),
      Text(
        'Home',
        style: optionStyle,
      ),
      Text(
        'Text',
        style: optionStyle,
      ),
      Text(
        'Audio',
        style: optionStyle,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          
          Text(
            'Open',
            style: optionStyle,
          ),
          // SizedBox(height: 10),
          Text(
            'Export',
            style: optionStyle,
          ),
          // SizedBox(height: 10),
          Text(
            'Change Source Language',
            style: optionStyle,
          ),
          // SizedBox(height: 10),
          Text(
            'Close',
            style: optionStyle,
          ),
          GestureDetector(
            onTap: onDoneClicked,
            child: Text(
              'Done',
              style: optionStyle.copyWith(
                color: isDoneClicked ? Colors.red : Colors.black,  // Change color based on state
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, ProfileScreen.routeName);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBS Translator'),
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions(context, _isDoneClicked, _onDoneClicked).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet),
            label: 'Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack_outlined),
            label: 'Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
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
