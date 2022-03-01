import 'package:btryakgin/model/foodtype_model.dart';

abstract class FoodView {
  Future<List<FoodTypeModel>> displayFoodList();
}
