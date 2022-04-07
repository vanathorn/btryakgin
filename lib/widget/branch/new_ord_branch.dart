import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/order_detail_model.dart';
import 'package:yakgin/model/order_model.dart';
import 'package:yakgin/model/status_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/widget/infosnackbar.dart';
import 'package:yakgin/widget/order/grs_total_widget.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';

class GetNewOrderBranch extends StatefulWidget {
  @override
  _GetNewOrderBranchState createState() => _GetNewOrderBranchState();
}

class _GetNewOrderBranchState extends State<GetNewOrderBranch> {
  bool havedata = true;
  String mbid, txtReason = '';
  double screen,
      ttlDiscount,
      ttlVatAmount,
      ttlNetAmount,
      ttlLogist,
      ttlGrsAmount;
  final MainStateController mainStateController = dget.Get.find();

  List<OrderModel> listOrders = List<OrderModel>.empty(growable: true);
  List<OrdDetailModel> listDetails = List<OrdDetailModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    findNewOrder();
  }

  //เอา mbid ไปหา cid(cid=resturantId)
  Future<Null> findNewOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/branch/getNewOrdBranch.aspx?mbid=$mbid&condition=' +
        '[Status]=0&strorder=olid asc';

    listOrders.clear();
    ttlVatAmount = 0;
    ttlLogist = 0;
    ttlNetAmount = 0;
    ttlGrsAmount = 0;
    ttlDiscount = 0;
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
//iName+'|'+topnameA+'|'+topnameB+'|'+topnameC+'|'+topdText+'|'+special+'|'
//ex. สตอเบอร์รี่|1|2|3|4|5|
// 6=qty 1.00|7=unitprice 35.00|8=DiscPerc 0.00|9=DiscAmount 0.00|
//10=amount 35.00|11=netamount 35.00|12=ถ้วย
            for (int i = 0; i < detailList.length; i++) {
              var tmp = detailList[i].split('|');
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

            ttlDiscount += double.parse(mModel.ttlDiscount);
            ttlLogist += double.parse(mModel.ttlLogist);
            ttlNetAmount += double.parse(mModel.ttlNetAmount);
            ttlVatAmount += double.parse(mModel.ttlVatAmount);
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
          margin: const EdgeInsets.only(left: 5),
          child: MyStyle().txtshadowsIntoLight('New Order'),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
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
                      child: Column(children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                //margin: const EdgeInsets.only(left: 0),
                                width: screen * 0.27,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    MyStyle().txtstyle(
                                      listOrders[index].strOrderDate,
                                      Colors.redAccent[700],
                                      11.0,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                width: screen * 0.33,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyStyle().txtstyle(
                                      listOrders[index].orderNo,
                                      Colors.black,
                                      12.0,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                width: screen * 0.32,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    MyStyle().txtstyle(
                                      MyCalculate().fmtNumberBath(double.parse(
                                          listOrders[index].ttlGrsAmount)),
                                      Colors.black,
                                      12.0,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        ExpansionTile(
                          title: Column(
                            children: [
                              Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          width: screen * 0.47,
                                          child: SingleChildScrollView(
                                            child: MyStyle().txtstyle(
                                              listOrders[index].mbname +
                                                  ' ' +
                                                  listOrders[index]
                                                      .contactphone,
                                              Colors.blueAccent[700],
                                              12.0,
                                            ),
                                          )),
                                      Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        width: screen * 0.23,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            /*
                                            MyStyle().txtstyle(
                                              listOrders[index]
                                                      .ttlitem
                                                      .toString() +
                                                  ' รายการ',
                                              Colors.blueAccent[700],
                                              10.0,
                                            ),*/
                                            MyStyle().txtblack14TH(
                                                listOrders[index].statusOrder)
                                          ],
                                        ),
                                      ),
                                    ]),
                              )
                            ],
                          ),
                          children: [
                            //Divider(thickness: 1),
                            Column(
                              children:
                                  //listStateController.selectedOrder.value.orddtl.map((e) =>
                                  listOrders[index]
                                      .orddtl
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8,
                                                right: 10,
                                                bottom: 8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        flex: 7,
                                                        child: MyStyle()
                                                            .txtblack16TH(
                                                                '${e.seq}. ${e.itemname}')),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            MyStyle().txtstyle(
                                                                MyCalculate().fmtNumber(
                                                                        double.parse(
                                                                            '${e.qty}')) +
                                                                    '*' +
                                                                    MyCalculate()
                                                                        .fmtNumber(
                                                                            double.parse('${e.unitprice}')),
                                                                Colors.black,
                                                                12),
                                                          ],
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            MyStyle().txtstyle(
                                                                MyCalculate().fmtNumber(
                                                                    double.parse(
                                                                        '${e.netamount}')),
                                                                Colors.black,
                                                                12)
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, bottom: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Divider(thickness: 1),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: MyStyle()
                                                .txtbody('มูลค่าสินค้า')),
                                        Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                MyStyle().txtblack18TH(
                                                    MyCalculate().fmtNumber(
                                                        double.parse(listOrders[
                                                                index]
                                                            .ttlNetAmount))),
                                              ],
                                            )),
                                        Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child:
                                                  MyStyle().txtbody('ส่วนลด'),
                                            )),
                                        Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                MyStyle().txtblack18TH(
                                                    MyCalculate().fmtNumber(
                                                        double.parse(
                                                            listOrders[index]
                                                                .ttlDiscount))),
                                              ],
                                            )),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: MyStyle()
                                                .txtbody('ภ.มูลค่าเพิ่ม')),
                                        Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                MyStyle().txtblack18TH(
                                                    MyCalculate().fmtNumber(
                                                        double.parse(listOrders[
                                                                index]
                                                            .ttlVatAmount))),
                                              ],
                                            )),
                                        Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child:
                                                  MyStyle().txtbody('ค่าขนส่ง'),
                                            )),
                                        Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                MyStyle().txtblack18TH(
                                                    MyCalculate().fmtNumber(
                                                        double.parse(
                                                            listOrders[index]
                                                                .ttlLogist))),
                                              ],
                                            )),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: MyStyle().txtbody('')),
                                        Expanded(
                                            flex: 2,
                                            child: MyStyle().txtstyle(
                                                'มูลค่าสุทธิ์',
                                                Colors.red,
                                                12)),
                                        Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                MyStyle().txtblack18TH(
                                                    MyCalculate().fmtNumber(
                                                        double.parse(
                                                            listOrders[index]
                                                                .ttlGrsAmount)))
                                              ],
                                            )),
                                      ])
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 3),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      /*
                                      FloatingActionButton.extended(
                                        label: Text('ไม่รับออร์เดอร์',
                                            style: TextStyle(
                                              fontFamily: 'thaisanslite',
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            )),
                                        icon: Icon(Icons.cancel),
                                        backgroundColor: Colors.redAccent[700],
                                        onPressed: () {
                                          txtReason = '';
                                          confirmCancel(listOrders[index]);
                                          setState(() {
                                            findNewOrder();
                                          });
                                        },
                                      ),
                                      SizedBox(width: 5),
                                      */
                                      FloatingActionButton.extended(
                                        label: Text('รับออร์เดอร์',
                                            style: TextStyle(
                                                fontFamily: 'thaisanslite',
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white)),
                                        icon: Icon(Icons.mark_chat_read),
                                        onPressed: () async {
                                          reciveOrder(listOrders[index]);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ])))),
          Divider(thickness: 2),
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

  Future<Null> reciveOrder(OrderModel listord) async {
    //mbid =  mbid ของ Customer
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'shop/setOrderStatus.aspx?mbordid=' +
        listord.mbordid +
        '&ccode=' +
        listord.ccode +
        '&mbid=' +
        listord.mbid +
        '&olid=' +
        listord.olid +
        '&reason=&shopname=' +
        listord.shopName +
        '&orderno=' +
        listord.orderNo;
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        checkReciveStatus(listord);
      } else {
        alertDialog(context, response.toString());
      }
    } catch (e) {
      alertDialog(context, '!รับคำสั่งซื้อไม่สำเร็จ');
    }
  }

  Future<Null> checkReciveStatus(OrderModel listord) async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/shop/checkOrdStatus.aspx?ccode=' +
            listord.ccode +
            '&olid=' +
            listord.olid +
            '&orderno=' +
            listord.orderNo;
    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null) {
          for (var map in result) {
            StatusModel mModel = StatusModel.fromJson(map);
            if (mModel.status == recive_order_status) {
              //listord.mbid -> mbid=ของลูกค้าที่สั่งซื้อ
              MyUtil().sendNoticToCustRider(
                  listord.mbid,
                  'รับคำสั่งซื้อ\r\n' + '${listord.orderNo}',
                  'ร้าน:' + listord.shopName);
              //Toast.show('รับคำสั่งซื้อ '+ listord.orderNo +' เรียบร้อย', context);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'รับคำสั่งซื้อ:' + listord.orderNo, Icons.mark_chat_read),
                );
              setState(() {
                findNewOrder();
              });
            } else {
              alertDialog(
                  context,
                  '!สถานะคำสั่งซื้อ ' +
                      listord.orderNo +
                      '\r\nผิดพลาดกรุณาตรวจสอบ');
            }
          }
        } else {
          alertDialog(context, '!ไม่พบคำสั่งซื้อ ' + listord.orderNo);
        }
      });
    } catch (e) {
      alertDialog(context,
          '!ตรวจสอบสถานะคำสั่งซื้อไม่ได้\r\n(ไม่สามารถติดต่อ Serverได้)');
    }
  }

  Future<Null> checkCancelStatus(OrderModel listord) async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/shop/checkOrdStatus.aspx?ccode=' +
            listord.ccode +
            '&olid=' +
            listord.olid +
            '&orderno=' +
            listord.orderNo;
    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null) {
          for (var map in result) {
            StatusModel mModel = StatusModel.fromJson(map);
            if (mModel.status == cancel_order_status) {
              MyUtil().sendNoticToCustom(
                  listord.mbid,
                  '*ยกเลิกคำสั่งซื้อ*' + '${listord.orderNo}',
                  'จากร้าน:' + listord.shopName);
              //Toast.show('ยกเลิกคำสั่งซื้อ:'+ listord.orderNo +' เรียบร้อย', context);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'ยกเลิกคำสั่งซื้อ:' + listord.orderNo, Icons.cancel),
                );
              setState(() {
                findNewOrder();
              });
            } else {
              alertDialog(
                  context,
                  '!สถานะคำสั่งซื้อ ' +
                      listord.orderNo +
                      '\r\nผิดพลาดกรุณาตรวจสอบ');
            }
          }
        } else {
          alertDialog(context, '!ไม่พบคำสั่งซื้อ ' + listord.orderNo);
        }
      });
    } catch (e) {
      alertDialog(context,
          '!ตรวจสอบสถานะคำสั่งซื้อไม่ได้\r\n(ไม่สามารถติดต่อ Serverได้)');
    }
  }

  Future<Null> cancelOrder(OrderModel listord) async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/setOrderStatus.aspx?mbordid=' +
        listord.mbordid +
        '&ccode=' +
        listord.ccode +
        '&mbid=' +
        listord.mbid +
        '&olid=' +
        listord.olid +
        '&reason=' +
        txtReason +
        '&shopname=' +
        listord.shopName +
        '&orderno=' +
        listord.orderNo;
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        checkCancelStatus(listord);
      } else {
        alertDialog(context, response.toString());
      }
    } catch (e) {
      alertDialog(context, '!ยกเลิกคำสั่งซื้อไม่สำเร็จ');
    }
  }

  Future<Null> confirmCancel(OrderModel listord) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Center(
            child: MyStyle().txtstyle(
                'ยกเลิกคำสั่งซื้อ:${listord.orderNo} ?', Colors.red, 12.0)),
        children: <Widget>[
          Column(
            children: [inputReason()],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                          width: screen * 0.28,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: MyStyle().titleCenter(
                              context, 'ยกเลิก', 12.0, Colors.black))),
                  TextButton(
                      onPressed: () async {
                        if (txtReason?.isEmpty ?? true) {
                          alertDialog(context, '!กรุณาระบุเหตผล');
                        } else {
                          Navigator.pop(context);
                          cancelOrder(listord);
                        }
                      },
                      child: Container(
                          width: screen * 0.28,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.redAccent[700],
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: MyStyle().titleCenter(
                              context, 'ยืนยัน', 12.0, Colors.white))),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget inputReason() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.7,
            child: TextFormField(
              initialValue: ' ',
              onChanged: (value) => txtReason = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ระบุเหตผล',
                prefixIcon: Icon(Icons.note, color: MyStyle().darkcolor),
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
