import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';
import 'package:kotsupplies/app/models/user.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/models/item.dart';
import 'package:kotsupplies/app/models/category.dart';
import 'package:kotsupplies/app/models/notification.dart';

class ApiService {
  Future<http.Response> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return await http.post(
      Uri.parse('$kApiBaseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Future<http.Response> _putJson(String path, Map<String, dynamic> body) async {
    return await http.put(
      Uri.parse('$kApiBaseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Future<http.Response> _postMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String? fileFieldName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$kApiBaseUrl$path'));
    request.fields.addAll(fields);
    if (file != null && fileFieldName != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: MediaType('image', file.path.split('.').last),
        ),
      );
    }
    var response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<http.Response> _putMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String? fileFieldName,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$kApiBaseUrl$path'));
    request.fields.addAll(fields);
    if (file != null && fileFieldName != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: MediaType('image', file.path.split('.').last),
        ),
      );
    }
    var response = await request.send();
    return http.Response.fromStream(response);
  }

  // User Endpoints
  Future<User> createUser(String username, {File? profileImage}) async {
    final response = await _postMultipart(
      '/users/create',
      {'username': username},
      file: profileImage,
      fileFieldName: 'profileImage',
    );
    if (response.statusCode == 201) {
      // Created
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<User> updateUser(
    String userGuid,
    String? username, {
    File? profileImage,
  }) async {
    final fields = <String, String>{};
    if (username != null) fields['username'] = username;

    final response = await _putMultipart(
      '/users/$userGuid',
      fields,
      file: profileImage,
      fileFieldName: 'profileImage',
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<User> login(String username) async {
    final response = await _postJson('/users/login', {'username': username});
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$kApiBaseUrl/users'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<User>.from(l.map((model) => User.fromJson(model)));
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  Future<User> getUserByGuid(String guid) async {
    final response = await http.get(Uri.parse('$kApiBaseUrl/users/$guid'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  // Notification Endpoints
  Future<List<AppNotification>> getNotificationsForUser(String userGuid) async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/notifications/$userGuid'),
    );
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<AppNotification>.from(
        l.map((model) => AppNotification.fromJson(model)),
      );
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  // List Endpoints
  Future<ListModel> createList(
    String creatorGuid,
    String title,
    String type, {
    String? description,
  }) async {
    final body = {'creatorGuid': creatorGuid, 'title': title, 'type': type};
    if (description != null) body['description'] = description;
    final response = await _postJson('/lists', body);
    if (response.statusCode == 200) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create list: ${response.body}');
    }
  }

  Future<ListModel> getListByGuid(String listGuid) async {
    final response = await http.get(Uri.parse('$kApiBaseUrl/lists/$listGuid'));
    if (response.statusCode == 200) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load list: ${response.body}');
    }
  }

  Future<ListModel> updateList(
    String listGuid, {
    String? title,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    final response = await _putJson('/lists/$listGuid', body);
    if (response.statusCode == 200) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update list: ${response.body}');
    }
  }

  Future<void> deleteList(String listGuid) async {
    final response = await http.delete(
      Uri.parse('$kApiBaseUrl/lists/$listGuid'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete list: ${response.body}');
    }
  }

  Future<ListModel> addListUser(String listGuid, String userGuid) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/lists/$listGuid/add-user/$userGuid'),
    );
    if (response.statusCode == 201) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add user to list: ${response.body}');
    }
  }

  Future<ListModel> removeListUser(String listGuid, String userGuid) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/lists/$listGuid/remove-user/$userGuid'),
    );
    if (response.statusCode == 201) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to remove user from list: ${response.body}');
    }
  }

  // Item Endpoints
  Future<Item> createItem(
    String listGuid,
    String title, {
    int? amount,
    bool? checked,
    String? categoryGuid,
    File? image,
  }) async {
    final fields = <String, String>{'title': title};
    if (amount != null) fields['amount'] = amount.toString();
    if (checked != null) fields['checked'] = checked.toString();
    if (categoryGuid != null) fields['categoryGuid'] = categoryGuid;

    final response = await _postMultipart(
      '/items/$listGuid',
      fields,
      file: image,
      fileFieldName: 'image',
    );
    if (response.statusCode == 201) {
      return Item.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create item: ${response.body}');
    }
  }

  Future<Item> getItemByGuid(String listGuid, String itemGuid) async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/items/$listGuid/$itemGuid'),
    );
    if (response.statusCode == 200) {
      return Item.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load item: ${response.body}');
    }
  }

  Future<Item> updateItem(
    String listGuid,
    String itemGuid, {
    String? title,
    int? amount,
    bool? checked,
    String? categoryGuid,
    File? image,
  }) async {
    final fields = <String, String>{};
    if (title != null) fields['title'] = title;
    if (amount != null) fields['amount'] = amount.toString();
    if (checked != null) fields['checked'] = checked.toString();
    if (categoryGuid != null) fields['categoryGuid'] = categoryGuid;

    final response = await _putMultipart(
      '/items/$listGuid/$itemGuid',
      fields,
      file: image,
      fileFieldName: 'image',
    );
    if (response.statusCode == 200) {
      return Item.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update item: ${response.body}');
    }
  }

  Future<void> deleteItem(String listGuid, String itemGuid) async {
    final response = await http.delete(
      Uri.parse('$kApiBaseUrl/items/$listGuid/$itemGuid'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> bulkUpdateItems(
    String listGuid,
    List<Map<String, dynamic>> itemsData,
  ) async {
    final response = await _postJson('/items/$listGuid/bulk', {
      'items': itemsData,
    });
    if (response.statusCode == 201) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to bulk update items: ${response.body}');
    }
  }

  // Category Endpoints
  Future<Category> createCategory(String listGuid, String name) async {
    final response = await _postJson('/categories/$listGuid', {'name': name});
    if (response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<Category> getCategoryByGuid(
    String listGuid,
    String categoryGuid,
  ) async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/categories/$listGuid/$categoryGuid'),
    );
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category: ${response.body}');
    }
  }

  Future<Category> updateCategory(
    String listGuid,
    String categoryGuid,
    String name,
  ) async {
    final response = await _putJson('/categories/$listGuid/$categoryGuid', {
      'name': name,
    });
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(String listGuid, String categoryGuid) async {
    final response = await http.delete(
      Uri.parse('$kApiBaseUrl/categories/$listGuid/$categoryGuid'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }

  // Image Helper
  String getImageUrl(String imageGuid) {
    return '$kApiBaseUrl/images/$imageGuid';
  }
}
