import 'package:yakgin/model/foodtype_model.dart';
import 'package:yakgin/referance/food_refer.dart';

import 'food_view.dart';

class FoodViewImp implements FoodView {
  @override
  Future<List<FoodTypeModel>> displayFoodList() {
    return getFoodList();
  }
}
