import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sql_conn/sql_conn.dart';
import 'package:yakgin/model/ddl_model.dart';
import 'package:yakgin/state/prov_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:get/get.dart' as dget;
import 'package:get_storage/get_storage.dart';

import 'package:yakgin/state/cart_shop_state.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/sqlservice.dart';


class Prov extends StatefulWidget {
  //final Sqflite app;
  final mainStateContoller = dget.Get.put(MainStateController());
  final cartShopStateController = dget.Get.put(CartShopStateController());
  final cartStateController = dget.Get.put(CartStateController());

  Prov();

  @override
  ProvState createState() => ProvState();
}

class ProvState extends State<Prov> {
  double screen;
  String name, email, imgwall;

  ProvDetailStateController provController =
      dget.Get.put(ProvDetailStateController());
  List<DDLModel> listProv = List<DDLModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    initboxStorage();
    SQLService().clearConn();
    getProvince();
  }

  Future<void> getProvince() async {
    listProv.clear();
    //listAmpher.clear();
    //listTumbon.clear();
    String query =
        "select ProvinceNo,ProvinceName from dbo.Province where enbFlag='Y' order by ProvinceName";
    try {
      if (!SqlConn.isConnected) {
        SQLService().connect();
      }
      var value = await SqlConn.readData(query);
      if (value.toString() != 'null') {
        value = value.toString().replaceAll('"', "");
        var x = value
            .toString()
            .replaceAll("[{", "")
            .replaceAll("}]", "")
            .replaceAll('"', "")
            .split('},')
            .toList();
        for (int j = 0; j < x.length; j++) {
          var y = x[j].split(',');
          String _id = y[0].split(':')[1];
          String _txtvalue = y[1].split(':')[1];
          //debugPrint('$_id / $_txtvalue');

          DDLModel ddl = new DDLModel();
          ddl.id = int.parse(_id);
          ddl.txtvalue = _txtvalue;
          setState(() {
            listProv.add(DDLModel(id: ddl.id, txtvalue: ddl.txtvalue));
          });
        }
      }
    } catch (e) {
      debugPrint('Error ' + e.toString());
    }
  }

  Future<void> initboxStorage() async {
    try {
      HttpOverrides.global = MyHttpOverrides();
      await GetStorage.init();
    } catch (ex) {
      print('***** HttpClient createHttpClient Fail *****');
      alertDialog(context, ex.toString());
    }
  }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyStyle().primarycolor,
        ),
        drawer: buildHomeDrawer('Wellcome', 'Guest', 'guest.png'),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
                center: Alignment(0, -0.62),
                radius: 1.0,
                colors: <Color>[Colors.white, Colors.blueAccent]),
          ),
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildProvince(),
              ],
            ),
          )),
        ));
  }

  Drawer buildHomeDrawer(name, email, imgwall) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Column(
            children: [
              MyStyle().homeAccountsDrawerHeader(name, email, imgwall),
            ],
          ),
          //buildSignout(),
        ],
      ),
    );
  }

  Container buildProvince() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
        ),
        margin: EdgeInsets.all(5),
        width: screen * 0.9,
        height: 54,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  listProv != null
                  ? MyStyle().titleDark('${listProv.length}')
                  : Text('xxx')                 
                ]
            )
        );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
