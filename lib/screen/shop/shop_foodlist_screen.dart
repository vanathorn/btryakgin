import 'dart:convert';
//vtr after upgrade import 'dart:ui';
import 'package:auto_animated/auto_animated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:yakgin/screen/shop/shop_fooddetail_screen.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/model/food_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/category_state.dart';
import 'package:yakgin/state/food_list_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';

class ShopFoodlistScreen extends StatefulWidget {
  final ShopRestModel restModel;
  final CategoryModel categoryModel;
  ShopFoodlistScreen({Key key, this.restModel, this.categoryModel})
      : super(key: key);
  @override
  _ShopFoodlistScreenState createState() => _ShopFoodlistScreenState();
}

class _ShopFoodlistScreenState extends State<ShopFoodlistScreen> {
  ShopRestModel restModel;
  CategoryModel categoryModel;
  String strConn, ccode, webPath;
  double screen;
  String strDistance;
  Location location = Location();
  final int startLogist = 30;
  int logistCost;
  CategoryStateContoller categoryStateContoller;
  List<FoodModel> foodModels = List<FoodModel>.empty(growable: true);
  String oldItem = '0';
  bool itemSame = false;
  FoodListStateController foodListStateController;
  final CartStateController cartStateController = Get.find();
  final MainStateController mainStateController = Get.find();
  bool loadding = true;

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    categoryModel = widget.categoryModel;
    ccode = restModel.ccode;
    strConn = restModel.strconn;
    webPath = restModel.webpath;
    categoryStateContoller = Get.find();
    categoryStateContoller.selectCategory.value = categoryModel;
    getFoodByType();
  }

  Future<Null> getFoodByType() async {
    String itid = '${categoryStateContoller.selectCategory.value.key}';
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodByType.aspx?ccode=$ccode&itid=$itid&strOrder=iName';

    //food_Addprice
    await Dio().get(url).then((value) {
      if (value.toString() != 'null' && value.toString() != '') {
        var result = json.decode(value.data);
        for (var map in result) {
          FoodModel fModels = FoodModel.fromJson(map);
          fModels.ccode = ccode; //for check what shop
          //*** addprice */
          fModels.addprice = 0;
          fModels.flagSp = (fModels.priceSp != 0) ? 'Y' : 'N';
          foodModels.add(fModels);
        }
      }
      setState(() {
        loadding = false;
        foodListStateController = Get.put(FoodListStateController());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBarWithOrderButton(
            title: 'สินค้าประเภท ${categoryModel.name}',
            subtitle: '',
            ttlordno: '0'),
        body: (loadding)
            ? MyStyle().showProgress()
            : (loadding == false && foodModels.length > 0)
                ? showFoodByType()
                : Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyStyle().txtTHRed(
                                'ไม่มีสินค้าประเภท ${categoryModel.name}'),
                          ],
                        ),
                      ],
                    ),
                  ));
  }

  Widget showFoodByType() {
    return Column(children: [
      Expanded(
          child: LiveList(
              showItemInterval: Duration(milliseconds: 150),
              showItemDuration: Duration(milliseconds: 350),
              reAnimateOnVisibility: true,
              scrollDirection: Axis.vertical,
              itemCount: foodModels.length,
              itemBuilder: animationItemBuilder((index) => InkWell(
                    onTap: () {
                      if (foodModels[index].id != oldItem) {
                        itemSame = false;
                        oldItem = foodModels[index].id;
                      } else {
                        itemSame = true;
                      }
                      foodListStateController.selectedFood.value =
                          foodModels[index];
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShopFoodDetailScreen(
                                  categoryModel: categoryModel,
                                  restModel: restModel,
                                  fModel: foodModels[index],
                                  itemSame: itemSame)));
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Stack(fit: StackFit.expand, children: [
                          Stack(
                            children: [
                              Container(
                                  width: screen,
                                  child: Image.network(
                                    'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${foodModels[index].image}',
                                    fit: BoxFit.cover,
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyStyle()
                                      .txtwhite14TH('กดรูปเพื่อแก้ไขสินค้า'),
                                ],
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                color: MyStyle().coloroverlay,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  color:
                                                      MyStyle().coloroverlay),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MyStyle().txtstyle(
                                                      '${foodModels[index].name}',
                                                      Colors.white,
                                                      13.0),
                                                  //SizedBox(width:5),
                                                  //MyStyle().txtwhite12TH('กดรูปเพื่อแก้ไขสินค้า'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                          width: 90.0,
                                                          child: showPrice(
                                                              foodModels[
                                                                  index])),
                                                      SizedBox(width: 15),
                                                      showRating(
                                                          foodModels[index]),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          )
                        ]),
                      ),
                    ),
                  ))))
    ]);
  }

  Row showRating(FoodModel fmodel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RatingBarIndicator(
            rating: fmodel.favorite,
            itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber[400],
                ),
            itemCount: 5,
            itemSize: 30.0,
            direction: Axis.horizontal),
      ],
    );
  }

  Row showPrice(FoodModel fmodel) {
    double price = double.parse('${fmodel.price}');
    var myFmt = NumberFormat('##0.##', 'en_US');
    var strPrice = myFmt.format(price);
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 5.0, bottom: 5.0),
        width: 50.0,
        height: 50,
        child: FloatingActionButton(
            backgroundColor: Colors.white, //wlightGreenAccent,
            child: MyStyle().txtstyle(strPrice, Colors.black, 16.0),
            onPressed: () => null),
      ),
      Container(
        margin: EdgeInsets.only(left: 2.0),
        width: 20.0,
        child: MyStyle().txtstyle('฿', Colors.white, 16.0),
      ),
    ]);
  }

  IconButton imageAddToCart(FoodModel fmodel) {
    return IconButton(
        onPressed: () {
          cartStateController.addToCart(context, fmodel,
              mainStateController.selectedRestaurant.value.restaurantId,
              topBid: '0',
              topCid: '0',
              addonid: '0',
              nameB: '',
              nameC: '',
              straddon: '');
        },
        icon: Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
        ));
  }

  /*
  final snackBar = SnackBar(
    content: Row( 
      children: [
        Icon(Icons.fastfood, color: Colors.white,),
        //SizedBox(width: MediaQuery.of(context).size.width),
        Expanded(child: Text(' กรุณาระบุจำนวน',))
      ],      
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: (Colors.black),
    action: SnackBarAction(
      label: 'dismiss',
      onPressed: () {
      },
    ),
  );
  */
}
