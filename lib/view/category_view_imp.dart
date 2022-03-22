import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/referance/category_refer.dart';
import 'package:yakgin/view/category_view.dart';

class CategoryViewImp implements CategoryViewModel {
  @override
  Future<List<CategoryModel>> displayCategoryByRestaurantById(String ccode) {
    return getCategoryByRestaurantId(ccode);
  }
}
