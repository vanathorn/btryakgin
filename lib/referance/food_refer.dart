import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:btryakgin/model/foodtype_model.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<FoodTypeModel>> getFoodList() async {
  //String strConn = getStrConn() as String;
  SharedPreferences prefer = await SharedPreferences.getInstance();
  String ccode = prefer.getString('pccode');
  var foodTypeModels = List<FoodTypeModel>.empty(growable: true);
  String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
      'foodType.aspx?ccode=' +
      ccode +
      '&strCondtion=&strOrder=';

  await Dio().get(url).then((value) {
    if (value.toString() != 'null') {
      var result = json.decode(value.data);
      for (var map in result) {
        FoodTypeModel fModels = FoodTypeModel.fromJson(map);
        foodTypeModels.add(fModels);
        print('*** fModels.itemname=${fModels.itname}');
      }
      //await Dio().get(url).then((value) {
      //var result = json.decode(value.data);
      //result.forEach((key, value) {
      //listfoods.add(FoodTypeModel.fromJson(key));
      //});
    }
  });
  return foodTypeModels;
}
