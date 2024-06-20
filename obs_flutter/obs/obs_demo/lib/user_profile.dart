import 'dart:convert';

class UserProfile {
  String userName;
  String? language;
  List<Map<String, dynamic>> stories;

  UserProfile({
    required this.userName,
    this.language,
    required this.stories,
  });

  // Serialize the UserProfile object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'language': language,
      'stories': stories,
    };
  }

  // Deserialize the JSON to UserProfile object
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userName: json['userName'],
      language: json['language'],
      stories: List<Map<String, dynamic>>.from(json['stories']),
    );
  }
}
