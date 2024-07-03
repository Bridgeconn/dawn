import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CreateUserPage.dart';
import 'screen/bottomNavi.dart';
import 'user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userName = prefs.getString('userName');
  String? language = prefs.getString('language');

  runApp(MyApp(
    userName: userName,
    language: language,
  ));
}

class MyApp extends StatelessWidget {
  final String? userName;
  final String? language;

  MyApp({this.userName, this.language});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: userName != null && language != null
          ? BottomNavigationBarExample(
              UserProfile(
                  userName: userName!, language: language!, stories: []),
            )
          : CreateUserPage(),
    );
  }
}
