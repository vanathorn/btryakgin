import 'dart:convert';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/category_model.dart';
import 'package:btryakgin/model/shoprest_model.dart';
import 'package:btryakgin/screen/custom/food_list_screen.dart';
import 'package:btryakgin/state/category_state.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/view/category_view_imp.dart';
import 'package:btryakgin/widget/commonwidget.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';

class CategoryScreen extends StatefulWidget {
  final ShopRestModel restModel;
  CategoryScreen({Key key, this.restModel}) : super(key: key);
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  ShopRestModel restModel;
  String strConn, ccode, webPath;
  double screen;
  String strDistance;
  Location location = Location();
  //final int startLogist = 30;
  //int logistCost;
  final viewModel = CategoryViewImp(); // CategoryViewImp();
  List<CategoryModel> categoryModels =
      List<CategoryModel>.empty(growable: true);
  CategoryStateContoller categoryStateContoller;

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    ccode = restModel.ccode;
    strConn = restModel
        .strconn; //'Data Source=10.1.1.100, 49728\\SQLEXPRESS; connection timeout = 150; Initial Catalog=dbFood4U; User ID=usrf4u; Password=F4uweb2612'; //restModel.strconn;
    webPath = restModel.webpath; //'Food4U'; //restModel.webpath;
    getCategory();
  }

  Future<Null> getCategory() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'foodType.aspx?ccode=$ccode&strCondtion=&strOrder=';

    categoryModels.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
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
        body: Container(
            child: (categoryModels != null && categoryModels.length > 0)
                ? showCategory()
                : MyStyle().showProgress()));
  }

  /*
  Widget showContent() {
    return Container(
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        categoryModels.length != 0 ? showCategory():MyStyle().showProgress()       
      ],
    ));
  }
  */

  Widget showCategory() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
                  if (int.parse(categoryModels[index].ttlitem) > 0) {
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => FoodListScreen(
                            restModel: restModel,
                            categoryModel: categoryModels[index]));
                    Navigator.push(context, route);
                  } else {
                    Toast.show(
                      'ไม่มีสินค้า\r\nประเภท ${categoryModels[index].name}',
                      context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    );
                    //.then((value) => getCategory());<- มี error (index) : invalid range is emptu:0 - categoryModels.length,
                  }
                },
                child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                        imageUrl:
                            '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$ccode/foodtype/${categoryModels[index].image}',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: MyStyle().coloroverlay,
                      ),
                      Center(
                          child: MyStyle().txtstyle(
                              '${categoryModels[index].name}',
                              Colors.white,
                              16.0))
                    ])),
              )),
        ))
      ],
    );
  }
}
