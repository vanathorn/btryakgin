import 'package:yakgin/model/category_model.dart';

abstract class CategoryViewModel {
  Future<List<CategoryModel>> displayCategoryByRestaurantById(String ccode);
}
