// import 'dart:convert';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/cart_ord_model.dart';
import 'package:btryakgin/state/main_state.dart';
//*--  err-firebase import 'package:btryakgin/utility/my_constant.dart';
import 'package:get/get.dart';
//*--  err-firebase import 'package:get_storage/get_storage.dart';
import 'package:toast/toast.dart';

class OrderStateController extends GetxController {
  final MainStateController mainStateController = Get.find();
  var cartOrd = new List<CartOrderModel>.empty(growable: true).obs;
  /*--  err-firebase final boxOrd = GetStorage(); */

  getCartOrd(String restaurantId) {
    print('-----> ${cartOrd.toList().length} <---------');
    cartOrd.any((e) => e.restaurantId == restaurantId);
  }

  addToCartOrd(BuildContext context, String restaurantId, String shopName,
      int countorder) async {
    try {
      if (isExistsOrd(restaurantId)) {
        //
      } else {
        CartOrderModel cModel = new CartOrderModel();
        cModel.restaurantId = restaurantId;
        cModel.shopName =
            shopName; //mainStateController.selectedRestaurant.value.thainame;
        cModel.countord = countorder;
        cartOrd.add(cModel);
        /*--  err-firebase
        saveDatabase();  
        */
        for (int index = 0; index < cartOrd.toList().length; index++) {
          print(
              '******** index=$index  ${cartOrd.toList()[index].restaurantId} / ${cartOrd.toList()[index].countord}');
        }
        //print('>>>>>>> B cartOrd.add  restaurantId = $restaurantId   $shopName  $countorder');
      }
      try {
        /*--  err-firebase
        var jsonDBEncode = jsonEncode(cartOrd);
        await boxOrd.write(MY_ORDER_KEY, jsonDBEncode);
        */

      } catch (ex) {
        print('error ***** ${ex.toString()}');
      }
      cartOrd.refresh(); //update
      print(
          'xxxxxxxxx  jsonDBEncode ${cartOrd.toList().length}  ${cartOrd.toList()[0].restaurantId} xxxxxx');
    } catch (e) {
      Toast.show(
        'เพิ่มร้านค้าไม่สำเร็จ',
        context,
        gravity: Toast.CENTER,
        backgroundColor: Colors.redAccent[700],
        textColor: Colors.white,
      );
    }
  }

  isExistsOrd(String restaurantId) =>
      cartOrd.any((e) => e.restaurantId == restaurantId);

  int getCountOrder0(String restaurantId) {
    return getCartOrd(restaurantId)
        .map((e) => (e.countord))
        .reduce((value, element) => value + element);
  }

  /*--  err-firebase
  saveDatabase() => boxOrd.write(MY_ORDER_KEY, jsonEncode(cartOrd)); 
  */

}
