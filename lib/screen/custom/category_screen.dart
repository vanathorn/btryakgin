import 'dart:convert';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/screen/custom/food_list_screen.dart';
//import 'package:yakgin/screen/custom/food_list_screen.dart';
import 'package:yakgin/state/category_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/view/category_view_imp.dart';
import 'package:yakgin/widget/commonwidget.dart';
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
    strConn = restModel.strconn;
    webPath = restModel.webpath;
    getCategory();
  }

  Future<Null> getCategory() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
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
                      '?????????????????????????????????\r\n?????????????????? ${categoryModels[index].name}',
                      context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    );
                    //.then((value) => getCategory());<- ?????? error (index) : invalid range is emptu:0 - categoryModels.length,
                  }
                },
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
                              16.0))
                    ])),
              )),
        ))
      ],
    );
  }
}
