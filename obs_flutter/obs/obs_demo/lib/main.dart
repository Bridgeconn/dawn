import 'package:flutter/material.dart';
import 'package:obs_demo/CreateUserPage.dart';
import 'package:obs_demo/screen/bottomNavi.dart';
import 'package:obs_demo/screen/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: CreateUserPage() // Navigate to UserProfilePage directly
        // home: BottomNavigationBarExample(),
        // home: Dashboard(),
        );
  }
}
