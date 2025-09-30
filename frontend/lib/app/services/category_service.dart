import 'package:kotsupplies/app/models/category.dart';
import 'package:kotsupplies/app/services/base_api_service.dart';

/// Service for category-related API operations
class CategoryService extends BaseApiService {
  /// Creates a new category in the specified list
  Future<Category> createCategory(String listGuid, String name) async {
    final response = await postJson('/categories/$listGuid', {'name': name});
    return parseJsonResponse(
      response,
      (json) => Category.fromJson(json),
      'Failed to create category',
    );
  }

  /// Retrieves a category by its GUID
  Future<Category> getCategoryByGuid(
    String listGuid,
    String categoryGuid,
  ) async {
    final response = await get('/categories/$listGuid/$categoryGuid');
    return parseJsonResponse(
      response,
      (json) => Category.fromJson(json),
      'Failed to load category',
    );
  }

  /// Updates an existing category's name
  Future<Category> updateCategory(
    String listGuid,
    String categoryGuid,
    String name,
  ) async {
    final response = await putJson('/categories/$listGuid/$categoryGuid', {
      'name': name,
    });
    return parseJsonResponse(
      response,
      (json) => Category.fromJson(json),
      'Failed to update category',
    );
  }

  /// Deletes a category from a list
  Future<void> deleteCategory(String listGuid, String categoryGuid) async {
    final response = await delete('/categories/$listGuid/$categoryGuid');
    handleVoidResponse(response, 'Failed to delete category');
  }
}
