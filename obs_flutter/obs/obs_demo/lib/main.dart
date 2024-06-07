import 'package:flutter/material.dart';
import 'profile.dart';
import 'bottommenu.dart';



/// Flutter code sample for [BottomNavigationBar].

void main() => runApp(const BottomNavigationBarExampleApp());

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const BottomNavigationBarExample(),
      routes: {
        ProfileScreen.routeName: (context) => const ProfileScreen(),
      },
    );
  }
}
