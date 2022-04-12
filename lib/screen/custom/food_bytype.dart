import 'dart:convert';
import 'dart:ui';
import 'package:auto_animated/auto_animated.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/prodslider_model.dart';
import 'package:yakgin/model/product_model.dart';
import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/state/food_state.dart';
import 'package:yakgin/state/slide_sate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodByType extends StatefulWidget {
  @override
  _FoodByType createState() => _FoodByType();
}

class _FoodByType extends State<FoodByType> {
  String strConn, webPath;
  String loginMobile, loginccode;
  double screen;
  bool loadding = true;
  bool havemenu = true;
  ShopModel shopModel;
  List<ProductModel> productModels = List<ProductModel>.empty(growable: true);
  List<ProdSlideModel> sliderModels =
      List<ProdSlideModel>.empty(growable: true);
  SlideStateController slideStateController;
  final FoodStateController foodStateController = Get.find();

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginccode = prefer.getString('pccode');
      strConn = prefer.getString('pstrconn');
      webPath = prefer.getString('pwebpath');
      if (strConn != null) {
        readShopName();
        readFoodByType();
      }
    });
  }

  Future<Null> readShopName() async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/checkShop.aspx?ccode=' +
            loginccode;
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          shopModel = ShopModel.fromJson(map);
        });
      }
    });
  }

  Future<Null> readFoodByType() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodByType.aspx?loginccode=' +
        loginccode +
        '&itid=${foodStateController.selectedFoodType.value.itid}&strOrder=iName';

    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ProductModel prodModel = ProductModel.fromJson(map);
          setState(() {
            productModels.add(prodModel);
          });
        }
        if (productModels.length != 0) {
          setState(() {
            readFoodSlide(productModels[0].iid, 0);
          });
        }
      } else {
        setState(() {
          havemenu = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: MyStyle()
            .txtTH(loadding ? '' : 'ร้าน ${shopModel.thainame}', Colors.white),
        backgroundColor: MyStyle().primarycolor,
        /***sample อย่าลบทิ้ง 
         foregroundColor: Colors.orange,
         elevation: 10,
         iconTheme: IconThemeData(color: Colors.pink),*/
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              decoration: new BoxDecoration(color: Colors.grey[100]),
              child: (loadding)
                  ? MyStyle().showProgress()
                  : MyStyle().titleCenterTH(
                      context,
                      'สินค้าประเภท ${foodStateController.selectedFoodType.value.itname}',
                      20,
                      MyStyle().headcolor),
            ),
            Expanded(
                flex: 0,
                child: MyStyle().titleCenterTH(
                    context,
                    'ดูภาพสไลด์ คลิ๊กบนรูปสินค้าที่ต้องการ',
                    16,
                    Colors.black38)),
            Expanded(
              flex: 1,
              child: (loadding) ? MyStyle().showProgress() : showContent(),
            ),
            Expanded(flex: 2, child: slidePhoto()
                // child: (sliderModels.length == 0)
                //     ? MyStyle().titleCenterTH(context,
                //         'คลิ๊กบนรูปสินค้า เพื่อดูภาพสไลด์', 22.0, Colors.black)
                //     : slidePhoto()

                /*                 
                    : Container(
                        child: FutureBuilder(builder: (context, snapshot) {
                        //var lstBestDeal = sliderModels as List<ProdSlideModel>;
                        return CarouselSlider(
                            items: sliderModels
                                .map((e) => Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Card(
                                              semanticContainer: true,
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              child: Column(
                                                children: [
                                                  MyStyle().titleCenterTH(
                                                      context,
                                                      '${e.iname}',
                                                      20,
                                                      MyStyle().headcolor),
                                                  Text('${e.slidepict2}'),
                                                ],
                                              ),
                                            ));
                                      },
                                    ))
                                .toList(),
                            options: CarouselOptions(
                                autoPlay: true,
                                autoPlayAnimationDuration: Duration(seconds: 5),
                                autoPlayCurve: Curves.easeIn,
                                height: double.infinity)
                        );
                      })
                    )*/
                ),
            showNamePrice(),
          ],
        ),
      ),
    );
  }

  Row showNamePrice() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              width: screen * 0.65,
              child: MyStyle().titleCenterTH(
                  context,
                  (slideStateController != null)
                      ? '${slideStateController.selectedProductSlide.value.iname}'
                      : '',
                  22.0,
                  Colors.black)),
          Container(
            margin: EdgeInsets.all(0.1),
            width: screen * 0.25,
            height: 64,
            child: FloatingActionButton(
                backgroundColor: Colors.lightBlue[700],
                child: MyStyle().txtprice(slideStateController != null
                    ? '${slideStateController.selectedProductSlide.value.price}'
                    : ''),
                onPressed: () => null),
            // *** or
            // child: CircleAvatar(
            //   backgroundColor: Colors.yellow,
            //   minRadius: 50,
            //   maxRadius: 50,
            //   child: MyStyle().txtprice(
            //     (slideStateController != null) ? '${slideStateController.selectedProductSlide.value.price}':''),
            // ),
          ),
          Container(
              margin: EdgeInsets.only(right: 3),
              child: MyStyle().titleDrawer('฿')),
        ]);
  }

  Widget showContent() {
    return Container(
        child: (productModels.length != 0)
            ? showListFood()
            : MyStyle().titleCenterTH(
                context,
                'ไม่มีรายสินค้า ในประเภท${foodStateController.selectedFoodType.value.itname}',
                22,
                Colors.red));
  }

  Widget showSlide() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (sliderModels.length != 0 && slideStateController != null)
          slidePhoto()
      ],
    ));
  }

  Widget showListFood() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: LiveList(
                  showItemInterval: Duration(milliseconds: 150),
                  showItemDuration: Duration(milliseconds: 350),
                  reAnimateOnVisibility: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: productModels.length,
                  itemBuilder: animationItemBuilder((index) => Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                readFoodSlide(
                                    '${productModels[index].iid}', index);
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/${productModels[index].foodpict}',
                                ),
                                minRadius: 50,
                                maxRadius: 50,
                              ),
                            ),
                            // ***sample อย่าลบทิ้ง
                            //SizedBox(height: 10,),
                            // Text('${productModels[index].iname}',
                            //   style: GoogleFonts.kanit(
                            //     fontStyle: FontStyle.normal,
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.normal,
                            //     color: Color(0xff000000),
                            //   )
                            // )
                            Expanded(
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  margin: EdgeInsets.only(top: 5),
                                  width: screen * 0.3,
                                  child: MyStyle().txtstyle(
                                      '${productModels[index].iname}',
                                      Colors.black,
                                      16.0)),
                            )
                          ],
                        ),
                      ))))
        ],
      ),
    );
  }

  Widget xxxslidePhoto() {
    return Expanded(
        child: Container(child: FutureBuilder(builder: (context, snapshot) {
      return CarouselSlider(
          items: sliderModels
              .map((e) => Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: screen * 0.75,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Column(
                              children: [
                                //ok MyStyle().titleCenterTH(context, '${e.iname}', 20, MyStyle().headcolor),
                                Image.network(
                                  '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/${e.slidephoto}',
                                ),
                              ],
                            ),
                          ));
                    },
                  ))
              .toList(),
          options: CarouselOptions(
              autoPlay: true,
              autoPlayAnimationDuration: Duration(seconds: 5),
              autoPlayCurve: Curves.easeIn,
              height: double.infinity));
    })));
  }

  Widget slidePhoto() {
    return Container(child: FutureBuilder(builder: (context, snapshot) {
      //var lstBestDeal = sliderModels as List<ProdSlideModel>;
      return CarouselSlider(
          items: sliderModels
              .map((e) => Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: screen * 0.75,
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

  Card xcardPhoto(ProdSlideModel e) {
    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Stack(fit: StackFit.expand, children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Image.network(
              '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/${e.slidephoto}',
              fit: BoxFit.cover,
            ),
          ),
          Center(child: MyStyle().txtstyle('${e.iname}', Colors.black, 18.0))
        ]));
  }

  Card cardPhoto(ProdSlideModel e) {
    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
            onTap: () {
              print('Function is executed on tap. ${e.slidephoto}');
            },
            child: Stack(fit: StackFit.expand, children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Image.network(
                  '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/${e.slidephoto}',
                  fit: BoxFit.cover,
                ),
              ),
              //*** Center(child: MyStyle().txtstyle('${e.iname}', Colors.black, 20.0))
            ])
            //*** or
            // child: Column(
            //   children: [
            //     //ok MyStyle().titleCenterTH(context, '${e.iname}', 20, MyStyle().headcolor),
            //     Image.network(
            //       '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/${e.slidephoto}',
            //     ),
            //   ],
            // )
            ));
  }

  Future<Null> readFoodSlide(String iid, int index) async {
    sliderModels.clear();
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodSlide.aspx?ccode=$loginccode&iid=$iid';

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
            slideStateController = Get.put(SlideStateController());
            slideStateController = Get.find();
            slideStateController.selectedProductSlide.value =
                productModels[index];
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
}
