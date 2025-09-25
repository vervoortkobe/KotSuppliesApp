import 'package:kotsupplies/app/models/category.dart';
import 'package:kotsupplies/app/models/item.dart';
import 'package:kotsupplies/app/models/user.dart';

enum ListType { imageCount, check }

class ListModel {
  final String guid;
  final String creatorGuid;
  final String title;
  final String? description;
  final String shareCode;
  final ListType type;
  final List<User>? users;
  final List<Category>? categories;
  final List<Item>? items;

  ListModel({
    required this.guid,
    required this.creatorGuid,
    required this.title,
    this.description,
    required this.shareCode,
    required this.type,
    this.users,
    this.categories,
    this.items,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      guid: json['guid'],
      creatorGuid: json['creatorGuid'],
      title: json['title'],
      description: json['description'],
      shareCode: json['shareCode'],
      type: ListType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      users: (json['users'] as List?)?.map((u) => User.fromJson(u)).toList(),
      categories: (json['categories'] as List?)
          ?.map((c) => Category.fromJson(c))
          .toList(),
      items: (json['items'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'creatorGuid': creatorGuid,
      'title': title,
      'description': description,
      'shareCode': shareCode,
      'type': type.toString().split('.').last,
      'users': users?.map((e) => e.toJson()).toList(),
      'categories': categories?.map((e) => e.toJson()).toList(),
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

  Category? get defaultCategory => categories?.firstWhere(
    (cat) => cat.name == 'uncategorized',
    orElse: () => categories!.first,
  );
}
