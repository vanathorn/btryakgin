import 'package:yakgin/model/food_model.dart';
import 'package:get/get.dart';

class FoodListStateController extends GetxController {
  var selectedFood = FoodModel(
          ccode: 'ccode',
          description: 'description',
          id: 'id',
          name: 'name',
          image: 'image',
          price: 0,
          toppingB: [],
          toppingC: [],
          addon: [],
          quantity: 0,
          quantitySp: 0,
          favorite: 0)
      .obs;

  String selectedItem;
}
