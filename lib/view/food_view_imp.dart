import 'package:btryakgin/model/foodtype_model.dart';
import 'package:btryakgin/referance/food_refer.dart';

import 'food_view.dart';

class FoodViewImp implements FoodView {
  @override
  Future<List<FoodTypeModel>> displayFoodList() {
    return getFoodList();
  }
}
