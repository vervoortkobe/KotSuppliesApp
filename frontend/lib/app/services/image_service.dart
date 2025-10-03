import 'package:kotsupplies/app/constants/app_constants.dart';

class ImageService {
  String getImageUrl(String imageGuid) {
    return '$kApiBaseUrl/images/$imageGuid';
  }
}
