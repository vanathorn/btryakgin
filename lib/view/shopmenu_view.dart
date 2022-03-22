import 'package:yakgin/model/shopmenu_model.dart';

abstract class ShopMenuView {
  Future<List<ShopMenuModel>> displayShopMenuList();
}
