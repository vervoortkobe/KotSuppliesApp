import 'package:kotsupplies/app/models/item.dart';

class Category {
  final String guid;
  String name;
  final List<Item>? items;

  Category({required this.guid, required this.name, this.items});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      guid: json['guid'],
      name: json['name'],
      items: (json['items'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'name': name,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}
