// create_user_page.dart

import 'package:flutter/material.dart';
import 'package:obs_demo/screen/bottomNavi.dart';
import 'user_profile.dart'; // Import the UserProfile class

class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  String? _selectedLanguage;
  String? _userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('OBS Translator'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _userName = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedLanguage,
                items: <String>['English', 'Spanish', 'French']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                },
                hint: Text('Select a language'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _userName != null
                    ? () {
                        // Create a UserProfile instance
                        UserProfile userProfile =
                            UserProfile(_userName!, _selectedLanguage);
                        // Navigate to the bottom navigation bar example page with the user profile data
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BottomNavigationBarExample(userProfile),
                          ),
                        );
                      }
                    : null,
                child: Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
