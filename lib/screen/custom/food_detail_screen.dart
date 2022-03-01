import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
//vtr after upgrade  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elegant_number_button/flutter_elegant_number_button.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:btryakgin/model/mess_model.dart';
import 'package:btryakgin/model/topping_model.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:btryakgin/model/addon_model.dart';
import 'package:btryakgin/model/food_model.dart';
import 'package:btryakgin/model/shoprest_model.dart';
import 'package:btryakgin/model/toppingb_model.dart';
import 'package:btryakgin/model/toppingc_model.dart';
import 'package:btryakgin/state/food_detail_state.dart';
import 'package:btryakgin/state/food_list_state.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:toast/toast.dart';

class FoodDetailScreen extends StatefulWidget {
  final ShopRestModel restModel;
  final FoodModel foodModel;
  final itemSame;
  FoodDetailScreen({Key key, this.restModel, this.foodModel, this.itemSame})
      : super(key: key);
  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  ShopRestModel restModel;
  FoodModel foodModel;
  String strConn, ccode, webPath;
  double screen, screenH, favorScore;
  String strDistance;
  FoodListStateController foodListStateController;
  //***** List<FoodModel> listFoodModels = List<FoodModel>.empty(growable: true);

  List<ToppingBModel> toppingB = List<ToppingBModel>.empty(growable: true);
  List<ToppingCModel> toppingC = List<ToppingCModel>.empty(growable: true);
  List<AddonModel> addons = List<AddonModel>.empty(growable: true);

  FoodDetailStateController foodController =
      Get.put(FoodDetailStateController());
  final MainStateController mainStateController = Get.find();
  //@override
  // ignore: override_on_non_overriding_member
  //Duration get transitionDuration => const Duration(milliseconds: 1000);

  var isExpanB = false;
  var isExpanC = false;
  var isExpanD = false;

  @override
  void initState() {
    super.initState();

    // foodController = FoodDetailStateController(
    //   duration: Duration(seconds: 1),
    //   vsync: this,
    // );

    restModel = widget.restModel;
    foodModel = widget.foodModel;
    ccode = restModel.ccode;
    strConn = restModel.strconn;
    webPath = restModel.webpath;
    favorScore = foodModel.favorite;

    foodListStateController = Get.find();
    foodListStateController.selectedFood.value = foodModel;

    getSelection();

    foodController.selectToppingB.value = null;
    foodController.selectToppingC.value = null;
    foodController.selectAddon.clear();
    foodController.quantity.value = 1;
    foodController.quantitySp.value = 0;
    //*** addprice
    foodController.priceB = 0;
    foodController.priceC = 0;
    foodController.priceD = 0;
  }

  Future<Null> getSelection() async {
    String iid = '${foodListStateController.selectedFood.value.id}';
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'getTopping_Price.aspx?ccode=$ccode&iid=$iid';

    toppingB.clear();
    toppingC.clear();
    addons.clear();

    await dio.Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ToppingModel tModels = ToppingModel.fromJson(map);
          String strTitle = tModels.topptitle.toString();
          String strToppB = tModels.listB.toString();
          var arrB = strToppB.split("*");
          for (int i = 0; i < arrB.length; i++) {
            var tmp = arrB[i].split("|");
            toppingB.add(ToppingBModel(
                toptitle: strTitle.split('*')[1],
                topid: int.parse(tmp[0]),
                topname: tmp[1],
                addprice: double.parse(tmp[2])));
          }
          //
          if (tModels.listC != null && tModels.listC != '') {
            String strToppC = tModels.listC.toString();
            var arrC = strToppC.split("*");
            for (int i = 0; i < arrC.length; i++) {
              var tmp = arrC[i].split("|");
              toppingC.add(ToppingCModel(
                  toptitle: strTitle.split('*')[2],
                  topid: int.parse(tmp[0]),
                  topname: tmp[1],
                  addprice: double.parse(tmp[2])));
            }
          }
          //
          if (tModels.listD != null && tModels.listD != '') {
            String strToppD = tModels.listD.toString();
            var arrD = strToppD.split("*");
            for (int i = 0; i < arrD.length; i++) {
              var tmp = arrD[i].split("|");
              addons.add(AddonModel(
                  optid: int.parse(tmp[0]),
                  optname: tmp[1],
                  toptitle: strTitle.split('*')[3],
                  addprice: double.parse(tmp[2])));
            }
          }
          //
          setState(() {
            foodModel.toppingB = toppingB.toList();
            foodModel.toppingC = toppingC.toList();
            foodModel.addon = addons.toList();
            foodModel.addprice = 0;
            foodModel.favorite = double.parse(tModels.favorite);
            favorScore = double.parse(tModels.favorite);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //timeDilation = 2.5;
    screen = MediaQuery.of(context).size.width;
    screenH = MediaQuery.of(context).size.height;

    return SafeArea(
        /* ** ไม่แสดงภาพ ใน Detail 
        appBar: AppBarWithOrderButton(
        title: 'ร้าน ${restModel.thainame}',subtitle: '', ttlordno: '0'),
       */

        child: Scaffold(
            body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxisScrolled) {
        return [
          /* *** ไม่แสดงภาพ ใน Detail *** --------------------------------*/
          //AppBarWithOrderButton(
          //title: 'ร้าน ${restModel.thainame}',subtitle: '', ttlordno: '0'),
          /* ---------------------------------------------------------   */
          SliverAppBar(
            /*
              floating: true,
              expandedHeight: screenH/3.0,
              flexibleSpace: FlexibleSpaceBar(                
                background: CachedNetworkImage(
                  imageUrl:
                    '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$ccode/${foodModel.image}',
                    fit: BoxFit.cover, 
                ),
              ),
              */
            bottom: PreferredSize(
                preferredSize: Size.square(screenH / 3.0),
                child: foodDetailImageWidget()),
            backgroundColor: Colors.grey[50],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            forceElevated: true,
            floating: true,
            pinned: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ];
      },
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 0),
          child: Column(
            children: [
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyStyle().txtstyle(
                              '${foodModel.name}', Colors.black, 16.0),
                          Container(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyStyle().txtblack14TH('เลือกคะแนน'),
                              showRating(),
                              SizedBox(width: 50)
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //ToppingB, ToppingC / addon
              foodModel.toppingB.length > 0
                  ? showToppingB(foodModel.toppingB[0].toptitle,
                      foodModel.price > 0 ? '+' : '')
                  : Container(),
              foodModel.toppingC.length > 0
                  ? showToppingC(foodModel.toppingC[0].toptitle)
                  : Container(),
              foodModel.addon.length > 0
                  ? showAddon(foodModel.addon[0].toptitle)
                  : Container(),

              //order  normal qty and special qty
              SizedBox(height: 5.0),
              normalPrice(),
              foodModel.priceSp > 0 ? specialPrice() : Container(),
            ],
          ),
        ),
      ),
    )));
  }

  Card showToppingB(toppingTitle, sign) {
    //final CartStateController cartStateController = Get.find(); //*** addprice */
    return Card(
      elevation: 5,
      child: Container(
          padding: EdgeInsets.all(0.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Obx(() => ExpansionTile(
                  onExpansionChanged: _onExpanBChanged,
                  trailing: Switch(
                    value: isExpanB,
                    onChanged: (_) {},
                  ),
                  title: MyStyle()
                      .txtstyle(toppingTitle, Colors.redAccent[700], 14.0),
                  children: foodModel.toppingB
                      .map(
                        (e) => //SingleChildScrollView(
                            RadioListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyStyle().txtTH20Dark(e.topname),
                              (e.addprice > 0)
                                  ? Text(
                                      '$sign ' +
                                          MyCalculate().fmtNumber(e.addprice),
                                      style: TextStyle(
                                          color: Colors.blueAccent[700]))
                                  : Text(
                                      (e.addprice != 0)
                                          ? MyCalculate().fmtNumber(e.addprice)
                                          : '',
                                      style: TextStyle(
                                          color: Colors.redAccent[700]))
                            ],
                          ),
                          value: e,
                          groupValue: foodController.selectToppingB.value,
                          onChanged: (value) {
                            setState(() {
                              foodController.selectToppingB.value = value;
                              //*** addprice */
                              foodController.priceB = e.addprice;
                              double ttladd = (foodController.priceB +
                                  foodController.priceC +
                                  foodController.priceD);
                              foodModel.addprice = ttladd;
                              //
                            });
                          },
                        ),
                      )
                      .toList()))
            ],
          )),
    );
  }

  Card showToppingC(toppingTitle) {
    return Card(
      elevation: 5,
      child: Container(
          padding: EdgeInsets.all(0.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Obx(() => ExpansionTile(
                  onExpansionChanged: _onExpanCChanged,
                  trailing: Switch(
                    value: isExpanC,
                    onChanged: (_) {},
                  ),
                  title: MyStyle()
                      .txtstyle(toppingTitle, Colors.redAccent[700], 14.0),
                  children: foodModel.toppingC
                      .map((e) => RadioListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyStyle().txtTH20Dark(e.topname),
                                (e.addprice > 0)
                                    ? Text(
                                        '+ ' +
                                            MyCalculate().fmtNumber(e.addprice),
                                        style: TextStyle(
                                            color: Colors.blueAccent[700]))
                                    : Text(
                                        (e.addprice != 0)
                                            ? MyCalculate()
                                                .fmtNumber(e.addprice)
                                            : '',
                                        style: TextStyle(
                                          color: Colors.redAccent[700],
                                        ))
                              ],
                            ),
                            value: e,
                            groupValue: foodController.selectToppingC.value,
                            onChanged: (value) {
                              setState(() {
                                foodController.selectToppingC.value = value;
                                //*** addprice */
                                foodController.priceC = e.addprice;
                                double ttladd = (foodController.priceB +
                                    foodController.priceC +
                                    foodController.priceD);
                                foodModel.addprice = ttladd;
                                //
                              });
                            },
                          ))
                      .toList()))
            ],
          )),
    );
  }

  Card showAddon(toppingTitle) {
    return Card(
      elevation: 5,
      child: Container(
          padding: EdgeInsets.all(0.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Obx(() => ExpansionTile(
                  onExpansionChanged: _onExpanDChanged,
                  trailing: Switch(
                    value: isExpanD,
                    onChanged: (_) {},
                  ),
                  title: MyStyle()
                      .txtstyle(toppingTitle, Colors.redAccent[700], 14.0),
                  children: [addOnChoiceChip()]))
            ],
          )),
    );
  }

  Column addOnChoiceChip() {
    return Column(
      //Wrap
      children: foodListStateController.selectedFood.value.addon
          .map((e) => Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ChoiceChip(
                        label: Container(
                            height: 42,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  foodController.selectAddon.contains(e)
                                      ? MyStyle().subTitleDrawerLight(e.optname)
                                      : MyStyle().subTitleDrawerDark(e.optname),
                                  SizedBox(width: 25),
                                  (e.addprice > 0)
                                      ? Text(
                                          '+ ' +
                                              MyCalculate()
                                                  .fmtNumber(e.addprice),
                                          style: TextStyle(
                                              color: foodController.selectAddon
                                                      .contains(e)
                                                  ? Colors.blue
                                                  : Colors.blueAccent[700]))
                                      : Text(
                                          (e.addprice != 0)
                                              ? MyCalculate()
                                                  .fmtNumber(e.addprice)
                                              : '',
                                          style: TextStyle(
                                            color: foodController.selectAddon
                                                    .contains(e)
                                                ? Colors.yellowAccent
                                                : Colors.redAccent[700],
                                          ))
                                ])),
                        selectedColor: Colors.black,
                        disabledColor: Colors.grey[100],
                        selected: foodController.selectAddon.contains(e),
                        onSelected: (selected) {
                          setState(() {
                            selected
                                ? foodController.selectAddon.add(e)
                                : foodController.selectAddon.remove(e);

                            //*** addprice */
                            foodController.priceD = getaddPriceD();
                            double ttladd = (foodController.priceB +
                                foodController.priceC +
                                foodController.priceD);
                            foodModel.addprice = ttladd;
                            //
                          });
                        }),
                  ],
                ),
              ))
          .toList(),
    );
  }

  double getaddPriceD() {
    double addpriceD = 0;
    foodListStateController.selectedFood.value.addon
        .map((e) => {
              addpriceD +=
                  foodController.selectAddon.contains(e).toString() == 'true'
                      ? e.addprice
                      : 0
            })
        .toList();
    return addpriceD;
  }

  Widget foodDetailImageWidget() {
    //cart
    final CartStateController cartStateController = Get.find();
    final FoodDetailStateController foodDetailStateController = Get.find();

    screenH = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          width: double.infinity, //= max width
          height: (screenH / 3.2),
          margin: EdgeInsets.only(left: 8.0, right: 8.0),
          /* child: new Hero(
            tag: 'img-${foodModel.name}',
            child: CachedNetworkImage(
              imageUrl:
                '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$ccode/${foodModel.image}',
                fit: BoxFit.cover,
            )
          ),*/
          child: new Hero(
              tag: 'img-${foodModel.name}',
              child: CachedNetworkImage(
                imageUrl:
                    '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$ccode/${foodModel.image}',
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  //height: 200, width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
        ),
        Align(
          alignment: const Alignment(
              0.8, 0.0), //ปุ่ม faverit / cart ห่างจาก  x ?, ขอบล่าง
          heightFactor: 0.5,
          child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 5), //ปุ่ม faverit / cart ห่างจาก ขอบซ้ายขวา
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 130,
                    child: Row(
                      children: [
                        FloatingActionButton(
                          heroTag: hero_fabFavTag,
                          onPressed: () async {
                            await saveFavorite();
                            Toast.show(
                              'ขอบคุณค่ะ',
                              context,
                              gravity: Toast.CENTER,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            );
                          },
                          child: Icon(
                            Icons.favorite,
                            color: Colors.pinkAccent[400],
                          ),
                          backgroundColor: Colors.white,
                          elevation: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: MyStyle().txtblack14TH('กดให้คะแนน'),
                        ),
                      ],
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: hero_fabCartTag,
                    onPressed: () {
                      String topBid = '0', topCid = '0', addonid = '';
                      String nameB = '', nameC = '', addonWORD = '';
                      String delim = '', mess = '';
                      if (foodModel.toppingB.length > 0) {
                        if (foodController.selectToppingB.value == null) {
                          mess = '!กรุณาเลือก' + foodModel.toppingB[0].toptitle;
                        } else {
                          topBid = foodController.selectToppingB.value.topid
                              .toString();
                          nameB = foodController.selectToppingB.value.topname;
                        }
                      }
                      if (foodModel.toppingC.length > 0) {
                        if (foodController.selectToppingC.value == null) {
                          mess += (mess == '' ? '!กรุณาเลือก' : ' ') +
                              foodModel.toppingC[0].toptitle;
                        } else {
                          topCid = foodController.selectToppingC.value.topid
                              .toString();
                          nameC = foodController.selectToppingC.value.topname;
                        }
                      }
                      if (mess == '') {
                        List<AddonModel> addonItems =
                            foodController.selectAddon;
                        if (addonItems != null && addonItems.length > 0) {
                          addonItems.forEach((addon) {
                            addonid += delim + addon.optid.toString();
                            addonWORD += delim + addon.optname;
                            delim = '|';
                          });
                        } else {
                          addonid = '0';
                        }
                        cartStateController.addToCart(
                          context,
                          foodModel,
                          mainStateController
                              .selectedRestaurant.value.restaurantId,
                          quantity: foodDetailStateController.quantity.value,
                          quantitySp:
                              foodDetailStateController.quantitySp.value,
                          topBid: topBid,
                          topCid: topCid,
                          addonid: addonid,
                          nameB: nameB,
                          nameC: nameC,
                          straddon: addonWORD,
                        );
                      } else {
                        alertDialog(context, mess);
                      }
                    },
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 5,
                  )
                ],
              )),
        )
      ],
    );
  }

  Row showRating() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      RatingBar.builder(
        initialRating: foodModel.favorite,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemBuilder: (context, _) {
          return Icon(
            Icons.star,
            color: Colors.amber[400],
          );
        },
        itemSize: 36,
        onRatingUpdate: (value) {
          setState(() {
            favorScore = value;
          });
        },
      ),
    ]);
  }

  Row showPriceCrycle(
      double baseprice, double addprice, Color bgcolor, Color txtcolor) {
    var myFmt = NumberFormat('##0.##', 'en_US');
    double price = (baseprice + addprice);
    var strPrice = myFmt.format(price);
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Container(
        margin: EdgeInsets.only(bottom: 5.0),
        width: 54.0,
        height: 54,
        child: FloatingActionButton(
            backgroundColor: bgcolor,
            child: MyStyle().txtstyle(strPrice, txtcolor, 16.0),
            onPressed: () => null),
      ),
      Container(
        margin: EdgeInsets.only(left: 2.0),
        width: 20.0,
        child: MyStyle().txtstyle('฿', Colors.black, 16.0),
      ),
    ]);
  }

  Row normalPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: (foodModel.priceSp > 0)
              ? MyStyle().txtTH18Dark('ปกติ ')
              : MyStyle().txtTH18Dark(''),
        ),
        showPriceCrycle(
            foodModel.price, foodModel.addprice, Colors.black, Colors.white),
        SizedBox(width: 10.0),
        Obx(() => ElegantNumberButton(
              initialValue: foodController.quantity.value,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) {
                foodController.quantity.value = value.toInt();
              },
              decimalPlaces: 0,
              step: 1,
              color: Colors.black12,
              buttonSizeWidth: 48,
              buttonSizeHeight: 48,
              textStyle: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
      ],
    );
  }

  Row specialPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: MyStyle().txtTH18Color('พิเศษ', Colors.redAccent[700]),
        ),
        showPriceCrycle(foodModel.priceSp, foodModel.addprice,
            Colors.amber[400], Colors.black),
        SizedBox(
          width: 10.0,
        ),
        Obx(() => ElegantNumberButton(
              initialValue: foodController.quantitySp.value,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) {
                foodController.quantitySp.value = value.toInt();
              },
              decimalPlaces: 0,
              step: 1,
              color: Colors.amber[400],
              buttonSizeWidth: 48,
              buttonSizeHeight: 48,
              textStyle: TextStyle(
                  fontSize: 18.0,
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold),
            )),
      ],
    );
  }

  Future<Null> saveFavorite() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'custom/favorScore.aspx?ccode=$ccode&iid=${foodModel.id}' +
        '&favorscore=$favorScore';

    try {
      await dio.Dio().get(url).then((value) {
        if (value != null && value.toString() != '') {
          var result = json.decode(value.data);
          double retScore = 0;
          for (var map in result) {
            MessModel mModel = MessModel.fromJson(map);
            retScore = double.parse(mModel.mess);
          }
          if (retScore != 0) {
            setState(() {
              favorScore = retScore;
              foodModel.favorite = favorScore;
            });
          }
        }
      });
    } catch (e) {
      //
    }
  }

  _onExpanBChanged(bool val) {
    setState(() {
      isExpanB = val;
    });
  }

  _onExpanCChanged(bool val) {
    setState(() {
      isExpanC = val;
    });
  }

  _onExpanDChanged(bool val) {
    setState(() {
      isExpanD = val;
    });
  }
}
