import 'package:btryakgin/model/category_model.dart';

abstract class CategoryViewModel {
  Future<List<CategoryModel>> displayCategoryByRestaurantById(String ccode);
}
