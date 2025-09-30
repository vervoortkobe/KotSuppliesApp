import 'package:flutter/material.dart';
import 'package:kotsupplies/app/models/list.dart';
import 'package:kotsupplies/app/services/api_services.dart';

class ListViewModel with ChangeNotifier {
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
      final user = await apiServices.users.getUserByGuid(userGuid);
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
      final newList = await apiServices.lists.createList(
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
      final updatedList = await apiServices.lists.updateList(
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

  Future<void> deleteList(String listGuid, String userGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await apiServices.lists.deleteList(listGuid, userGuid);
      _userLists.removeWhere((list) => list.guid == listGuid);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to delete list: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> leaveList(String listGuid, String userGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await apiServices.lists.leaveList(listGuid, userGuid);
      _userLists.removeWhere((list) => list.guid == listGuid);
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to leave list: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<ListModel?> joinList(String shareCode, String userGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      ListModel listToJoin = await apiServices.lists.getListByShareCode(
        shareCode,
      );
      await apiServices.lists.addListUser(listToJoin.guid, userGuid);
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
