import 'dart:io';
import 'package:kotsupplies/app/models/user.dart';
import 'package:kotsupplies/app/services/base_api_service.dart';

/// Service for user-related API operations
class UserService extends BaseApiService {
  /// Creates a new user with the given username and optional profile image
  Future<User> createUser(String username, {File? profileImage}) async {
    final response = await postMultipart(
      '/users/create',
      {'username': username},
      file: profileImage,
      fileFieldName: 'profileImage',
    );
    return parseJsonResponse(
      response,
      (json) => User.fromJson(json),
      'Failed to create user',
    );
  }

  /// Updates an existing user's information
  Future<User> updateUser(
    String userGuid,
    String? username, {
    File? profileImage,
  }) async {
    final fields = <String, String>{};
    if (username != null) fields['username'] = username;

    final response = await putMultipart(
      '/users/$userGuid',
      fields,
      file: profileImage,
      fileFieldName: 'profileImage',
    );
    return parseJsonResponse(
      response,
      (json) => User.fromJson(json),
      'Failed to update user',
    );
  }

  /// Logs in a user with the given username
  Future<User> login(String username) async {
    final response = await postJson('/users/login', {'username': username});
    return parseJsonResponse(
      response,
      (json) => User.fromJson(json),
      'Failed to login',
    );
  }

  /// Retrieves all users from the system
  Future<List<User>> getAllUsers() async {
    final response = await get('/users');
    return parseJsonListResponse(
      response,
      (json) => User.fromJson(json),
      'Failed to load users',
    );
  }

  /// Retrieves a specific user by their GUID
  Future<User> getUserByGuid(String guid) async {
    final response = await get('/users/$guid');
    return parseJsonResponse(
      response,
      (json) => User.fromJson(json),
      'Failed to load user',
    );
  }
}
