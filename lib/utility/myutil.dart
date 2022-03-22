import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/model/login_model.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'my_constant.dart';

class MyUtil {
  Widget showLogo() => Image.asset('images/logo.png');

  Drawer buildHomeDrawer(name, email) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Column(
            children: [
              builderUserAccountsDrawerHeader(name, email),
              //buildSignIn(),
              //buildSignUp(),
            ],
          ),
          //buildSignout(),
        ],
      ),
    );
  }

  UserAccountsDrawerHeader builderUserAccountsDrawerHeader(name, email) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/wall.jpg'), fit: BoxFit.cover)),
      accountName: MyStyle().titleDrawer(email == null ? 'email' : email),
      accountEmail: MyStyle().subtitleDrawer(name == null ? 'Name' : name),
      //***** name คือ email  Email คือ  user  *****
      currentAccountPicture: Image.asset('images/logo.png'),
    );
  }

  Future<String> findStrConn(BuildContext context) async {
    String mystrConn;
    SharedPreferences prefer = await SharedPreferences.getInstance();
    String loginMobile = prefer.getString('pmobile');
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkMobile.aspx?Mobile=$loginMobile';

    try {
      Response response = await Dio().get(url);
      if (response.toString().trim() == '') {
        alertDialog(context, '!มือถือไม่ถูกต้อง');
        //mystrConn='err_mobile';
      } else {
        var result = json.decode(response.data);
        for (var map in result) {
          LoginModel loginmodel = LoginModel.fromJson(map);
          if (loginMobile == loginmodel.mobile) {
            mystrConn = loginmodel.ccode;
          } else {
            alertDialog(context, '!ข้อมูลไม่ถูกต้อง');
            //mystrConn='err_data';
            break;
          }
        }
      }
    } catch (e) {
      //mystrConn='err_server';
      alertDialog(context, '!ไม่สามารถติดต่อ Serverได้');
    }
    return mystrConn;
  }

  void showToast(BuildContext context, String message) {
    Toast.show(
      message, context,
      gravity: Toast.CENTER,
      //backgroundColor: Colors.black,
      //textColor: Colors.yellowAccent,
    );
  }

  String getItemName(CartModel cModel) {
    String result = '';
    String topB =
        ('${cModel.nameB.trim()}' != '') ? '_${cModel.nameB.trim()}' : '';
    String topC =
        ('${cModel.nameC.trim()}' != '') ? '_${cModel.nameC.trim()}' : '';
    result = '${cModel.name}$topB$topC';
    return result;
  }

  String getOption(CartModel cModel) {
    String result = '';
    String txtaddon = ('${cModel.straddon.trim()}' != '')
        ? ' ${cModel.straddon.trim().replaceAll('|', ' ')}'
        : '';
    result = '$txtaddon';
    return result;
  }

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          Icons.fastfood,
          color: Colors.white,
        ),
        Expanded(
            child: Text(
          ' กรุณาระบุจำนวน',
        ))
      ],
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: (Colors.black),
    action: SnackBarAction(
      label: 'dismiss',
      onPressed: () {},
    ),
  );

  Future<Null> sendNoticToAdmin(String txtTitle, String txtBody) async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'notictoAdmin.aspx?title=$txtTitle&body=$txtBody';
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        //
      }
    } catch (e) {
      //
    }
  }

  Future<Null> sendNoticToShop(
      String resturantid, String txtTitle, String txtBody) async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'notictoShop.aspx?resturantid=$resturantid&title=$txtTitle&body=$txtBody';
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        //
      }
    } catch (e) {
      //
    }
  }

  Future<Null> sendNoticToCustom(
      String mbid, String txtTitle, String txtBody) async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/notictoCustom.aspx?mbid=' +
            mbid +
            '&title=' +
            txtTitle +
            '&body=' +
            txtBody;
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        //
      }
    } catch (e) {
      //
    }
  }

  Future<Null> sendNoticToCustRider(
      String mbid, String txtTitle, String txtBody) async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/notictoCustRider.aspx?mbid=' +
            mbid +
            '&title=' +
            txtTitle +
            '&body=' +
            txtBody;
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        //
      }
    } catch (e) {
      //
    }
  }
}
