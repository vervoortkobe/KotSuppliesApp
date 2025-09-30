import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kotsupplies/app/models/category.dart';
import 'package:kotsupplies/app/models/item.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/services/api_services.dart';

class ItemViewModel with ChangeNotifier {
  ListModel? _currentList;
  bool _isLoading = false;
  String? _errorMessage;

  ListModel? get currentList => _currentList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchListDetails(String listGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _currentList = await apiServices.lists.getListByGuid(listGuid);
    } catch (e) {
      _setErrorMessage('Failed to load list details: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Item?> createItem(
    String listGuid,
    String title, {
    int? amount,
    bool? checked,
    String? categoryGuid,
    File? image,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final newItem = await apiServices.items.createItem(
        listGuid,
        title,
        amount: amount,
        checked: checked,
        categoryGuid: categoryGuid,
        image: image,
      );
      await fetchListDetails(listGuid);
      return newItem;
    } catch (e) {
      _setErrorMessage('Failed to create item: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateItem(
    String listGuid,
    Item item, {
    String? title,
    int? amount,
    bool? checked,
    String? categoryGuid,
    File? image,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await apiServices.items.updateItem(
        listGuid,
        item.guid,
        title: title,
        amount: amount,
        checked: checked,
        categoryGuid: categoryGuid,
        image: image,
      );
      await fetchListDetails(listGuid);
    } catch (e) {
      _setErrorMessage('Failed to update item: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteItem(String listGuid, String itemGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await apiServices.items.deleteItem(listGuid, itemGuid);
      await fetchListDetails(listGuid);
    } catch (e) {
      _setErrorMessage('Failed to delete item: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Category?> createCategory(String listGuid, String name) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final newCategory = await apiServices.categories.createCategory(
        listGuid,
        name,
      );
      await fetchListDetails(listGuid);
      return newCategory;
    } catch (e) {
      _setErrorMessage('Failed to create category: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCategory(
    String listGuid,
    String categoryGuid,
    String name,
  ) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await apiServices.categories.updateCategory(listGuid, categoryGuid, name);
      await fetchListDetails(listGuid);
    } catch (e) {
      _setErrorMessage('Failed to update category: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(String listGuid, String categoryGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await apiServices.categories.deleteCategory(listGuid, categoryGuid);
      await fetchListDetails(listGuid);
    } catch (e) {
      _setErrorMessage('Failed to delete category: $e');
    } finally {
      _setLoading(false);
    }
  }
}
