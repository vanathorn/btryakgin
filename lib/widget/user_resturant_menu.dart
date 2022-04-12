import 'dart:convert';

import 'package:auto_animated/auto_animated.dart';
import 'package:dio/dio.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/screen/custom/food_bytype.dart';
import 'package:yakgin/screen/custom/user_rest_food.dart';
import 'package:yakgin/screen/shop/shop_location.dart';
import 'package:yakgin/state/resturant_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';

class UserResturantMenu extends StatefulWidget {
  @override
  _UserResturantMenuState createState() => _UserResturantMenuState();
}

class _UserResturantMenuState extends State<UserResturantMenu> {
  String strConn, webPath;
  String loginName, loginMobile;
  double screen;
  ShopModel shopModel;
  String nameofShop;
  bool loadding = true;
  bool havemenu = true;
  List<ShopRestModel> restModels = List<ShopRestModel>.empty(growable: true);
  //final viewModels = FoodViewImp();
  final resturantStateController = Get.put(ResturantStateController());

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      getRestutant();
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        loadding ? MyStyle().showProgress() : showContent(),
      ],
    );
  }

  Future<Null> getRestutant() async {
    if (restModels.length != 0) {
      restModels.clear();
    }
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getResturant.aspx?strCondtion=&strOrder=';
    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopRestModel fModels = ShopRestModel.fromJson(map);
          setState(() {
            restModels.add(fModels);
          });
        }
      } else {
        setState(() {
          havemenu = false;
        });
      }
    });
  }

  Widget showContent() {
    return havemenu
        ? showListResturant()
        : MyStyle().titleCenterTH(
            context, 'ไม่มีร้านค้าที่อยู่ในโครงการ', 22, Colors.red);
  }

  Widget showListResturant() {
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
                  //resturantStateController.selectedResturant.value = //restModels[index];

                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => UerRestFood(
                      restModel: restModels[index],
                    ),
                  );
                  Navigator.push(context, route);

                  /*
                   MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => CategoryScreen(restModel: restModels[index],),
                  );
                  Navigator.push(context, route);
                  */
                },
                child: Row(
                  children: [
                    Container(
                      //decoration: myBoxDecoration(),
                      margin:
                          const EdgeInsets.only(top: 3, bottom: 12, left: 3),
                      width: 150, height: 150,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                              'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${restModels[index].shoppict}'),
                          //Container(color: MyStyle().coloroverlay),
                          // Center(
                          //   child: MyStyle().txtstyle(restModels[index].thainame, Colors.white, 22),
                          // )
                        ],
                      ),
                    ),
                    Container(color: Colors.black),
                    Container(
                      //decoration: myBoxDecoration(),
                      margin: const EdgeInsets.only(
                        top: 3,
                        bottom: 12,
                      ),
                      decoration: new BoxDecoration(color: Colors.grey[100]),
                      width: (screen - 155.0), height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyStyle().txtstyle('${restModels[index].thainame}',
                                Colors.black, 14),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 8.0),
                              child: MyStyle().txtstyle(
                                  '${restModels[index].address}',
                                  Colors.black54,
                                  10.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
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
                                          14),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            /*                       
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only( right: 8.0),
                            child: shopLocation(restModels[index]),
                          ),
                        ],
                      ) 
                      */
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   width:100, height: 10,
                    //   decoration: myBoxDecoration(),
                    // )
                  ],
                ),
              )),
        ));
  }

  FloatingActionButton shopLocation(ShopRestModel restModels) {
    return FloatingActionButton(
      //backgroundColor: Colors.greenAccent[700],
      onPressed: () {
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => ShopLocation(
                  restModels: restModels,
                ));
        Navigator.push(context, route).then((value) => getRestutant());
      },
      child: Icon(Icons.location_pin),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      //border: Border.all(width: 1, color: Colors.deepPurpleAccent[400]),
      border: Border(
          left: BorderSide(
        color: Colors.black,
        width: 3.0,
      )),
      //borderRadius: BorderRadius.all(Radius.circular(8.0))
    );
  }

  //***** if want touse LiveGrid
  LiveGrid showLiveGrid() {
    return LiveGrid(
      showItemInterval: Duration(milliseconds: 150),
      showItemDuration: Duration(milliseconds: 300),
      reAnimateOnVisibility: true,
      scrollDirection: Axis.vertical,
      itemCount: restModels.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, crossAxisSpacing: 1, mainAxisSpacing: 2),
      itemBuilder: animationItemBuilder((index) => InkWell(
            onTap: () {
              resturantStateController.selectedResturant.value =
                  restModels[index];
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => FoodByType(),
              );
              Navigator.push(context, route);
            },
            child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                        'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${restModels[index].shoppict}'),
                    Container(color: MyStyle().coloroverlay),
                    Center(
                      child: MyStyle().txtstyle(
                          restModels[index].thainame, Colors.white, 28),
                    )
                  ],
                )),
          )),
    );
  }
}
