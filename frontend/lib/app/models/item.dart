import 'package:kotsupplies/app/models/category.dart';

class Item {
  final String guid;
  String title;
  int? amount;
  String? imageGuid;
  bool checked;
  Category? category;

  Item({
    required this.guid,
    required this.title,
    this.amount,
    this.imageGuid,
    this.checked = false,
    this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      guid: json['guid'],
      title: json['title'],
      amount: json['amount'],
      imageGuid: json['imageGuid'],
      checked: json['checked'] ?? false,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'title': title,
      'amount': amount,
      'imageGuid': imageGuid,
      'checked': checked,
      'category': category?.toJson(),
    };
  }
}
