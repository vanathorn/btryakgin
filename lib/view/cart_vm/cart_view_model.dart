import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/state/cart_state.dart';

abstract class CartViewModel {
  void updateQuantity(CartStateController controller, String restaurantId,
      int index, int value);
  void updateQuantitySp(CartStateController controller, String restaurantId,
      int index, int valueSp);
  void deleteCart(CartStateController controller, String restaurantId,
      CartModel cartItem, String strKey);
  void clearCart(CartStateController controller, String restaurantId,
      List<CartModel> cartItems);
  void getCartShop(CartStateController controller);
  void resetCart(CartStateController controller);
}
