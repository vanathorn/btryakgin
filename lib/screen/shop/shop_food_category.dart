import 'dart:convert';
//vtr after upgrade import 'dart:ui';

import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/screen/shop/shop_foodlist_screen.dart';
import 'package:yakgin/state/category_state.dart';
import 'package:yakgin/state/resturant_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopFoodCategoryScreen extends StatefulWidget {
  @override
  _ShopFoodCategoryScreenState createState() => _ShopFoodCategoryScreenState();
}

class _ShopFoodCategoryScreenState extends State<ShopFoodCategoryScreen> {
  double screen;
  String ccode, loginName, strDistance, brcode;
  Location location = Location();
  bool loadding = true;
  bool havemenu = true;

  List<CategoryModel> categoryModels =
      List<CategoryModel>.empty(growable: true);
  CategoryStateContoller categoryStateContoller;

  ShopRestModel restModel;
  List<ShopRestModel> restModels = List<ShopRestModel>.empty(growable: true);
  final resturantStateController = Get.put(ResturantStateController());

  @override
  void initState() {
    super.initState();
    findShop();
  }

  Future<Null> findShop() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      ccode = prefer.getString('pccode');
      brcode = prefer.getString(MyConstant().keybrcode);
      getRestutant();
    });
    getCategory();
  }

  Future<Null> getRestutant() async {
    restModels.clear();
    String url =
        "${MyConstant().apipath}.${MyConstant().domain}/getResturant.aspx?" +
            "strCondtion=ccode='$ccode'&strOrder=";

    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopRestModel fModels = ShopRestModel.fromJson(map);
          setState(() {
            fModels.ccode = ccode;
            restModels.add(fModels);
          });
        }
      } else {
        setState(() {
          havemenu = false;
        });
      }
    });
  }

  Future<Null> getCategory() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodType.aspx?ccode=$ccode&strCondtion=&strOrder=';

    categoryModels.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null' &&
          value.toString().indexOf('????????????????????????????????????????????????') == -1) {
        var result = json.decode(value.data);
        for (var map in result) {
          CategoryModel fModels = CategoryModel.fromJson(map);
          categoryModels.add(fModels);
        }
        setState(() {
          categoryStateContoller = Get.put(CategoryStateContoller());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        body: (categoryModels != null && categoryModels.length > 0)
            ? showCategory()
            : MyStyle().showProgress());
  }

  Widget showCategory() {
    return Column(
      children: [
        Expanded(
            child: LiveGrid(
          showItemDuration: Duration(microseconds: 300),
          showItemInterval: Duration(microseconds: 300),
          reAnimateOnVisibility: true,
          scrollDirection: Axis.vertical,
          itemCount: categoryModels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1),
          itemBuilder: animationItemBuilder((index) => InkWell(
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => ShopFoodlistScreen(
                          restModel: restModels[0],
                          categoryModel: categoryModels[index], 
                          brcode: brcode));
                  Navigator.push(context, route);

                  //.then((value) => getCategory());<- ?????? error (index)
                  //: invalid range is emptu:0 - categoryModels.length,
                },
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(children: [
                    Container(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/foodtype/${categoryModels[index].image}',
                        fit: BoxFit.cover,
                      )
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: 45,
                          color: MyStyle().coloroverlay,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyStyle().txtTH18Light('${categoryModels[index].name}')
                              ])),
                    )])
              )
              /*
                *** Overlay ?????????????????????
                child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/foodtype/${categoryModels[index].image}',                               
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: MyStyle().coloroverlay,
                      ),
                      Center(
                          child: MyStyle().txtstyle(
                              '${categoryModels[index].name}',
                              Colors.white,
                              16.0)),
                    ]))*/
          )),
        ))
      ],
    );
  }
}
