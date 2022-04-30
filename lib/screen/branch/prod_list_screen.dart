import 'dart:convert';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
import 'package:yakgin/widget/appbar_br_paycart.dart';
import 'package:yakgin/widget/commonwidget.dart';

class ProdListScreen extends StatefulWidget {
  final ShopRestModel restModel;
  final CategoryModel categoryModel;
  final String brloc;
  ProdListScreen({Key key, this.restModel, this.categoryModel, this.brloc})
      : super(key: key);
  @override
  _ProdListScreenState createState() => _ProdListScreenState();
}

class _ProdListScreenState extends State<ProdListScreen> {
  ShopRestModel restModel;
  CategoryModel categoryModel;
  String ccode, brloc;
  double screen, custlat, custlng;
  CategoryStateContoller categoryStateContoller;
  List<FoodModel> foodModels = List<FoodModel>.empty(growable: true);
  String oldItem = '0';
  bool itemSame = false;
  FoodListStateController foodListCtl;
  final CartStateController cartStateCtl = Get.find();
  final MainStateController mainStateCtl = Get.find();

  bool loadding = true;
  String clickItem = '0';

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    categoryModel = widget.categoryModel;
    ccode = restModel.ccode;
    brloc = widget.brloc;
    categoryStateContoller = Get.find();
    categoryStateContoller.selectCategory.value = categoryModel;
    getFoodByType();
  }

  Future<Null> getFoodByType() async {
    await getLocation();
    String itid = '${categoryStateContoller.selectCategory.value.key}';
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'branch/prodremain_brloc.aspx?ccode=$ccode&brloc=$brloc' +
        '&itid=$itid&strOrder=iName';

    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          FoodModel fModels = FoodModel.fromJson(map);
          fModels.ccode = ccode; //for check what shop
          //*** addprice */
          fModels.addprice = 0;
          fModels.flagSp = (fModels.priceSp != 0) ? 'Y' : 'N';
          //-------------------------------
          double balqty = fModels.balqty;
          int qtyincart = cartStateCtl.qtyIncart(
              mainStateCtl.selectedRestaurant.value.restaurantId, fModels.id);
          double remainQty = balqty - double.parse(qtyincart.toString());
          fModels.reqty = remainQty;
          //--------------------------------
          foodModels.add(fModels);
        }
      }
      setState(() {
        loadding = false;
        foodListCtl = Get.put(FoodListStateController());
      });
    });
  }

  Future<Null> recalRemain() async {
    for (int j = 0; j < foodModels.length; j++) {
      int qtyincart = cartStateCtl.qtyIncart(
          mainStateCtl.selectedRestaurant.value.restaurantId, foodModels[j].id);
      double balqty = foodModels[j].balqty;
      double remainQty = balqty - double.parse(qtyincart.toString());
      foodModels[j].reqty = remainQty;
    }
  }

  //automaticallyImplyLeading: false,
  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBarBrPayCart(
            title: ' ร้าน ${restModel.thainame}', subtitle: ''),
        body: (loadding == false && foodModels.length > 0) //
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
                      foodListCtl.selectedFood.value = foodModels[index];
                      /*
                      if (foodModels[index].reqty > 0) {
                        //ไม่ใช้ เนื่องจาก หลังจาก back กลับมา
                        // ยอดคงเหลือจะไม่ถูก refresh
         
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FoodDetailScreen(
                                    restModel: restModel,
                                    foodModel: foodModels[index],
                                    itemSame: itemSame)));
                      }
                      */
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: 
Stack(fit: StackFit.expand, children: [
  CachedNetworkImage(
    imageUrl: 'https://www.${MyConstant().domain}/' +
              '${MyConstant().imagepath}/$ccode/${foodModels[index].image}',
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
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(color: MyStyle().coloroverlay),
                    Row(
                      children: [
                        Container(
                          width: screen * .95,
                          child: SingleChildScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyStyle().txtTH18('${foodModels[index].name}',
                                              Colors.white),
                                showBalQty(foodModels[index])
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 90,
                              child: 
                                showPrice(foodModels[index])),
                                showRating(foodModels[index]),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Row(
                                    children: [
                                      MyStyle().txtstyle('-',Colors.white,20),
                                      imageSubtToCart(foodModels[index]),
                                    ],
                                  )),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3.0),
                                  child: imageAddToCart(foodModels[index]))
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

  Row showBalQty(FoodModel fmodel) {
    var qty = '';
    var myFmt = NumberFormat('##0.##', 'en_US');
    double remainQty = fmodel.reqty;
    qty = myFmt.format(remainQty);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MyStyle().txtTH18('เหลือ', Colors.white54),
        SizedBox(width: 5),
        MyStyle().txtstyle(qty, Color.fromARGB(255, 10, 214, 3), 18.0),
        SizedBox(width: 5),
        MyStyle().txtTH18(fmodel.uname, Colors.white54),
      ],
    );
  }

  IconButton imageAddToCart(FoodModel fmodel) {
    return IconButton(
        onPressed: () {
          if (fmodel.reqty > 0) {
            cartStateCtl.addToCart(context, fmodel,
                mainStateCtl.selectedRestaurant.value.restaurantId,
                topBid: '0',
                topCid: '0',
                addonid: '0',
                nameB: '',
                nameC: '',
                straddon: '');
            setState(() {
              clickItem = fmodel.id;
              fmodel.reqty -= 1;
            });
          }
        },
        icon: Icon(Icons.add_shopping_cart,
            color: Color.fromARGB(255, 10, 214, 3)));
  }

  IconButton imageSubtToCart(FoodModel fmodel) {
    return IconButton(
        onPressed: () {
          if (fmodel.reqty < fmodel.balqty) {
            cartStateCtl.addToCart(context, fmodel,
                mainStateCtl.selectedRestaurant.value.restaurantId,
                quantity: -1,
                topBid: '0',
                topCid: '0',
                addonid: '0',
                nameB: '',
                nameC: '',
                straddon: '',
                warning: false);
            setState(() {
              fmodel.reqty += 1;
            });
          }
        },
        icon: Icon(
          Icons.remove_shopping_cart,
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

  Future<Null> getLocation() async {
    var location = Location();
    var currentLocation;
    try {
      currentLocation = await location.getLocation();
      setState(() {
        custlat = currentLocation.latitude;
        custlng = currentLocation.longitude;
        //for test only
        //custlat = 14.1278686;
        //custlng = 100.6212333;
      });
    } catch (ex) {
      //
    }
  }
}
