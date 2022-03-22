import 'dart:convert';

import 'package:dio/dio.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

import 'package:yakgin/model/order_detail_model.dart';
import 'package:yakgin/model/order_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/order/grs_total_widget.dart';

class UserOrderList extends StatefulWidget {
  @override
  _UserOrderListState createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  bool havedata = true;
  String mbid;
  double screen,
      ttlGrsAmount,
      ttlDiscount,
      ttlVatAmount,
      ttlNetAmount,
      ttlLogist;
  final MainStateController mainStateController = dget.Get.find();

  List<OrderModel> listOrders = List<OrderModel>.empty(growable: true);
  List<OrdDetailModel> listDetails = List<OrdDetailModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    findOrder();
  }

  Future<Null> findOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/custom/customOrderList.aspx?mbid=$mbid&condition=' +
        '[Status] not in (2,3)&strorder=olid asc';

    listOrders.clear();
    ttlGrsAmount = 0;

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null) {
        for (var map in result) {
          setState(() {
            OrderModel mModel = OrderModel.fromJson(map);
            listDetails.clear();

            var detailList = mModel.detailList.split('*').toList();
            String iname = '';
            double qty;
            double unitprice;
            double netamount;

            for (int i = 0; i < detailList.length; i++) {
              var tmp = detailList[i].split("|");
              iname = tmp[0] +
                  tmp[1] +
                  tmp[2] +
                  tmp[3] +
                  tmp[4] +
                  (tmp[5] != '' ? '_' + tmp[5] : '');
              qty = double.parse(tmp[6]);
              unitprice = double.parse(tmp[7]);
              netamount = double.parse(tmp[11]);
              listDetails.add(OrdDetailModel(mModel.restaurantId,
                  (i + 1).toString(), iname, qty, unitprice, netamount));
            }

            mModel.orddtl = listDetails.toList();
            listOrders.add(mModel);
            ttlGrsAmount += double.parse(mModel.ttlGrsAmount);

            havedata = true;
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
        Container(
          margin: const EdgeInsets.only(left: 5, top: 1, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyStyle().txtshadowsIntoLight('Your Order'),
              Container(
                width: 90,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.lightGreenAccent[700],
                  onPressed: findOrder,
                  label: Text('ปัจจุบัน',
                      style: TextStyle(
                        fontFamily: 'thaisanslite',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      )),
                  icon: Icon(Icons.refresh, color: Colors.white),
                  splashColor: Colors.blue,
                  //foregroundColor: Colors.white,
                  //hoverColor: Colors.red,
                  //focusColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 48),
          child: listOrders == null
              ? MyStyle().showProgress()
              : (listOrders.length == 0)
                  ? Center(
                      child: MyStyle().titleCenterTH(context,
                          (havedata) ? '' : 'ไม่มีคำสั่งซื้อ', 16, Colors.red),
                    )
                  : showData(context),
        )
      ],
    );
  }

  Container showData(BuildContext context) => Container(
          child: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: listOrders.length,
                  itemBuilder: (context, index) => Card(
                      elevation: 5.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5.0),
                      child: orderData(index)))),
          Divider(thickness: 1),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 10),
          //       child: MyStyle().txtTitle('GRS Amount'),
          //     ),
          //   ],
          // ),
          GrsTotalWidget(
              netamount: ttlNetAmount,
              discount: ttlDiscount,
              vatamount: ttlVatAmount,
              logist: ttlLogist,
              grsamount: ttlGrsAmount)
        ],
      ));

  Column orderData(int index) {
    return Column(children: [
      Container(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 2.7,
                colors: <Color>[Colors.white, MyStyle().secondarycolor]),
          ),
          child: orderHead(index),
        ),
      ),
      ExpansionTile(
        title: orderTitle(index),
        children: [
          orderDetail(index),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: orderFooter(index),
          ),
          orderStep(index),
        ],
      )
    ]);
  }

  Column orderStep(int index) {
    return Column(
      children: [
        StepsIndicator(
          nbSteps: 4,
          selectedStep: listOrders[index].stepIn,
          lineLength: (!kIsWeb) ? 65 : (screen * 0.11),
          selectedStepColorOut: Colors.black,
          selectedStepColorIn: Color.fromRGBO(250, 196, 2, 1),
          unselectedStepColorIn: Colors.white,
          doneStepColor: Colors.blue, //step ทำแล้ว
          /* ทำงานถ้าไม่กำหนด enableLineAnimation
          doneLineColor: Colors.green, //เส้นที่ทำงานแล้ว 
          undoneLineColor: Colors.red,//เส้นที่จะทำงานต่อไป
          */
          enableLineAnimation: true,
          enableStepAnimation: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35, right: 35, bottom: 8),
          child: Container(
            width: (!kIsWeb) ? screen : screen * 0.36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyStyle().txtblack12TH('Order'),
                MyStyle().txtblack12TH('Cooking'),
                MyStyle().txtblack12TH('Delivery'),
                MyStyle().txtblack12TH('Finish')
              ],
            ),
          ),
        )
      ],
    );
  }

  Column orderDetail(int index) {
    return Column(
      children: listOrders[index]
          .orddtl
          .map((e) => Padding(
                padding: const EdgeInsets.only(left: 8, right: 10, bottom: 8.0),
                child: orderItems(e),
              ))
          .toList(),
    );
  }

  Column orderTitle(int index) {
    return Column(
      children: [
        Container(
          child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                  margin: const EdgeInsets.only(left: 5),
                  //width: screen * 0.48,
                  child: SingleChildScrollView(
                    child: MyStyle().txtstyle(
                      listOrders[index].shopName +
                          ' ' +
                          listOrders[index].contactphone,
                      Colors.blueAccent[700],
                      12.0,
                    ),
                  )),
            /*
            Container(
              margin: const EdgeInsets.only(left: 5),
              width: screen * 0.22,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MyStyle().txtblack12TH(listOrders[index].statusOrder)
                ],
              ),
            ),
            */
          ]),
        )
      ],
    );
  }

  Row orderHead(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          //margin: const EdgeInsets.only(left: 3),
          width: screen * 0.35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MyStyle().txtstyle(
                listOrders[index].strOrderDate,
                Colors.redAccent[700],
                11.0,
              ),
              SizedBox(width: 5.0),
              MyStyle().txtblack12TH(listOrders[index].ordTime)
            ],
          ),
        ),
        Container(
          width: screen * 0.29,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyStyle().txtstyle(listOrders[index].orderNo, Colors.black, 10.0),
            ],
          ),
        ),
        Container(
          //width: screen * 0.33,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyStyle().txtstyle(
                MyCalculate().fmtNumberBath(
                    double.parse(listOrders[index].ttlGrsAmount)),
                Colors.black,
                12.0,
              ),
            ],
          ),
        )
      ],
    );
  }

  Column orderFooter(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(thickness: 1),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(flex: 2, child: MyStyle().txtbody('มูลค่าสินค้า')),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyStyle().txtblack17TH(MyCalculate()
                      .fmtNumber(double.parse(listOrders[index].ttlNetAmount))),
                ],
              )),
          Expanded(flex: 1, child: MyStyle().txtbody('')),
          Expanded(flex: 2, child: MyStyle().txtbody('ส่วนลด')),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyStyle().txtblack17TH(MyCalculate()
                      .fmtNumber(double.parse(listOrders[index].ttlDiscount))),
                ],
              )),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(flex: 2, child: MyStyle().txtbody('ภ.มูลค่าเพิ่ม')),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyStyle().txtblack17TH(MyCalculate()
                      .fmtNumber(double.parse(listOrders[index].ttlVatAmount))),
                ],
              )),
          Expanded(flex: 1, child: MyStyle().txtbody('')),
          Expanded(flex: 2, child: MyStyle().txtbody('ค่าขนส่ง')),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyStyle().txtblack17TH(MyCalculate()
                      .fmtNumber(double.parse(listOrders[index].ttlLogist))),
                ],
              )),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(flex: 5, child: MyStyle().txtbody('')),
          Expanded(
              flex: 2,
              child: MyStyle().txtstyle('มูลค่าสุทธิ์', Colors.red, 12)),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyStyle().txtblack17TH(MyCalculate()
                      .fmtNumber(double.parse(listOrders[index].ttlGrsAmount)))
                ],
              )),
        ])
      ],
    );
  }

  Column orderItems(OrdDetailModel e) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 7,
                child: MyStyle().txtblack16TH('${e.seq}. ${e.itemname}')),
            Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().txtblack17TH(
                      MyCalculate().fmtNumber(double.parse('${e.qty}')) +
                          '*' +
                          MyCalculate()
                              .fmtNumber(double.parse('${e.unitprice}')),
                    ),
                  ],
                )),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().txtblack17TH(
                      MyCalculate().fmtNumber(double.parse('${e.netamount}')),
                    )
                  ],
                ))
          ],
        ),
      ],
    );
  }
}
