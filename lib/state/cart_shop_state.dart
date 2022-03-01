//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/cart_model.dart';
import 'package:btryakgin/model/food_model.dart';
import 'package:btryakgin/model/shoprest_model.dart';
//*--  err-firebase import 'package:btryakgin/utility/my_constant.dart';
import 'package:get/get.dart';
//*--  err-firebase import 'package:get_storage/get_storage.dart';
import 'package:toast/toast.dart';

class CartShopStateController extends GetxController {
  var cartShop = List<ShopRestModel>.empty(growable: true).obs;
  /*--  err-firebase final box = GetStorage(); */
  getCartShop() => cartShop.any((e) => e.restaurantId != null);

  addToCartShop(BuildContext context, FoodModel foodModel, String restaurantId,
      String shopName) async {
    try {
      if (isExistsShop(restaurantId)) {
        //
      } else {
        ShopRestModel cModel = new ShopRestModel();
        cModel.restaurantId = restaurantId;
        cModel.thainame = shopName;
        cartShop.add(cModel);
      }

      /*--  err-firebase
      var jsonDBEncode = jsonEncode(cartShop);
      await box.write(MY_CART_KEY, jsonDBEncode);
      */

      cartShop.refresh(); //update
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

  isExistsShop(String restaurantId) =>
      cartShop.any((e) => e.restaurantId == restaurantId);

  clearCartShop(List<CartModel> cartItems, String restaurantId) {
    cartShop.remove(cartShop.firstWhere((e) => e.restaurantId == restaurantId));
    cartShop.refresh();
    //*--  err-firebase saveShopDatabase();
  }

  /*--  err-firebase
  saveShopDatabase() => box.write(MY_CART_KEY, jsonEncode(cartShop));  
  */

  /*
  final snackBar = SnackBar(
    content: Row( 
      children: [
        Icon(Icons.fastfood, color: Colors.white,),
        Expanded(child: Text(' กรุณาระบุจำนวน',))
      ],      
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: (Colors.black),
    action: SnackBarAction(
      label: 'dismiss',
      onPressed: () {
      },
    ),
  );
  */
}
