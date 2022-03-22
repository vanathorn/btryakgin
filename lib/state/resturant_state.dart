import 'package:yakgin/model/shoprest_model.dart';
import 'package:get/get.dart';

class ResturantStateController extends GetxController {
  var selectedResturant = ShopRestModel(
      restaurantId: 'restaurantId', //new
      thainame: 'resturantname',
      address: 'resturantaddress',
      shoppict: 'resturantpict',
      account: [] //new
      ).obs;
}
