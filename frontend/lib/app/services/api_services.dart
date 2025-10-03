import 'package:kotsupplies/app/services/user_service.dart';
import 'package:kotsupplies/app/services/list_service.dart';
import 'package:kotsupplies/app/services/item_service.dart';
import 'package:kotsupplies/app/services/category_service.dart';
import 'package:kotsupplies/app/services/notification_service.dart';
import 'package:kotsupplies/app/services/image_service.dart';

class ApiServices {
  static final ApiServices _instance = ApiServices._internal();
  factory ApiServices() => _instance;
  ApiServices._internal();

  // Service instances
  final UserService _userService = UserService();
  final ListService _listService = ListService();
  final ItemService _itemService = ItemService();
  final CategoryService _categoryService = CategoryService();
  final NotificationService _notificationService = NotificationService();
  final ImageService _imageService = ImageService();

  // Service getters
  UserService get users => _userService;
  ListService get lists => _listService;
  ItemService get items => _itemService;
  CategoryService get categories => _categoryService;
  NotificationService get notifications => _notificationService;
  ImageService get images => _imageService;
}

// Global instance
final apiServices = ApiServices();
