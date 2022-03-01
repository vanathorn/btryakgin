import 'dart:convert';
import 'package:dio/dio.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/resturant_model.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBasketList extends StatefulWidget {
  @override
  _UserBasketListState createState() => _UserBasketListState();
}

class _UserBasketListState extends State<UserBasketList> {
  String strConn, loginccode, webPath;
  String loginName, loginMobile;
  double screen;
  bool loadding = true;
  bool havedata = true;
  List<ResturantModel> foodModels = List<ResturantModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    findUser();
    //print('first ***** havedata=$havedata');
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      loginccode = prefer.getString('pccode');
      strConn = prefer.getString('pstrconn');
      webPath = prefer.getString('pwebpath');
      //print('second ***** havedata=$havedata');
      getBastket();
      //*** for text only
      setState(() {
        loadding = false;
      });
    });
  }

  Future<Null> getBastket() async {
    if (foodModels.length != 0) {
      foodModels.clear();
    }
    String url =
        '${MyConstant().domain}/${MyConstant().apipath}/xx.aspx?ccode=' +
            loginccode +
            '&strCondtion=&strOrder=';
    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ResturantModel fModels = ResturantModel.fromJson(map);
          setState(() {
            foodModels.add(fModels);
          });
        }
      } else {
        setState(() {
          havedata = false;
        });
      }
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

  Widget showContent() {
    return havedata
        ? showListBasket()
        : MyStyle().titleCenterTH(
            context, 'ไม่มีรายการอาหาร ในตะกร้าของคุณ', 22, Colors.red);
  }

  Widget showListBasket() {
    return Container(
      child: MyStyle().titleCenterTH(
          context, 'แสดงสินค้าในตะกร้าของ $loginName', 22, Colors.black),
    );
  }
}
