import 'package:yakgin/model/foodtype_model.dart';

abstract class FoodView {
  Future<List<FoodTypeModel>> displayFoodList();
}
