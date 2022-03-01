import 'dart:convert';
//vtr after upgrade  import 'dart:ui';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:btryakgin/model/category_model.dart';
import 'package:btryakgin/model/food_model.dart';
import 'package:btryakgin/model/shoprest_model.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/state/category_state.dart';
import 'package:btryakgin/state/food_list_state.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/widget/appbar_withcart.dart';
import 'package:btryakgin/widget/commonwidget.dart';
import 'food_detail_screen.dart';

class FoodListScreen extends StatefulWidget {
  final ShopRestModel restModel;
  final CategoryModel categoryModel;
  FoodListScreen({Key key, this.restModel, this.categoryModel})
      : super(key: key);
  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  ShopRestModel restModel;
  CategoryModel categoryModel;
  String strConn, ccode, webPath;
  double screen;
  //String strDistance;
  //Location location = Location();
  //final int startLogist = 30;
  //int logistCost;
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
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'foodByType.aspx?ccode=$ccode&itid=$itid&strOrder=iName';

    //food_Addprice
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
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
        appBar: AppBarWithCartButton(
            title: 'ร้าน ${restModel.thainame}', subtitle: ''),
        body: (loadding == false && foodModels.length > 0)
            ? showFoodByType()
            : Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (loadding == false && foodModels.length == 0)
                            ? MyStyle().txtTHRed(
                                'ไม่มีสินค้าประเภท ${categoryModel.name}')
                            : MyStyle().showProgress()
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
                              builder: (context) => FoodDetailScreen(
                                  restModel: restModel,
                                  foodModel: foodModels[index],
                                  itemSame: itemSame)));
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Stack(fit: StackFit.expand, children: [
                          CachedNetworkImage(
                            imageUrl: '${MyConstant().domain}/$webPath' +
                                '/${MyConstant().imagepath}/$ccode/${foodModels[index].image}',
                            fit: BoxFit.cover,
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
                                              MyStyle().txtstyle(
                                                  '${foodModels[index].name}',
                                                  Colors.white,
                                                  14.0),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                          width: 90,
                                                          child: showPrice(
                                                              foodModels[
                                                                  index])),
                                                      showRating(
                                                          foodModels[index]),
                                                      (foodModels[index]
                                                                      .topbid ==
                                                                  '' &&
                                                              foodModels[index]
                                                                      .topcid ==
                                                                  '')
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          40.0),
                                                              child: imageAddToCart(
                                                                  foodModels[
                                                                      index]),
                                                            )
                                                          : Container(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10.0),
                                                                child: MyStyle()
                                                                    .txtstyle(
                                                                        'สินค้ากดรูป',
                                                                        Colors
                                                                            .white,
                                                                        10),
                                                              ),
                                                            )
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
          itemSize: 20.0,
          direction: Axis.horizontal,
        ),
      ],
    );
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
