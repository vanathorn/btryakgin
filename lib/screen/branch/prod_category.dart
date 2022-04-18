import 'dart:convert';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakgin/model/account_model.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/screen/branch/prod_list.dart';
import 'package:yakgin/state/accbk_detail_state.dart';
import 'package:yakgin/state/accbk_list_state.dart';
import 'package:yakgin/state/category_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/view/category_view_imp.dart';
import 'package:yakgin/widget/commonwidget.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';

class ProdCategoryScreen extends StatefulWidget {
  ProdCategoryScreen({Key key}) : super(key: key);
  @override
  _ProdCategoryScreenState createState() => _ProdCategoryScreenState();
}

class _ProdCategoryScreenState extends State<ProdCategoryScreen> {
  final MainStateController mainStateController = Get.find();
  ShopRestModel restModel;
  String ccode;
  double screen;
  String strDistance;
  Location location = Location();
  final viewModel = CategoryViewImp();
  List<CategoryModel> categoriesList = List<CategoryModel>.empty(growable: true);
  CategoryStateContoller categoryStateContoller;

  AccbkListStateController listStateController;
  List<AccountModel> listAccbks = List<AccountModel>.empty(growable: true);
  AccbkDetailStateController foodController =
      Get.put(AccbkDetailStateController());

  @override
  void initState() {
    super.initState();    
    getPreferences();
    listStateController = Get.put(AccbkListStateController());
  }

  Future<Null> getPreferences() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      ccode = prefer.getString('pccode');
      getResturant();
      getCategory();
    });
  }

  Future<Null> getResturant() async {
    String url =
      '${MyConstant().apipath}.${MyConstant().domain}/getShopByType.aspx?ccode=$ccode';

    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {          
          setState(() {
            restModel = ShopRestModel.fromJson(map);
          });
        }
      }
    });
  }

  Future<Null> getCategory() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
      'foodType.aspx?ccode=$ccode&strCondtion=&strOrder=';

    categoriesList.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          CategoryModel fModels = CategoryModel.fromJson(map);
          categoriesList.add(fModels);
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
    listStateController = Get.find();
    listStateController.selectedAccount.value = restModel;
    return Scaffold(        
        body: 
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /*
              Expanded(
                flex: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    paymentButton(),
                    paymentButton(),
                  ],
                )
              ),*/
              SingleChildScrollView(
                child: (categoriesList != null && categoriesList.length > 0)
                      ? showCategory()                      
                      : MyStyle().showProgress()
              )
            ],
          ),
        );
  }

  /*
  Widget paymentButton() => FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: Icon(
          Icons.near_me_outlined,
          color: Colors.white,
        ),
        label: MyStyle().txtstyle('ชำระค่าสินค้า', Colors.white, 11),
        onPressed: () {
          //
        },
      );*/

  Widget showCategory() {
    return LiveGrid(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          showItemDuration: Duration(microseconds: 300),
          showItemInterval: Duration(microseconds: 300),
          reAnimateOnVisibility: true,
          scrollDirection: Axis.vertical,
          itemCount: categoriesList.length,
          
          gridDelegate: 
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1),
          itemBuilder: animationItemBuilder((index) => InkWell(
                onTap: () {
                  if (int.parse(categoriesList[index].ttlitem) > 0) {
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => ProdListScreen(
                            restModel: restModel,
                            categoryModel: categoriesList[index]));
                    Navigator.push(context, route);
                  } else {
                    Toast.show(
                      'ไม่มีสินค้า\r\nประเภท ${categoriesList[index].name}',
                      context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    );
                    //.then((value) => getCategory());<- มี error (index) : invalid range is emptu:0 - categoriesList.length,
                  }
                },
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(children: [
                    Container(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/foodtype/${categoriesList[index].image}',
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
                                MyStyle().txtstyle('${categoriesList[index].name}',
                              Colors.white, 16.0)
                              ])),
                    )])
              )),
        )
    );
  }
}
