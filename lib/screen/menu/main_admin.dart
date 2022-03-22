import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/count_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/signOut.dart';
import 'package:yakgin/widget/admin/get_newmember.dart';
import 'package:yakgin/widget/appbar_admin.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
//*** https://mui.com/components/material-icons/

class MainAdmin extends StatefulWidget {
  @override
  _MainAdminState createState() => _MainAdminState();
}

class _MainAdminState extends State<MainAdmin> {
  String ccode, _adminName;
  Widget currentWidget = GetNewMember();
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

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefer.getString('pname');
    });
  }

  Future<Null> countNewMember() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'admin/countNewMember.aspx';
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          CountModel mModel = CountModel.fromJson(map);
          setState(() {
            mainStateController.selectedRestaurant.value.cntnewm =
                int.parse(mModel.cnt);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    countNewMember();
    return Scaffold(
        appBar: AppBarAdminButton(
            title: 'Wellcome $_adminName', subtitle: '', ttlnewmember: '0'),
        drawer: buildDrawer('', '$_adminName', 'admin_wall.jpg'),
        body: currentWidget);
  }

  Drawer buildDrawer(name, email, imgwall) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              Container(
                height: 177,
                child: MyStyle().builderAdminAccountsDrawerHeader(
                    name, email, imgwall, 'images/admin_logo.jpg'),
              ),
              newMemberMenu(),
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

  ListTile newMemberMenu() => ListTile(
        leading: Icon(Icons.person_pin),
        title: MyStyle().titleDark('สมาชิกใหม่'),
        subtitle: MyStyle().subtitleDark('สมาชิกลงทะเบียนเข้ามาใหม่'),
        onTap: () {
          setState(() {
            currentWidget = GetNewMember();
          });
          Navigator.pop(context);
        },
      );

  Widget signOutMenu() {
    return Container(
      decoration: BoxDecoration(color: MyStyle().bgsignout),
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
