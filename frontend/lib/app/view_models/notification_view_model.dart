import 'package:flutter/material.dart';
import 'package:kotsupplies/app/models/notification.dart';
import 'package:kotsupplies/app/services/api_service.dart';

class NotificationViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
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

  Future<void> fetchNotifications(String userGuid) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _notifications = await _apiService.getNotificationsForUser(userGuid);
    } catch (e) {
      _setErrorMessage('Failed to load notifications: $e');
    } finally {
      _setLoading(false);
    }
  }
}
