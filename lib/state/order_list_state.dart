import 'package:yakgin/model/order_model.dart';
import 'package:get/get.dart';

class OrderListStateController extends GetxController {
  var selectedOrder = OrderModel(
    restaurantId: '',
    orderNo: '',
    orddtl: [],
  ).obs;
}
