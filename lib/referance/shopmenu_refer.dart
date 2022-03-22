import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yakgin/model/shopmenu_model.dart';
import 'package:yakgin/utility/my_constant.dart';

Future<List<ShopMenuModel>> getShopMenuList() async {
  //SharedPreferences prefer = await SharedPreferences.getInstance();
  //String strConn = prefer.getString('pstrconn');
  var shopMenuModels = List<ShopMenuModel>.empty(growable: true);
  String url = '${MyConstant().apipath}.${MyConstant().domain}/shopMenu.aspx';
  await Dio().get(url).then((value) {
    if (value.toString() != 'null') {
      var result = json.decode(value.data);
      for (var map in result) {
        ShopMenuModel sModels = ShopMenuModel.fromJson(map);
        shopMenuModels.add(sModels);
      }
    }
  });
  return shopMenuModels;
}
