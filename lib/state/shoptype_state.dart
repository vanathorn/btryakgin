import 'package:yakgin/model/shoptype_model.dart';
import 'package:get/get.dart';

class ShopTypeStateController extends GetxController {
  var selectedShopType = ShopTypeModel(
          stid: 'stid', stypename: 'stypename', stypepict: 'stypepict')
      .obs;
}
