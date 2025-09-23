import 'package:kotsupplies/app/models/list.dart';

class AppNotification {
  final int id;
  final String message;
  final DateTime createdAt;
  final ListModel? list;

  AppNotification({
    required this.id,
    required this.message,
    required this.createdAt,
    this.list,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      list: json['list'] != null ? ListModel.fromJson(json['list']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'list': list?.toJson(),
    };
  }
}
