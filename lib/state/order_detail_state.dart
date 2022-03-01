import 'package:btryakgin/model/order_detail_model.dart';
import 'package:get/get.dart';

class OrderDetailStateController extends GetxController {
  var selectOrder = List<OrdDetailModel>.empty(growable: true).obs;
}
