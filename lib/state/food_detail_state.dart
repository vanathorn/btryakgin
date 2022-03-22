import 'package:yakgin/model/addon_model.dart';
import 'package:yakgin/model/toppingb_model.dart';
import 'package:yakgin/model/toppingc_model.dart';
import 'package:get/get.dart';

class FoodDetailStateController extends GetxController {
  var quantity = 1.obs;
  var quantitySp = 0.obs;
  double priceB = 0;
  double priceC = 0;
  double priceD = 0;

  var selectToppingB = ToppingBModel(topid: 0, topname: 'topname').obs;
  var selectToppingC = ToppingCModel(topid: 0, topname: 'topname').obs;
  var selectAddon = List<AddonModel>.empty(growable: true).obs;

  var selectToppingBSp = ToppingBModel(topid: 0, topname: 'topname').obs;
  var selectToppingCSp = ToppingCModel(topid: 0, topname: 'topname').obs;
  var selectAddonSp = List<AddonModel>.empty(growable: true).obs;
}
