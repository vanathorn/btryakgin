import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btryakgin/model/count_model.dart';
import 'package:btryakgin/model/mess_model.dart';
import 'package:btryakgin/screen/user_edit_info.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/utility/signOut.dart';
import 'package:btryakgin/widget/appbar_withrider.dart';
import 'package:btryakgin/widget/rider/rider_order_delivery.dart';
import 'package:btryakgin/widget/rider/rider_order_list.dart';

class MainRider extends StatefulWidget {
  @override
  _MainRiderState createState() => _MainRiderState();
}

class _MainRiderState extends State<MainRider> {
  String strConn, mbid, loginName, loginMobile, ccode, mbimage = 'userlogo.png';
  Widget currentWidget = RiderOrderList();
  final MainStateController mainStateController = Get.find();

  @override
  void initState() {
    super.initState();
    notification();
    findUser();
  }

  Future<Null> notification() async {
    try {
      if (Platform.isAndroid) {
        /*
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage message) {
          if (message != null) {
            Navigator.pushNamed(context, '/message',
                arguments: MessageArguments(message, true));
          }
        });*/

        // FirebaseMessaging.instance.configure(onLaunch: (message) async {          //
        // }, onResume: (message) async {
        //   String txtTitle = message['data']['title'];
        //   String txtBody = message['data']['body'];
        //   noticDialog(context, txtTitle, txtBody);
        // }, onMessage: (message) async {
        //   String txtTitle = message['notification']['title'];
        //   String txtBody = message['notification']['body'];
        //   noticDialog(context, txtTitle, txtBody);
        // });

        // workaround for onLaunch: When the app is completely closed (not in the background)
        // and opened directly from the push notification

        // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        //   if (message != null) Toast.show('onMessageOpenedApp', context);
        // });

        // FirebaseMessaging.instance
        //     .getInitialMessage()
        //     .then((RemoteMessage message) {
        //   if (message != null) {
        //     print('onMessageOpenedApp data: ${message.data}');
        //     Toast.show('onMessageOpenedApp data: ${message.data}', context);
        //   }
        // });

        // onMessage: When the app is open and it receives a push notification
        // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //   String txtTitle = jsonEncode(message.data['notification']['title']);
        //   String txtBody = jsonEncode(message.data['notification']['body']);
        //   noticDialog(context, txtTitle, txtBody);
        // });

        // // replacement for onResume: When the app is in the background and opened directly from the push notification.
        // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        //   String txtTitle = jsonEncode(message.data['data']['title']);
        //   String txtBody = jsonEncode(message.data['data']['body']);
        //   noticDialog(context, txtTitle, txtBody);
        // });

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
      } else if (Platform.isIOS) {
        //
      }
    } catch (ex) {
      //
    }
  }

  // void _openDetailPage() {
  //   Navigator.of(context).push(MaterialPageRoute(builder: (_) {
  //     return MainRider();
  //   }));
  // }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      loginMobile = prefer.getString(MyConstant().keymoblie);
      mbid = prefer.getString(MyConstant().keymbid);
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

  Future<Null> countOrderNo() async {
    String url =
        '${MyConstant().domain}/${MyConstant().apipath}/rider/countOrdRider.aspx';
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          CountModel mModel = CountModel.fromJson(map);
          setState(() {
            mainStateController.selectedRestaurant.value.cntord =
                int.parse(mModel.cnt);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    countOrderNo();
    return Scaffold(
        /*
      appBar: AppBar(
        backgroundColor: MyStyle().primarycolor,
        title: MyStyle().txtTH(
            loginName == null ? 'Main User' : 'login $loginName', Colors.white),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              iconSize: 38,
              onPressed: () => signOut(context) //
              )
        ],
      ),*/
        appBar: AppBarWithRiderButton(
            title: 'Wellcome $loginName', subtitle: '', ttlordno: '0'),
        drawer: buildDrawer('Wellcome', loginName, 'rider.jpg'),
        body: currentWidget);
  }

  Drawer buildDrawer(name, email, imgwall) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              //MyStyle().builderUserAccountsDrawerHeader(name,email,imgwall,mbimage),
              riderDrawerHeader(name, email, imgwall, mbimage),
              bookOrderMenu(),
              reservedMenu(),
            ],
          ),
          Column(
            //ต้องเปลี่ยนจาก ListView -> Stack ถึงจะ work
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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

  UserAccountsDrawerHeader riderDrawerHeader(name, email, imgwall, logoimage) {
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

  ListTile bookOrderMenu() => ListTile(
        leading: Icon(Icons.shop),
        title: MyStyle().titleDark('จองนำส่งสินค้า'),
        subtitle: MyStyle().subtitleDark('จองสินค้าเพื่อนำส่ง'),
        onTap: () {
          setState(() {
            currentWidget = RiderOrderList();
          });
          Navigator.pop(context);
        },
      );

  ListTile reservedMenu() => ListTile(
        leading: Icon(Icons.delivery_dining),
        title: MyStyle().titleDark('สินค้าที่จองนำส่งไว้'),
        subtitle: MyStyle().subtitleDark('สินค้าที่จะต้องนำส่งให้ลูกค้า'),
        onTap: () {
          setState(() {
            currentWidget = RiderOrderDelivery();
          });
          Navigator.pop(context);
        },
      );
  /*    
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
  */

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
}
