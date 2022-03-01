import 'package:btryakgin/model/category_model.dart';
import 'package:btryakgin/referance/category_refer.dart';
import 'package:btryakgin/view/category_view.dart';

class CategoryViewImp implements CategoryViewModel {
  @override
  Future<List<CategoryModel>> displayCategoryByRestaurantById(String ccode) {
    return getCategoryByRestaurantId(ccode);
  }
}
