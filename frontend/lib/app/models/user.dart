import 'package:kotsupplies/app/models/list.dart';

class User {
  final String guid;
  final String username;
  final String? profileImageUrl;
  final List<ListModel>? accessibleLists;

  User({
    required this.guid,
    required this.username,
    this.profileImageUrl,
    this.accessibleLists,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var listsJson = json['accessibleLists'] as List?;
    List<ListModel>? lists;
    if (listsJson != null) {
      lists = listsJson.map((list) => ListModel.fromJson(list)).toList();
    }

    return User(
      guid: json['guid'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
      accessibleLists: lists,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'accessibleLists': accessibleLists?.map((e) => e.toJson()).toList(),
    };
  }
}
