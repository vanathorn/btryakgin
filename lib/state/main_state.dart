import 'package:btryakgin/model/shoprest_model.dart';
import 'package:get/get.dart';

class MainStateController extends GetxController {
  var selectedRestaurant = ShopRestModel(
          thainame: 'thainame',
          shoppict: 'shoppict',
          address: 'address',
          phone: 'phone',
          lat: 'lat',
          lng: 'lng',
          ccode: 'ccode',
          webpath: 'webpath',
          restaurantId: 'restaurantId',
          cntord: 0,
          cntnewm: 0)
      .obs;
}
