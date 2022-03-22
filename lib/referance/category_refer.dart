import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/utility/my_constant.dart';

Future<List<CategoryModel>> getCategoryByRestaurantId(String ccode) async {
  var list = List<CategoryModel>.empty(growable: true);
  String url =
      '${MyConstant().apipath}.${MyConstant().domain}/foodType.aspx?ccode=' +
          ccode +
          '&strCondtion=&strOrder=';
  await Dio().get(url).then((value) {
    if (value.toString() != 'null') {
      var result = json.decode(value.data);
      for (var map in result) {
        CategoryModel fModels = CategoryModel.fromJson(map);
        list.add(fModels);
      }
    }
  });
  print('*** list.length=${list.length}');
  return list;
}
