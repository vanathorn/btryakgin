import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/map_sample.dart';
import 'package:yakgin/screen/menu/main_admin.dart';
import 'package:yakgin/screen/menu/main_shop_branch.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yakgin/screen/SignIn.dart';
import 'package:yakgin/screen/SingUp.dart'; //
import 'package:yakgin/screen/menu/main_rider.dart';
import 'package:yakgin/screen/menu/main_shop_head.dart';
import 'package:yakgin/screen/menu/main_user.dart';
import 'package:yakgin/screen/menu/multi_home.dart';
import 'package:yakgin/state/cart_shop_state.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:flutter/foundation.dart';

class Home extends StatefulWidget {
  //final Sqflite app;
  final mainStateContoller = Get.put(MainStateController());
  final cartShopStateController = Get.put(CartShopStateController());
  final cartStateController = Get.put(CartStateController());
  //final orderStateController = Get.put(OrderStateController());  //count-order

  Home();

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  double screen;
  String name, email, imgwall;
  @override
  void initState() {
    super.initState();
    checkPreferance();
    initboxStorage();
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async { 
      if (widget.box.hasData(MY_CART_KEY)){
        var cartSave = await widget.box.read(MY_CART_KEY) as String;
        if (cartSave.length >0 && cartSave.isNotEmpty){
          final listCart = jsonDecode(cartSave) as List<dynamic>;
          final listCartParsed = listCart.map((e) => CartModel.fromJson(e)).toList();
          if (listCartParsed.length > 0)
            widget.cartStateController.cart = listCartParsed;
        }
      }else{
        widget.cartStateController.cart = 
         new List<CartModel>.empty(growable: true);
      }
    });
    */
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

  Future<Null> checkPreferance() async {
    String token = "";
    try {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      token = await firebaseMessaging.getToken();
      //String token = await FirebaseMessaging.instance.getToken();
    } catch (ex) {
      alertDialog(context, 'home:FirebaseMessaging Error ' + ex.toString());
    }
    try {
      SharedPreferences prefer = await SharedPreferences.getInstance();
      String chooseCode = prefer.getString('pchooseCode');
      String loginId = prefer.getString('pid');
      String brcode = prefer.getString(MyConstant().keybrcode);
      print('************ loginId=$loginId --- token=$token');
      if (loginId != null && loginId.isNotEmpty && token != "") {
        String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
            'updateToken.aspx?mbid=$loginId&token=$token';
        await Dio().get(url).then((value) => print('Update Token Success'));
      }
      if (chooseCode != null && chooseCode.isNotEmpty) {
        if (chooseCode == 'U') {
          routeToService(MainUser());
          //routeToService(ShowMenuFood()); //***** for test only
        } else if (chooseCode == 'R') {
          routeToService(MainRider());
        } else if (chooseCode == 'S') {
          if (brcode == '${MyConstant().headBranch}') {
            routeToService(MainShopHead());
          } else {
            routeToService(MainShopBranch());
          }
        } else if (chooseCode == 'A') {
          routeToService(MainAdmin());
        } else {
          routeToService(MultiHome());
        }
      }
    } catch (ex) {
      alertDialog(context, 'home : SharedPreferences Error' + ex.toString());
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
                buildLogo(),
                //MyStyle().txtbrand('Yakgin'),
                signinBar(),
                signupBar(),
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
              buildSignIn(),
              buildSignUp(),
              //testMap(),
            ],
          ),
          //buildSignout(),
        ],
      ),
    );
  }

  Container buildLogo() {
    return Container(
        width: !kIsWeb ? (screen * 0.28) : (screen * 0.08),
        margin: const EdgeInsets.only(top: 3),
        child: MyUtil().showLogo());
  }

  Container signinBar() {
    return Container(
        margin: const EdgeInsets.all(8),
        width: !kIsWeb ? (screen * 0.75) : (screen * 0.28),
        child: InkWell(
            onTap: () {
              Navigator.pop(context);
              MaterialPageRoute route =
                  MaterialPageRoute(builder: (value) => SignIn());
              Navigator.push(context, route);
            },
            child: Container(
                decoration: BoxDecoration(
                  //color: Colors.transparent,
                  //borderRadius: BorderRadius.circular(0),
                  image: DecorationImage(
                    image: AssetImage("images/signin.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                height: 120,
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/signin.png"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        // margin:
                        //     const EdgeInsets.only(top: !kIsWeb ? 75 : 0),
                        height: 34,
                        color: MyStyle().coloroverlay,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyStyle()
                                  .txtstyle('เข้าใช้ระบบ', Colors.white, 14.0),
                            ])),
                  ),
                ]))));
  }

  Container signupBar() {
    return Container(
        margin: const EdgeInsets.all(8),
        width: !kIsWeb ? (screen * 0.75) : (screen * 0.28),
        child: InkWell(
            onTap: () {
              Navigator.pop(context);
              MaterialPageRoute route =
                  MaterialPageRoute(builder: (value) => SignUp());
              Navigator.push(context, route);
            },
            child: Container(
                decoration: BoxDecoration(
                  //color: Colors.transparent,
                  //borderRadius: BorderRadius.circular(0),
                  image: DecorationImage(
                    image: AssetImage("images/signup.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                height: 120,
                child: Stack(
                    //fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            // margin:
                            //      const EdgeInsets.only(top: !kIsWeb ? 85 : 0),
                            height: 34,
                            color: MyStyle().coloroverlay,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyStyle().txtstyle(
                                      'สมัครสมาชิก', Colors.white, 14.0),
                                ])),
                      ),
                    ]))));
  }

  ListTile buildSignIn() {
    return ListTile(
      leading: Icon(
        Icons.login,
        size: 36,
      ),
      title: MyStyle().titleDark('เข้าใช้ระบบ'),
      subtitle: MyStyle().subtitleDark('Signin with your exist account.'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignIn());
        Navigator.push(context, route);
      },
    );
  }

  ListTile buildSignUp() {
    return ListTile(
      leading: Icon(
        Icons.app_registration,
        size: 36,
      ),
      title: MyStyle().titleDark('สมัครสมาชิกใหม่'),
      subtitle: MyStyle().subtitleDark('New register.'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignUp());
        Navigator.push(context, route);
      },
    );
  }

  ListTile testMap() {
    return ListTile(
      leading: Icon(
        Icons.login,
        size: 36,
      ),
      title: MyStyle().titleDark('ทดสอบแผนที่'),
      subtitle: MyStyle().subtitleDark('test google map.'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => MapSample());
        Navigator.push(context, route);
      },
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
