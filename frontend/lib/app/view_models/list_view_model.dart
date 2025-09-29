import 'package:flutter/material.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/services/api_service.dart';

class ListViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ListModel> _userLists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ListModel> get userLists => _userLists;
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

  Future<void> fetchUserLists(String userGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final user = await _apiService.getUserByGuid(userGuid);
      _userLists = user.accessibleLists ?? [];
    } catch (e) {
      _setErrorMessage('Failed to load lists: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<ListModel?> createList(
    String creatorGuid,
    String title,
    ListType type, {
    String? description,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final newList = await _apiService.createList(
        creatorGuid,
        title,
        type.toString().split('.').last,
        description: description,
      );

      await fetchUserLists(creatorGuid);

      return newList;
    } catch (e) {
      _setErrorMessage('Failed to create list: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateList(
    String listGuid, {
    String? title,
    String? description,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final updatedList = await _apiService.updateList(
        listGuid,
        title: title,
        description: description,
      );
      int index = _userLists.indexWhere((list) => list.guid == listGuid);
      if (index != -1) {
        _userLists[index] = updatedList;
      }
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to update list: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteList(String listGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _apiService.deleteList(listGuid);
      _userLists.removeWhere((list) => list.guid == listGuid);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to delete list: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<ListModel?> joinList(String shareCode, String userGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      ListModel listToJoin = await _apiService.getListByShareCode(shareCode);
      await _apiService.addListUser(listToJoin.guid, userGuid);
      await fetchUserLists(userGuid);
      return listToJoin; // Return the joined list for navigation
    } catch (e) {
      _setErrorMessage('Failed to join list: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
