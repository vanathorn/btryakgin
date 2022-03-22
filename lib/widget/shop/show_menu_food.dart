import 'dart:convert';
import 'dart:ui';

import 'package:auto_animated/auto_animated.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/foodtype_model.dart';
import 'package:yakgin/model/prodslider_model.dart';
import 'package:yakgin/model/product_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';

class ShowMenuFood extends StatefulWidget {
  final ShopRestModel restModel;
  ShowMenuFood({Key key, this.restModel}) : super(key: key);
  @override
  _ShowMenuFoodState createState() => _ShowMenuFoodState();
}

class _ShowMenuFoodState extends State<ShowMenuFood> {
  ShopRestModel restModel;
  double screen;
  String strConn, webPath, ccode;
  bool loadding = true;
  bool havetype = true;
  String itid;
  List<ProductModel> productModels = List<ProductModel>.empty(growable: true);
  List<ShopRestModel> foodModels = List<ShopRestModel>.empty(growable: true);
  List<ProdSlideModel> sliderModels =
      List<ProdSlideModel>.empty(growable: true);
  //final FoodStateController foodStateController = Get.find();
  //SlideStateController slideStateController;
  List<FoodTypeModel> foodTypeModels =
      List<FoodTypeModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    ccode = restModel.ccode;
    strConn = restModel.strconn;
    webPath = restModel.webpath;
    readFoodTypeController();
  }

  Future<Null> readFoodTypeController() async {
    if (foodTypeModels.length != 0) {
      foodTypeModels.clear();
    }
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodType.aspx?ccode=$ccode&strCondtion=&strOrder=';

    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          FoodTypeModel fModels = FoodTypeModel.fromJson(map);
          setState(() {
            foodTypeModels.add(fModels);
          });
        }
        itid = foodTypeModels[0].itid;
      } else {
        setState(() {
          havetype = false;
        });
      }
    });
  }

  Future<Null> readFoodSlide(String iid, int index) async {
    //ยังไม่ใช้
    sliderModels.clear();
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodSlide.aspx?ccode=$ccode&iid=$iid';

    await Dio().get(url).then((value) {
      /*setState(() {
        load_slide = false;
      });*/
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ProdSlideModel pslideModels = ProdSlideModel.fromJson(map);
          setState(() {
            //*** can use/
            //x slideStateController = Get.put(SlideStateController());
            //x slideStateController = Get.find();
            //x slideStateController.selectedProductSlide.value = productModels[index];
            //foodName = '${slideStateController.selectedProductSlide.value.iname}';
            sliderModels.add(pslideModels);
          });
        }
      } else {
        /*
        setState(() {
          have_slide = false;
        });*/
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: foodTypeModels.length == 0
          ? MyStyle().showProgress()
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.0),
                  //width: screen, //220,
                  height: 480, //770, //190,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: slideFoodType(),
                      ),
                      Expanded(
                        flex: 2,
                        child: showFoodByType(),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(top: 2.0),
                //     child: showFoodByType()
                // )
              ],
            ),
    );
  }

  Widget slideFoodType() {
    return Container(child: FutureBuilder(builder: (context, snapshot) {
      return CarouselSlider(
          items: foodTypeModels
              .map((e) => Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: cardPhoto(e),
                      );
                    },
                  ))
              .toList(),
          options: CarouselOptions(
              autoPlay: true,
              autoPlayAnimationDuration: Duration(seconds: 3),
              autoPlayCurve: Curves.easeIn,
              height: double.infinity));
    }));
  }

  Card cardPhoto(FoodTypeModel e) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () {
          getFoodByType(e.itid);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Container(
                  height: 120,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Image.network(
                      'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/foodtype/${e.ftypepict}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(e.itname)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> getFoodByType(String ftypeid) async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodByType.aspx?ccode=$ccode&itid=$ftypeid&strOrder=iName';

    //&itid=${foodStateController.selectedFoodType.value.itid}
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        if (productModels.length != 0) {
          productModels.clear();
        }
        for (var map in result) {
          ProductModel prodModels = ProductModel.fromJson(map);
          productModels.add(prodModels);
        }
      }
    });
    setState(() {
      //จำเป็นต้องมี
    });
  }

  Widget showFoodByType() {
    return Container(
        child: productModels.length == 0
            ? MyStyle().titleCenterTH(context,
                'คลิ๊กบนประเภทสินค้า เพื่อดูรายการสินค้า', 16, Colors.black38)
            : productList());
  }

  Widget productList() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      //height: 770,
      child: Column(
        children: [
          Expanded(
              child: LiveList(
                  //showItemInterval: Duration(milliseconds: 150),
                  //showItemDuration: Duration(milliseconds: 350),
                  reAnimateOnVisibility: true,
                  scrollDirection: Axis.vertical,
                  itemCount: productModels.length,
                  itemBuilder: animationItemBuilder((index) => Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                //readFoodSlide('${productModels[index].iid}', index);
                              },
                              child: ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                child: Image.network(
                                  'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${productModels[index].foodpict}',
                                  width: screen * 0.8,
                                ),
                              ),

                              /*                    
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${productModels[index].foodpict}'
                                ),
                                minRadius: screen*0.75,
                                maxRadius: screen*0.75,
                              ),
                              */
                            ),
                          ],
                        ),
                      ))))
        ],
      ),
    );
  }
}
