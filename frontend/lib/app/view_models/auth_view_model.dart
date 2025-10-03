import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kotsupplies/app/models/user.dart';
import 'package:kotsupplies/app/services/api_services.dart';
import 'package:kotsupplies/app/services/storage_service.dart';

class AuthViewModel with ChangeNotifier {
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
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

  Future<void> checkLoginStatus() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _currentUser = await _storageService.getLoggedInUser();
    } catch (e) {
      _setErrorMessage('Failed to retrieve stored user data.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String username) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _currentUser = await apiServices.users.login(username);
      await _storageService.saveLoggedInUser(_currentUser!);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, {File? profileImage}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _currentUser = await apiServices.users.createUser(
        username,
        profileImage: profileImage,
      );
      await _storageService.saveLoggedInUser(_currentUser!);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String newUsername, {File? profileImage}) async {
    if (_currentUser == null) {
      _setErrorMessage('No user logged in.');
      return false;
    }
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _currentUser = await apiServices.users.updateUser(
        _currentUser!.guid,
        newUsername,
        profileImage: profileImage,
      );
      await _storageService.saveLoggedInUser(_currentUser!);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _storageService.clearLoggedInUser();
      _currentUser = null;
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
