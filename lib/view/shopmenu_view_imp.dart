import 'package:btryakgin/model/shopmenu_model.dart';
import 'package:btryakgin/referance/shopmenu_refer.dart';
import 'package:btryakgin/view/shopmenu_view.dart';

class ShopMenuViewImp implements ShopMenuView {
  @override
  Future<List<ShopMenuModel>> displayShopMenuList() {
    return getShopMenuList();
  }
}
