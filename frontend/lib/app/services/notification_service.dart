import 'package:kotsupplies/app/models/notification.dart';
import 'package:kotsupplies/app/services/base_api_service.dart';

class NotificationService extends BaseApiService {
  Future<List<AppNotification>> getNotificationsForUser(String userGuid) async {
    final response = await get('/notifications/$userGuid');
    return parseJsonListResponse(
      response,
      (json) => AppNotification.fromJson(json),
      'Failed to load notifications',
    );
  }
}
