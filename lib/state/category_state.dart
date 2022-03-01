import 'package:btryakgin/model/category_model.dart';
import 'package:get/get.dart';

class CategoryStateContoller extends GetxController {
  var selectCategory =
      CategoryModel(name: 'name', image: 'image', foods: []).obs;
}
