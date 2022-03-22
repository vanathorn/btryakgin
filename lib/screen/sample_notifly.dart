import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/delivery_model.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/widget/appbar_sample.dart';
import 'package:yakgin/widget/infosnackbar.dart';

class SampleNotiflyScreen extends StatefulWidget {
  SampleNotiflyScreen({Key key}) : super(key: key);
  @override
  _SampleNotiflyScreenState createState() => _SampleNotiflyScreenState();
}

class _SampleNotiflyScreenState extends State<SampleNotiflyScreen> {
  DeliveryModel deliModel;
  double screen, lat1, lng1;
  String txtdetail = '';

  @override
  void initState() {
    super.initState();
    initFirebase();
    notification();
  }

  Future<Null> initFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (ex) {
      //debugPrint('initFirebase fail : Firebase.initializeApp() ' + ex.toString());
      alertDialog(
          context, 'Firebase.initializeApp() Fail.\r\n' + ex.toString());
    }
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
      alertDialog(context, ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBarSampleButton(title: 'FirebaseMessaging Sample.'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                inputName(),
                SizedBox(height: 25),
                FloatingActionButton.extended(
                  label: Text('ส่งการแจ้งเตือน',
                      style: TextStyle(
                        fontFamily: 'thaisanslite',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      )),
                  icon: Icon(Icons.alarm),
                  backgroundColor: Colors.redAccent[700],
                  onPressed: () {
                    setState(() {
                      sendNotifly();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> sendNotifly() async {
    try {
      MyUtil().sendNoticToShop(
          '1', 'ทดสอบแจ้งเตือน', 'ด้วย : FirebaseMessaging\r\n$txtdetail');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          InfoSnackBar.infoSnackBar(
              'Title:' + 'ทดสอบแจ้งเตือน', Icons.mark_chat_read),
        );
      setState(() {
        //
      });
    } catch (ex) {
      alertDialog(context, ex.toString());
    }
  }

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //margin: EdgeInsets.only(top: 10),
            width: screen * 0.75,
            height: 50,
            child: TextFormField(
              initialValue: '',
              onChanged: (value) => txtdetail = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'เนื้อความ',
                prefixIcon: Icon(Icons.message, color: MyStyle().darkcolor),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().lightcolor),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyStyle().darkcolor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          )
        ],
      );
}
