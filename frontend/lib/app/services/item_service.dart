import 'dart:convert';
import 'dart:io';
import 'package:kotsupplies/app/models/item.dart';
import 'package:kotsupplies/app/services/base_api_service.dart';

/// Service for item-related API operations
class ItemService extends BaseApiService {
  /// Creates a new item in the specified list
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

    final response = await postMultipart(
      '/items/$listGuid',
      fields,
      file: image,
      fileFieldName: 'image',
    );
    return parseJsonResponse(
      response,
      (json) => Item.fromJson(json),
      'Failed to create item',
    );
  }

  /// Retrieves an item by its GUID
  Future<Item> getItemByGuid(String listGuid, String itemGuid) async {
    final response = await get('/items/$listGuid/$itemGuid');
    return parseJsonResponse(
      response,
      (json) => Item.fromJson(json),
      'Failed to load item',
    );
  }

  /// Updates an existing item's information
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

    final response = await putMultipart(
      '/items/$listGuid/$itemGuid',
      fields,
      file: image,
      fileFieldName: 'image',
    );
    return parseJsonResponse(
      response,
      (json) => Item.fromJson(json),
      'Failed to update item',
    );
  }

  /// Deletes an item from a list
  Future<void> deleteItem(String listGuid, String itemGuid) async {
    final response = await delete('/items/$listGuid/$itemGuid');
    handleVoidResponse(response, 'Failed to delete item');
  }

  /// Updates multiple items in bulk
  Future<List<Map<String, dynamic>>> bulkUpdateItems(
    String listGuid,
    List<Map<String, dynamic>> itemsData,
  ) async {
    final response = await postJson('/items/$listGuid/bulk', {
      'items': itemsData,
    });

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to bulk update items: ${response.body}');
    }
  }
}
