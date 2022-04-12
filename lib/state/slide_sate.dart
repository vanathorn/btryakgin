import 'package:yakgin/model/product_model.dart';
import 'package:get/get.dart';

class SlideStateController extends GetxController {
  var selectedProductSlide =
    ProductModel(iid: 'iid', iname: 'iname', price: 'price', uname: 'uname').obs;
}
