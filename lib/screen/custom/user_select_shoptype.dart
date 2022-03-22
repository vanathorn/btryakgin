import 'dart:convert';
//vtr after upgrade  import 'dart:ui';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/model/shoptype_model.dart';
//import 'package:yakgin/screen/custom/category_screen.dart';
import 'package:yakgin/screen/custom/category_withappbar_screen.dart';
import 'package:yakgin/screen/custom/user_rest_food.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';
import 'package:get/get.dart';

class UserSelectShoptype extends StatefulWidget {
  @override
  _UserSelectShoptype createState() => _UserSelectShoptype();
}

class _UserSelectShoptype extends State<UserSelectShoptype> {
  String loginMobile, ccode;
  double screen;
  bool loadding = true;
  ShopTypeModel shoptypeModel;
  String selectType = '';

  final MainStateController mainStateContoller = Get.find();

  List<ShopTypeModel> shoptypeModels = List<ShopTypeModel>.empty(growable: true);
  List<ShopRestModel> restModels = List<ShopRestModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getShopType();
    firstAllShopType();
  }

  Future<Null> getShopType() async {
    //if (shoptypeModels.length > 0)
    shoptypeModels.clear();
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getShopType.aspx?withall=Y';
    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopTypeModel eModel = ShopTypeModel.fromJson(map);
          setState(() {
            shoptypeModels.add(eModel);
          });
        }
      }
    });
  }

  Future<Null> firstAllShopType() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getShopType.aspx?withall=Y';

    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopTypeModel eModel = ShopTypeModel.fromJson(map);
          setState(() {
            shoptypeModels.add(eModel);
          });
        }
        if (shoptypeModels.length != 0) {
          setState(() {
            readShopByTypeSlide(shoptypeModels[0].stid, 0);
          });
        }
      } else {
        setState(() {
          //havemenu = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
                flex: 0,
                child: MyStyle().titleCenterTH(context,
                    'เลือกประเภทสินค้าที่ต้องการ', 16, Colors.black38)),
            Expanded(flex: 1, child: (loadding) ? Container() : showContent()),
            Expanded(
                flex: 5,
                child: (restModels.length > 0)
                    ? slideShopType()
                    : MyStyle().showProgress()),
          ],
        ),
      ),
    );
  }

  Widget showContent() {
    return Container(
        child: (shoptypeModels.length != 0)
            ? showListShopType()
            : MyStyle().titleCenterTH(
                context, 'ไม่มีร้านค้าประเภท $selectType', 20, Colors.red));
  }

  Widget showListShopType() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: LiveList(
                  showItemInterval: Duration(milliseconds: 150),
                  showItemDuration: Duration(milliseconds: 350),
                  reAnimateOnVisibility: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: shoptypeModels.length,
                  itemBuilder: animationItemBuilder(
                    (index) => Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 3, right: 8.0),
                      child: Column(
                        children: [
                          Align(
                              //alignment: Alignment.topCenter,
                              child: SizedBox(
                            child: GestureDetector(
                              onTap: () {
                                selectType =
                                    '${shoptypeModels[index].stypename}';
                                readShopByTypeSlide(
                                    '${shoptypeModels[index].stid}', index);
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 34.0,
                                    //backgroundColor: MyStyle().coloroverlay,
                                    backgroundImage: NetworkImage(
                                      '${MyConstant().apipath}.${MyConstant().domain}/${MyConstant().shoptypeimagepath}/${shoptypeModels[index].stypepict}',
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          //child:
                                          //GestureDetector(
                                          //onTap: () {
                                          //readShopByTypeSlide('${shoptypeModels[index].stid}', index);
                                          //},
                                          child: CircleAvatar(
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  '${MyConstant().apipath}.${MyConstant().domain}/${MyConstant().shoptypeimagepath}/${shoptypeModels[index].stypepict}',
                                                ),
                                                radius: 15.0,
                                                /* child:                                       
                                                        Icon(
                                                          Icons.camera_alt,
                                                          size: 15.0,
                                                          color: Color(0xFF404040),
                                                        ),
                                                    */
                                              ),
                                            ),
                                            backgroundColor:
                                                MyStyle().coloroverlay,
                                            radius: 34.0,
                                          ),
                                          //)
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: MyStyle().txtstyle(
                                              '${shoptypeModels[index].stypename}',
                                              Colors.white,
                                              12.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }

  Widget slideShopType() {
    return Container(
        width: screen,
        child: LiveList(
            showItemInterval: Duration(milliseconds: 150),
            showItemDuration: Duration(milliseconds: 350),
            reAnimateOnVisibility: true,
            scrollDirection: Axis.vertical,
            itemCount: restModels.length,
            itemBuilder: animationItemBuilder((index) => InkWell(
                  onTap: () {
                    mainStateContoller.selectedRestaurant.value = restModels[index]; 
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => CategoryWithAppbarScreen(
                        restModel: restModels[index],
                      ),
                    );
                    Navigator.push(context, route);
                  },
                  child: Card(
                      elevation: 8,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 3, bottom: 5, right: 3),
                                // decoration: new BoxDecoration(
                                //      color: Colors.white), //grey[100]
                                width: (screen - 152.0), //height: 120,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      MyStyle().txtstyle(
                                          '${restModels[index].thainame}',
                                          Colors.black,
                                          14),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 5.0),
                                        child: MyStyle().txtstyle(
                                            '${restModels[index].address}',
                                            Colors.black54,
                                            11.0),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.mobile_friendly,
                                                    color: Colors.black),
                                                SizedBox(
                                                  width: 3.0,
                                                ),
                                                MyStyle().txtstyle(
                                                    '${restModels[index].phone}',
                                                    Colors.blue[900],
                                                    13),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      FloatingActionButton.extended(
                                        backgroundColor: Color(0xffBFB372),
                                        label: Text('เกี่ยวกับร้าน',
                                            style: TextStyle(
                                                fontFamily: 'thaisanslite',
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black)),
                                        icon: Icon(Icons.deck, color: Colors.black,),
                                        onPressed: () async {
                                          mainStateContoller
                                                  .selectedRestaurant.value =
                                              restModels[
                                                  index]; //vtr mainController
                                          MaterialPageRoute route =
                                              MaterialPageRoute(
                                            builder: (context) => UerRestFood(
                                              restModel: restModels[index],
                                            ),
                                          );
                                          Navigator.push(context, route);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(5.0),
                                width: 120,
                                height: 120,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${restModels[index].shoppict}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              /* *** ทำ Overlay ใต้ภาพ
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height:38.0,
                            color: MyStyle().coloroverlay,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top:0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(color:MyStyle().coloroverlay),
                                          MyStyle().txtstyle('${restModels[index].thainame}', Colors.white, 15.0),                                 
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        )*/
                            ],
                          ),
                        ],
                      )),
                ))));
  }

  Future<Null> readShopByTypeSlide(String id, int index) async {
    restModels.clear();
    String url = (id == '0')
        ? '${MyConstant().apipath}.${MyConstant().domain}/getShopAll.aspx?strCondtion=&strOrder='
        : '${MyConstant().apipath}.${MyConstant().domain}/getShopByType.aspx?stid=$id';

    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopRestModel pslideModels = ShopRestModel.fromJson(map);
          //
          // listAccbks.clear();
          // var straccbank = pslideModels.banklist.split('*').toList();
          // for(int i=0; i<straccbank.length; i++){
          //   var tmp = straccbank[i].split("|");
          //   listAccbks.add(AccountModel(pslideModels.ccode, tmp[0], tmp[1], tmp[2], tmp[3], tmp[4]));
          // }
          // pslideModels.account = listAccbks.toList();
          setState(() {
            restModels.add(pslideModels);
          });
        }
      } else {
        //print('value.toString() is null');
      }
    });
  }
}
