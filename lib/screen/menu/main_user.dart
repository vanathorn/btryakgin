import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:btryakgin/model/count_model.dart';
import 'package:btryakgin/model/mess_model.dart';
import 'package:btryakgin/screen/custom/cart_shop_list.dart';
import 'package:btryakgin/screen/user_edit_info.dart';
import 'package:btryakgin/screen/custom/user_select_shoptype.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/utility/signOut.dart';
import 'package:btryakgin/widget/custom/user_order_list.dart';

class MainUser extends StatefulWidget {
  @override
  _MainUserState createState() => _MainUserState();
}

class _MainUserState extends State<MainUser> {
  String strConn, mbid, loginName, loginMobile, ccode, mbimage = 'userlogo.png';
  Widget currentWidget = UserSelectShoptype();
  int cntOrder = 0;

  final CartStateController cartStateController = Get.find();
  final MainStateController mainStateController = Get.find();
  ZoomDrawerController zoomDrawerController;

  @override
  void initState() {
    super.initState();
    notification();
    findUser();
  }

  Future<Null> notification() async {
    try {
      if (Platform.isAndroid) {
        FirebaseMessaging firebaseMessaging = FirebaseMessaging();
        firebaseMessaging.configure(onLaunch: (message) async {
          //
        }, onResume: (message) async {
          String txtTitle = message['data']['title'];
          String txtBody = message['data']['body'];
          noticDialog(context, txtTitle, txtBody);
        }, onMessage: (message) async {
          String txtTitle = message['notification']['title'];
          String txtBody = message['notification']['body'];
          noticDialog(context, txtTitle, txtBody);
        });

        // onMessage: When the app is open and it receives a push notification
        /*
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("onMessage data: ${message.data}");
          Toast.show('onMessage data: ${message.data}', context);
          String txtTitle = jsonEncode(message.data['notification']['title']);
          String txtBody = jsonEncode(message.data['notification']['body']);
          noticDialog(context, txtTitle, txtBody);
        });

        // replacement for onResume: When the app is in the background and opened directly from the push notification.
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('onResume data: ${message.data}');
          Toast.show('onResume data: ' + jsonEncode(message.data), context);
          String txtTitle = jsonEncode(message.data['data']['title']);
          String txtBody = jsonEncode(message.data['data']['body']);
          noticDialog(context, txtTitle, txtBody);
        });
        */

      } else if (Platform.isIOS) {
        //
      }
    } catch (ex) {
      //
    }
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      loginName = preferences.getString('pname');
      loginMobile = preferences.getString(MyConstant().keymoblie);
      mbid = preferences.getString(MyConstant().keymbid);
      getMemberPict();
    });
  }

  Future<Null> getMemberPict() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'getMbpict.aspx?mbid=$mbid';

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null && result != '') {
        for (var map in result) {
          setState(() {
            MessModel mModel = MessModel.fromJson(map);
            mbimage = mModel.mess;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().primarycolor,
        title: MyStyle().txtTH(
            (loginName != null ? 'Wellcome ' + loginName : ''), Colors.white),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              iconSize: 38,
              onPressed: () => signOut(context) //
              )
        ],
      ),
      drawer: buildDrawer('Wellcome ', loginName, 'user.jpg'),
      body: currentWidget,
    );
  }

  Drawer buildDrawer(name, email, imgwall) {
    return Drawer(
      child: Stack(
        //ListView
        children: <Widget>[
          Column(
            children: [
              //MyStyle().builderUserAccountsDrawerHeader(name, email, imgwall, mbimage),
              userDrawerHeader(name, email, imgwall, mbimage),
              userSelectShoptypeMenu(),
              userBasketMenu(),
              userOrderMenu(),
            ],
          ),
          Column(
            //ต้องเปลี่ยนจาก ListView -> Stack ถึงจะ work
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              //Divider(thickness: 1, color: Colors.black12),
              signOutMenu(),
              SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }

  UserAccountsDrawerHeader userDrawerHeader(name, email, imgwall, logoimage) {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDrawer(imgwall),
      accountEmail: Row(
        children: [
          MyStyle().subtitleDrawer(name == null ? 'Name' : name),
          SizedBox(width: 3),
          MyStyle().titleDrawer(email == null ? 'Email' : email),
        ],
      ),
      accountName: Text(''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
              onTap: () {
                setState(() {
                  currentWidget = UserEditInfo(
                      mbid: mbid,
                      loginname: loginName,
                      loginmobile: loginMobile,
                      pictname: mbimage);
                });
                Navigator.pop(context);
              },
              child: logoimage == ''
                  ? Image.asset('userlogo.png')
                  : Image.network(
                      '${MyConstant().domain}/${MyConstant().memberimagepath}/$logoimage',
                      fit: BoxFit.cover,
                    )),
        ),
      ),
    );
  }

  ListTile userSelectShoptypeMenu() => ListTile(
        leading: Icon(Icons.fastfood),
        title: MyStyle().titleDark('ร้านค้า'),
        subtitle: MyStyle().subtitleDark('ร้านค้าที่ร่วมโครงการ'),
        onTap: () {
          setState(() {
            currentWidget = UserSelectShoptype(); //UserResturantMenu();
          });
          Navigator.pop(context);
        },
      );

  ListTile userBasketMenu() => ListTile(
        leading: Icon(Icons.add_shopping_cart),
        title: MyStyle().titleDark('ตระกร้าสินค้าของคุณ'),
        subtitle: MyStyle().subtitleDark('สินค้าของคุณที่รอยืนยันการสั่งซื้อ'),
        onTap: () {
          if (cartStateController.getCartShop().toList().length > 0) {
            setState(() {
              currentWidget = CartShopListScreen(); //CartDetailScreen();
            });
            Navigator.pop(context);
          } else {
            Toast.show(
              'ไม่มีสินค้าในตะกร้าของคุณ $loginName',
              context,
              gravity: Toast.CENTER,
              backgroundColor: Colors.redAccent[700],
              textColor: Colors.white,
            );
          }
        },
      );

  ListTile userOrderMenu() => ListTile(
        leading: Icon(Icons.restaurant_menu),
        title: MyStyle().titleDark('การซื้อของคุณ'),
        subtitle: MyStyle().subtitleDark('สินค้าที่สั่งซื้อแล้วรอการส่ง'),
        onTap: () {
          final cnt = countOrder();
          cnt.then((e) => {
                if (e > 0)
                  {
                    setState(() {
                      currentWidget = UserOrderList();
                    }),
                    Navigator.pop(context)
                  }
                else
                  {
                    Toast.show(
                      'ไม่มีสินค้า\r\nที่คุณ $loginName สั่งซื้อ',
                      context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.redAccent[700],
                      textColor: Colors.white,
                    )
                  }
              });
        },
      );

  ListTile userProfileMenu() => ListTile(
        leading: Icon(Icons.account_circle),
        title: MyStyle().titleDark('แก้ไขโปรไฟล์ส่วนตัว'),
        subtitle: MyStyle().subtitleDark('ชื่อ มือถือ และรูปภาพที่แสดง'),
        onTap: () {
          setState(() {
            currentWidget = UserEditInfo(
                mbid: mbid,
                loginname: loginName,
                loginmobile: loginMobile,
                pictname: mbimage);
          });
          Navigator.pop(context);
        },
      );

  Widget signOutMenu() {
    return Container(
      decoration: BoxDecoration(color: Colors.red[600]),
      child: ListTile(
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        title: MyStyle().titleLight('ออกจากระบบ'),
        subtitle: MyStyle().subtitleLight('Back to home page.'),
        onTap: () => signOut(context),
      ),
    );
  }

  Future<int> countOrder() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}' +
        '/custom/countOrder.aspx?mbid=' +
        mbid +
        '&condition=[Status] not in (2,3,9)';
    cntOrder = 0;
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null) {
        for (var map in result) {
          CountModel mModel = CountModel.fromJson(map);
          cntOrder = int.parse(mModel.cnt);
        }
      }
    });
    return cntOrder;
  }
}
