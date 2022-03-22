import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/product_model.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResturantScreen extends StatefulWidget {
  @override
  _ResturantScreen createState() => _ResturantScreen();
}

class _ResturantScreen extends State<ResturantScreen> {
  String strConn, webPath;
  String loginMobile, loginccode, loginName;
  double screen;
  bool loadding = true;
  //bool havemenu = true;
  //ShopModel shopModel;
  List<ProductModel> productModels = List<ProductModel>.empty(growable: true);
  // List<ProdSlideModel> sliderModels = List<ProdSlideModel>.empty(growable: true);
  // final FoodStateController foodStateController = Get.find();
  // SlideStateController slideStateController;

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
      loginName = prefer.getString('pname');
      if (strConn != null) {
        readFoodByType();
      }
    });
  }

  Future<Null> readFoodByType() async {
    //var foodStateController;
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'shopList.aspx?strOrder=Seq';

    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ProductModel prodModels = ProductModel.fromJson(map);
          setState(() {
            productModels.add(prodModels);
          });
        }
        if (productModels.length != 0) {
          setState(() {
            //readFoodSlide(productModels[0].iid, 0);
          });
        }
      } else {
        // setState(() {
        //   havemenu = false;
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    //var foodStateController;
    return Scaffold(
        appBar: AppBar(
          title:
              MyStyle().txtTH(loadding ? '' : 'Login $loginName', Colors.white),
          backgroundColor: MyStyle().primarycolor,
        ),
        body: Container(
            padding: const EdgeInsets.all(5),
            child: Column(children: [
              Container(
                decoration: new BoxDecoration(color: Colors.grey[100]),
                child: (loadding)
                    ? MyStyle().showProgress()
                    : MyStyle().titleCenterTH(context,
                        'ร้านอาหารที่ร่วมโครงการ', 20, MyStyle().headcolor),
              ),
            ])));
  }
}
