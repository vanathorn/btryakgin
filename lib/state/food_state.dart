import 'package:btryakgin/model/foodtype_model.dart';
import 'package:get/get.dart';

class FoodStateController extends GetxController {
  var selectedFoodType = FoodTypeModel(
          gcatname: 'category',
          itname: 'typename',
          itdescription: 'typedetail',
          ftypepict: 'typepict')
      .obs;
}
