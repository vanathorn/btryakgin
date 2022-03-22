//vtr after upgrade  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/utility/mystyle.dart';

class HomeScreen extends StatelessWidget {
  final zoomDrawerController;
  HomeScreen(this.zoomDrawerController);

  Widget build(BuildContext context) {
    //double screen=MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('เลือกเมนูการทำงาน'),
            leading: InkWell(
              onTap: () => zoomDrawerController.toggle(),
              child: Icon(Icons.menu),
            )),
        body: SafeArea(
            child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, //cenetr ตามแนวตั้ง Vertical
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      children: [
                        MyStyle().txtTH('คุณเป็นสมาชิกมากว่าหนึ่งประเภทสมาชิก',
                            Colors.black),
                        MyStyle().txtTH('เลือกเมนูสำหรับการทำงานที่คุณต้องการ',
                            Colors.black),
                        SizedBox(height: 15.0),
                        MyStyle().txtTH('เมนูลูกค้าประกอบด้วย', Colors.red),
                        MyStyle()
                            .txtTH('-ร้านค้าที่อยู่ในโครงการ', Colors.black),
                        MyStyle().txtTH('-ตะกร้าสินค้าของคุณ', Colors.black),
                        MyStyle().txtTH('-การซื้อสินค้าของคุณ', Colors.black),
                        SizedBox(height: 15.0),
                        MyStyle()
                            .txtTH('เมนูเจ้าของร้านประกอบด้วย', Colors.red),
                        MyStyle()
                            .txtTH('-รายการสินค้าที่ลูกค้าสั่ง', Colors.black),
                        MyStyle().txtTH('-รายการสินค้าในร้านค้า', Colors.black),
                        MyStyle().txtTH('-รายละเอียดร้านของคุณ', Colors.black),
                        SizedBox(height: 15.0),
                        MyStyle().txtTH(
                            'เมนูผู้ส่งอาหารประกอบด้วยประกอบด้วย', Colors.red),
                        MyStyle().txtTH('-1.', Colors.black),
                        MyStyle().txtTH('-2.', Colors.black),
                      ],
                    ))
              ]),
            ),
          ],
        )));
  }
}
