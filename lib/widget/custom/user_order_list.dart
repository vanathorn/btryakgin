import 'dart:convert';

import 'package:dio/dio.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';
import 'package:yakgin/model/br_item_model.dart';

import 'package:yakgin/model/order_detail_model.dart';
import 'package:yakgin/model/order_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/state/order_list_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/order/grs_total_widget.dart';

class UserOrderList extends StatefulWidget {
  @override
  _UserOrderListState createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  bool havedata = true, havebranch = true;
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
  List<BrItemModel> listBritems = List<BrItemModel>.empty(growable: true);
  var isExpan = false;

  OrderListStateController orderStateCtrl;

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
            listBritems.clear();
            //***** order detail
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
            //***** branch detail
            var britemList = mModel.britemList.split('*').toList();
            for (int i = 0; i < britemList.length; i++) {
              var tmp = britemList[i].split("|");
              listBritems.add(BrItemModel(
                  shopname: tmp[0],
                  branchname: tmp[1],
                  iname: tmp[2],
                  qty: double.parse(tmp[3]),
                  uname: tmp[5],
                  iid: int.parse(tmp[7]),
                  seq: (i + 1).toString()));
            }
            mModel.orddtl = listDetails.toList();
            mModel.brdtl = listBritems.toList();
            listOrders.add(mModel);
            ttlGrsAmount += double.parse(mModel.ttlGrsAmount);
            havedata = true;
            orderStateCtrl = dget.Get.put(OrderListStateController());
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
    orderStateCtrl = dget.Get.find(); //vtr
    orderStateCtrl.selectedOrder.value = listOrders[index];
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
        onExpansionChanged: (bool expanding) =>
            _onExpanChanged(expanding, index), //_onExpanChanged,
        trailing: Switch(
          value: isExpan,
          onChanged: (_) {},
        ),
        title: orderTitle(index),
        children: [
          orderDetail(index),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: orderFooter(index),
          ),
          orderStep(index),
          branchDetail(index),
        ],
      )
    ]);
  }

  //notuse now
  Column expandbranchDetail() {
    return Column(
        children: listBritems
            .map((e) => Padding(
                padding: const EdgeInsets.only(left: 8, right: 10, bottom: 8.0),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        flex: 4,
                        child: MyStyle().txtblack16TH('${e.shopname}')),
                    Expanded(
                        flex: 4,
                        child: MyStyle().txtTH(
                            '${e.seq}. ${e.iname}', MyStyle().primarycolor)),
                    Expanded(
                        flex: 1,
                        child: MyStyle()
                            .txtblack16TH('${MyCalculate().fmtNumber(e.qty)}')),
                    Expanded(
                        flex: 1, child: MyStyle().txtblack16TH('${e.uname}')),
                  ]),
                ])))
            .toList());
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
                MyStyle().txtblack12TH(MyConstant().step1),
                MyStyle().txtblack12TH(MyConstant().step2),
                MyStyle().txtblack12TH(MyConstant().step3),
                MyStyle().txtblack12TH(MyConstant().step4)
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

  Column branchDetail(int index) {
    return Column(
      children: listOrders[index]
          .brdtl
          .map((e) => Padding(
                padding: const EdgeInsets.only(left: 8, right: 10, bottom: 8.0),
                child: branchItems(e),
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
          width: screen * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  MyStyle().txtstyle(listOrders[index].strOrderDate,
                    Colors.redAccent[700], 11.0),
                  MyStyle().txtblack12TH(listOrders[index].ordTime)
                ],
              ),
            ],
          ),
        ),
        Container(          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyStyle().txtstyle(listOrders[index].orderNo, Colors.black, 10.0)
            ],
          ),
        ),
        Container(
          width: screen * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyStyle().txtstyle(
                MyCalculate().fmtNumberBath(
                    double.parse(listOrders[index].ttlGrsAmount)),
                Colors.black, 12.0
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

  Column branchItems(BrItemModel e) {
    return Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 4, child: MyStyle().txtblack16TH('${e.shopname}')),
          Expanded(
              flex: 4,
              child: MyStyle()
                  .txtTH('${e.seq}.${e.iname}', MyStyle().primarycolor)),
          Expanded(
              flex: 1,
              child:
                  MyStyle().txtblack16TH('${MyCalculate().fmtNumber(e.qty)}')),
          Expanded(flex: 1, child: MyStyle().txtblack16TH('${e.uname}')),
        ])
      ],
    );
  }

  _onExpanChanged(bool val, int index) {
    setState(() async {
      isExpan = val;
      //if (isExpan) {
      //String _olid = '${orderStateCtrl.selectedOrder.value.olid}';
      //await getItemBranch(listOrders[index].ccode, listOrders[index].olid);
      //}
    });
  }

  //not use now
  Future<Null> getItemBranch(String _ccode, String _olid) async {
    listBritems.clear();
    // String _ccode = '${orderStateCtrl.selectedOrder.value.ccode}';
    // String _olid = '${orderStateCtrl.selectedOrder.value.olid}';
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/custom/getItemByBranch.aspx?ccode=$_ccode&olid=$_olid';

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null) {
        String oldshop = '';
        int j = 0;
        for (var map in result) {
          setState(() {
            BrItemModel mModel = BrItemModel.fromJson(map);
            if (mModel.shopname != oldshop) {
              oldshop = mModel.shopname;
              j = 1;
            } else {
              mModel.shopname = '';
            }
            mModel.seq = j.toString();
            listBritems.add(mModel);
            havebranch = true;
            j++;
          });
        }
      } else {
        setState(() {
          havebranch = false;
        });
      }
    });
  }
}
