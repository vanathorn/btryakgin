import 'package:yakgin/model/shopmenu_model.dart';
import 'package:yakgin/referance/shopmenu_refer.dart';
import 'package:yakgin/view/shopmenu_view.dart';

class ShopMenuViewImp implements ShopMenuView {
  @override
  Future<List<ShopMenuModel>> displayShopMenuList() {
    return getShopMenuList();
  }
}
