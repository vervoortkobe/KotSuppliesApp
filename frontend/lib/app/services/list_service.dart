import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/services/base_api_service.dart';

/// Service for list-related API operations
class ListService extends BaseApiService {
  /// Creates a new list with the given parameters
  Future<ListModel> createList(
    String creatorGuid,
    String title,
    String type, {
    String? description,
  }) async {
    final body = {'creatorGuid': creatorGuid, 'title': title, 'type': type};
    if (description != null) body['description'] = description;

    final response = await postJson('/lists', body);
    return parseJsonResponse(
      response,
      (json) => ListModel.fromJson(json),
      'Failed to create list',
    );
  }

  /// Retrieves a list by its GUID
  Future<ListModel> getListByGuid(String listGuid) async {
    final response = await get('/lists/$listGuid');
    return parseJsonResponse(
      response,
      (json) => ListModel.fromJson(json),
      'Failed to load list',
    );
  }

  /// Retrieves a list by its share code
  Future<ListModel> getListByShareCode(String shareCode) async {
    final response = await get('/lists/share/$shareCode');
    return parseJsonResponse(
      response,
      (json) => ListModel.fromJson(json),
      'Failed to load list by share code',
    );
  }

  /// Updates an existing list's information
  Future<ListModel> updateList(
    String listGuid, {
    String? title,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;

    final response = await putJson('/lists/$listGuid', body);
    return parseJsonResponse(
      response,
      (json) => ListModel.fromJson(json),
      'Failed to update list',
    );
  }

  /// Deletes a list (only allowed for list creators)
  Future<void> deleteList(String listGuid, String userGuid) async {
    final response = await delete('/lists/$listGuid/$userGuid');
    handleVoidResponse(response, 'Failed to delete list');
  }

  /// Removes a user from a list (for non-creators)
  Future<void> leaveList(String listGuid, String userGuid) async {
    final response = await postJson('/lists/$listGuid/leave/$userGuid', {});
    handleVoidResponse(response, 'Failed to leave list');
  }

  /// Adds a user to a list
  Future<ListModel> addListUser(String listGuid, String userGuid) async {
    final response = await postJson('/lists/$listGuid/add-user/$userGuid', {});
    return parseJsonResponse(
      response,
      (json) => ListModel.fromJson(json),
      'Failed to add user to list',
    );
  }

  /// Removes a user from a list
  Future<ListModel> removeListUser(String listGuid, String userGuid) async {
    final response = await postJson(
      '/lists/$listGuid/remove-user/$userGuid',
      {},
    );
    return parseJsonResponse(
      response,
      (json) => ListModel.fromJson(json),
      'Failed to remove user from list',
    );
  }
}
