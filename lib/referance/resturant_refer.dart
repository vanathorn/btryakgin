//import 'dart:convert';
import 'package:yakgin/model/resturant_model.dart';
//import 'package:yakgin/strings/my_string.dart';

Future<List<ResturantModel>> getCategoryByRestaurantId(
    String restaurantId) async {
  var list = List<ResturantModel>.empty(growable: true);
  // var source = await FirebaseDatabase.instance
  //   .reference()
  //   .child(RESTAURANT_REF)
  //   .child(restaurantId)
  //   .child(CATEGORY_REF)
  //   .once();
  // Map<dynamic, dynamic> values = source.value;
  // values.forEach((key, value) {
  //   list.add(ResturantModel.fromJson(jsonDecode(jsonEncode(value))));
  // });

  return list;
}
