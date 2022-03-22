//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/model/food_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/state/cart_shop_state.dart';
import 'package:yakgin/state/main_state.dart';
//import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/widget/mysnackbar.dart';
import 'package:get/get.dart';
//*--  err-firebase import 'package:get_storage/get_storage.dart';
import 'package:toast/toast.dart';

class CartStateController extends GetxController {
  final MainStateController mainStateController = Get.find();
  final CartShopStateController shopController = Get.find();
  var cart = List<CartModel>.empty(growable: true).obs;
  /*--  err-firebase final box = GetStorage(); */

  //List<CartModel> getCart(String restaurantId) =>
  //cart.where((e) => e.restaurantId == restaurantId).toList();

  getCartShop() => shopController.cartShop.where((e) => e.restaurantId != '0');

  getCart(String restaurantId) =>
      cart.where((e) => e.restaurantId == restaurantId);

  getItemCart(String restaurantId) =>
      cart.where((e) => e.restaurantId == restaurantId);

  addToCart(BuildContext context, FoodModel foodModel, String restaurantId,
      {int quantity: 1,
      int quantitySp: 0,
      String topBid: '0',
      String topCid: '0',
      String addonid: '0',
      String nameB: '',
      String nameC: '',
      String straddon: '',
      bool warning: true}) async {
    String strKey = restaurantId +
        '_' +
        '${foodModel.id}' +
        '_' +
        topBid +
        '_' +
        topCid +
        '_' +
        addonid;
    try {
      var cartItem = CartModel(
          strKey: strKey,
          ccode: foodModel.ccode,
          id: foodModel.id,
          name: foodModel.name,
          description: foodModel.description,
          image: foodModel.image,
          price: foodModel.price + (foodModel.addprice), //*** addprice */
          priceSp: foodModel.priceSp + (foodModel.addprice), //*** addprice */
          toppingB: foodModel.toppingB,
          toppingC: foodModel.toppingC,
          addon: foodModel.addon,
          quantity: quantity,
          quantitySp: quantitySp,
          shopName: mainStateController.selectedRestaurant.value.thainame,
          restaurantId: restaurantId,
          topBid: topBid,
          topCid: topCid,
          addonid: addonid,
          nameB: nameB,
          nameC: nameC,
          straddon: straddon,
          flagSp: foodModel.flagSp,
          balqty: foodModel.balqty);
      if (isExistsShop(restaurantId)) {
        //print('******** isExistsShop  restaurantId=$restaurantId');
      } else {
        ShopRestModel cModel = new ShopRestModel();
        cModel.ccode = cartItem.ccode;
        cModel.restaurantId = restaurantId;
        cModel.thainame = mainStateController.selectedRestaurant.value.thainame;
        cModel.shoppict =
            (mainStateController.selectedRestaurant.value.shoppict != null)
                ? mainStateController.selectedRestaurant.value.shoppict
                : 'photo256.png';
        cModel.phone =
            (mainStateController.selectedRestaurant.value.phone != null)
                ? mainStateController.selectedRestaurant.value.phone
                : '';
        shopController.cartShop.add(cModel);
        //print('******** not isExistsShop   restaurantId=$restaurantId');
      }
      if (isExists(cartItem, restaurantId, strKey)) {
        //debugPrint('I. ****** exist cartItem restaurantId=$restaurantId  strKey=$strKey');
        var foodNeedToUpdate = cart.firstWhere(
            (e) => e.restaurantId == restaurantId && e.strKey == strKey);
        if (foodNeedToUpdate != null) {
          foodNeedToUpdate.quantity += (quantity);
          foodNeedToUpdate.quantitySp += (quantitySp);
        }
      } else {
        cartItem.shopName =
            mainStateController.selectedRestaurant.value.thainame;
        cartItem.strKey = strKey;
        cartItem.topBid = topBid;
        cartItem.topCid = topCid;
        cartItem.addonid = addonid;
        cartItem.nameB = nameB;
        cartItem.nameC = nameC;
        cartItem.straddon = straddon;
        if ((quantity + quantitySp) > 0) {
          cartItem.quantity = quantity;
          cartItem.quantitySp = quantitySp;
          cart.add(cartItem);
        } else {
          cartItem.quantity = 0;
          cartItem.quantitySp = 0;
        }
        cartItem.flagSp = foodModel.flagSp;
        cartItem.id = foodModel.id; //new  *** for qtyIncart
        cartItem.balqty = foodModel.balqty;
        //print('II. ****** not exist cartItem restaurantId=$restaurantId  strKey=$strKey');
      }
      /*--  err-firebase
      //after update info, we will save it to storage
      var jsonDBEncode = jsonEncode(cart);
      await box.write(MY_CART_KEY, jsonDBEncode);
      */

      /***********************/
      cart.refresh(); //update
      /***********************/
      //print('xxxxxx cartItem.id = ${cartItem.id}');
      if (quantity + quantitySp > 0) {
        MyUtil().showToast(context, 'เพิ่มลงตะกร้าเรียบร้อย');
      } else {
        if (warning) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              MySnackBar.showSnackBar("!กรุณาระบุจำนวน", Icons.fastfood),
            );
        }
      }
    } catch (e) {
      Toast.show(
        'เพิ่มลงตะกร้าไม่สำเร็จ',
        context,
        gravity: Toast.CENTER,
        backgroundColor: Colors.redAccent[700],
        textColor: Colors.white,
      );
    }
  }

  isExists(CartModel cartItem, String restaurantId, String strKey) =>
      cart.any((e) => e.restaurantId == restaurantId && e.strKey == strKey);
  //&& e.id == cartItem.id

  isExistsShop(String restaurantId) =>
      shopController.cartShop.any((e) => e.restaurantId == restaurantId);

  double sumCartModel1() {
    return cart.length == 0
        ? 0
        : (cart
                .map((e) => e.price * e.quantity)
                .reduce((value, element) => value + element) +
            cart
                .map((e) => e.priceSp * e.quantitySp)
                .reduce((value, element) => value + element));
  }

  //add-> double
  double sumCart(String restaurantId) => getCart(restaurantId).length == 0
      ? 0
      : getCart(restaurantId)
          .map((e) => ((e.price * e.quantity) + (e.priceSp * e.quantitySp)))
          .reduce((value, element) => value + element);

  int getQuantity(String restaurantId) {
    return getCart(restaurantId).length == 0
        ? 0
        : getCart(restaurantId)
            .map((e) => (e.quantity + e.quantitySp))
            .reduce((value, element) => value + element);
  }

  getCartByItemid(String restaurantId, String keyid) =>
      cart.where((e) => e.restaurantId == restaurantId && e.id == keyid);

  int qtyIncart(String restaurantId, String keyid) {
    int retval = 0;
    if (getCart(restaurantId).length == 0) {
      return 0;
    } else {
      if (isItemExists(restaurantId, keyid)) {
        retval = getCartByItemid(restaurantId, keyid)
            .map((e) => (e.quantity + e.quantitySp))
            .reduce((value, element) => value + element);
      } else {
        retval = 0;
      }
    }
    return retval;
  }

  isItemExists(String restaurantId, String strKey) =>
      cart.any((e) => e.restaurantId == restaurantId && e.id == strKey);

  double getShippingFee(double startLogist, double distance) {
    double logistcost;
    if (distance < 1.0) {
      logistcost = startLogist;
    } else {
      logistcost = startLogist +
          ((distance - 1).ceil() *
              10); //ceil=ปัดขึ้น  floor=ปัดทิ้งลง  round=ปัด 0.5
    }
    return logistcost;
  }

  getSubTotal(String restaurantId, double shippingFree) =>
      sumCart(restaurantId) + shippingFree;

  deleteItemCart(String restaurantId, CartModel cartItem, String strKey) {
    cart.remove(cart.firstWhere((e) =>
        e.restaurantId == restaurantId &&
        e.id == strKey &&
        e.id == cartItem.id));
    /*--  err-firebase
    saveDatabase();
    */
    //***** clear summary cartShop
    if (isRemainCart(restaurantId)) {
      //
    } else {
      shopController.cartShop.remove(shopController.cartShop
          .firstWhere((e) => e.restaurantId == restaurantId));
    }
  }

  deleteItemCartII(String restaurantId, CartModel cartItem, String strKey) {
    for (int index = cart.length - 1; index > -1; index--) {
      if (cart[index].restaurantId == restaurantId &&
          cart[index].id == strKey &&
          cart[index].id == cartItem.id) {
        cart.removeAt(index);
        break;
      }
    }

    /*--  err-firebase
    saveDatabase();
    */
    //***** clear summary cartShop
    if (isRemainCart(restaurantId)) {
      //
    } else {
      shopController.cartShop.remove(shopController.cartShop
          .firstWhere((e) => e.restaurantId == restaurantId));
    }
  }

  isRemainCart(String restaurantId) =>
      cart.any((e) => e.restaurantId == restaurantId);

  checkCartRemain(String restaurantId) {
    cart.firstWhere(
        (e) => e.restaurantId == restaurantId); //e.id == cartItem.id
  }

  notWorkclearCart(List<CartModel> cartItems, String restaurantId) {
    for (int index = cart.length; index > 0; index--) {
      var eModel = cart.firstWhere(
          (e) => e.restaurantId == restaurantId && e.id == cartItems[index].id);
      if (eModel != null) {
        cart.removeAt(index - 1);
      }
    }
    /*--  err-firebase
    saveDatabase();
    */
  }

  clearCart(List<CartModel> cartItems, String restaurantId) {
    if (cart.length > 0) {
      cartItems.forEach((cartItem) {
        cart.remove(cart.firstWhere((e) => e.restaurantId == restaurantId));
      });
      /*--  err-firebase
      saveDatabase();
      */

      //***** clear summary cartShop
      shopController.cartShop.remove(shopController.cartShop
          .firstWhere((e) => e.restaurantId == restaurantId));
    }
  }

  resetCart() {
    cart.clear();
    shopController.cartShop.clear();
  }

  /*--  err-firebase
  saveDatabase() => box.write(MY_CART_KEY, jsonEncode(cart));
  */

  //saveDatabaseCartShop() => box.write(MY_CART_KEY,
  //jsonEncode(shopController.cartShop));

  void mergeCart(
      List<CartModel> cartItems, String restaurantId, String strKey) {
    if (cart.length > 0) {
      cartItems.forEach((cartItem) {
        if (isExists(cartItem, restaurantId, strKey)) {
          var foodNeedToUpdate =
              getCartNeedUpdate(cartItem, restaurantId, strKey);
          if (foodNeedToUpdate != null) {
            foodNeedToUpdate.quantity += cartItem.quantity;
            foodNeedToUpdate.quantitySp += cartItem.quantitySp;
          }
        }
      });
    }
  }

  getCartNeedUpdate(CartModel cartItem, String restaurantId, String strKey) {
    cart.firstWhere((e) =>
        e.restaurantId == restaurantId &&
        e.strKey == strKey); //e.id == cartItem.id
  }

  /*
  showSnackBar(BuildContext context, String message) {
      ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()..showSnackBar(
        MySnackBar.showSnackBar(message, Icons.fastfood),
      );
  }
  
  final snackBar = SnackBar(
    content: Row( 
      children: [
        Icon(Icons.fastfood, color: Colors.white,),
        //SizedBox(width: MediaQuery.of(context).size.width),
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
