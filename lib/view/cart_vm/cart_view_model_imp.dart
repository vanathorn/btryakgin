import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/view/cart_vm/cart_view_model.dart';
import 'package:get/get.dart';

class CartViewModelImp implements CartViewModel {
  final MainStateController mainStateController = Get.find();

  void updateCart(CartStateController controller, String restaurantId,
      int index, int value) {
    controller.cart = controller.getCart(restaurantId);
    controller.cart[index].quantity = value;
    controller.cart.refresh();
    /*--  err-firebase controller.saveDatabase(); */
  }

  void updateQuantity(CartStateController controller, String restaurantId,
      int index, int value) {
    var cart =
        controller.cart.where((e) => e.restaurantId == restaurantId).toList();
    cart[index].quantity = value;
    controller.cart.refresh();
    /*--  err-firebase controller.saveDatabase(); */
  }

  void updateQuantitySp(CartStateController controller, String restaurantId,
      int index, int valueSp) {
    var cart =
        controller.cart.where((e) => e.restaurantId == restaurantId).toList();
    cart[index].quantitySp = valueSp;
    controller.cart.refresh();
    /*--  err-firebase controller.saveDatabase(); */
  }

  void deleteCart(CartStateController controller, String restaurantId,
      CartModel cartItem, String strKey) {
    controller.deleteItemCart(restaurantId, cartItem, strKey);
    controller.cart.refresh();
    /*--  err-firebase controller.saveDatabase(); */
  }

  void clearCart(CartStateController controller, String restaurantId,
      List<CartModel> cartItems) {
    controller.clearCart(cartItems, restaurantId);
    controller.cart.refresh();
    /*--  err-firebase controller.saveDatabase(); */
  }

  void getCartShop(CartStateController controller) {
    controller.getCartShop();
  }

  void resetCart(CartStateController controller) {
    controller.resetCart();
  }
}
