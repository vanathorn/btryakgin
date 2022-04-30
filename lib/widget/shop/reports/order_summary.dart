import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/sumdaily_detail_model.dart';
import 'package:yakgin/model/sumdaily_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/order/grs_total_widget.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';

class OrderSummary extends StatefulWidget {
  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  bool havedata = true;
  String mbid, txtReason;
  double screen,
      ttlDiscount,
      ttlVatAmount,
      ttlNetAmount,
      ttlLogist,
      ttlGrsAmount;
  List<SumDailyModel> listOrders = List<SumDailyModel>.empty(growable: true);
  List<SumDailyDetailModel> listDetails =
      List<SumDailyDetailModel>.empty(growable: true);
  final MainStateController mainStateController = dget.Get.find();

  final minDate = DateTime(
      DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  final maxDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    findOrder();
  }

  Future<Null> findOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences
        .getString(MyConstant().keymbid); //เอา mbid ไปหา cid(cid=resturantId)
    String sDate = mydate112(startDate);
    String eDate = mydate112(endDate);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/branch/getDailySumBr.aspx?mbid=$mbid&startdate=$sDate&enddate=$eDate';

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
            SumDailyModel mModel = SumDailyModel.fromJson(map);
            listDetails.clear();

            var detailList = mModel.detailList.split('*').toList();
            String orderNo = '';
            double amount; //, discount, free,
            double logist, netAmount, vatAmount, grsAmount;
            for (int i = 0; i < detailList.length; i++) {
              var tmp = detailList[i].split("|");
              orderNo = tmp[0];
              amount = double.parse(tmp[1]);
              //ttlDiscount = double.parse(tmp[2]);
              //ttlFree = double.parse(tmp[3]);
              logist = double.parse(tmp[4]);
              netAmount = double.parse(tmp[5]);
              vatAmount = double.parse(tmp[6]);
              grsAmount = double.parse(tmp[7]);
              listDetails.add(SumDailyDetailModel(
                mModel.restaurantId,
                (i + 1).toString(),
                orderNo,
                ttlAmount: amount.toStringAsFixed(2),
                ttlLogist: logist.toStringAsFixed(2),
                ttlNetAmount: netAmount.toStringAsFixed(2),
                ttlVatAmount: vatAmount.toStringAsFixed(2),
                ttlGrsAmount: grsAmount.toStringAsFixed(2),
              ));
              //ttlDiscount += double.parse(mModel.ttlDiscount);
              ttlLogist += logist;
              ttlNetAmount += netAmount;
              ttlVatAmount += vatAmount;
              ttlGrsAmount += grsAmount;
            }
            mModel.orddtl = listDetails.toList();
            listOrders.add(mModel);
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
    return Scaffold(
      body: Column(
        children: [
          criteriaDate(),
          listOrders == null
              ? MyStyle().showProgress()
              : (listOrders.length != 0)
                  ? dataSummary(context)
                  : Center(
                      child: MyStyle().titleCenterTH(
                          context,
                          (havedata) ? '' : 'ไม่มีคำสั่งซื้อตามเงื่อนไข}',
                          16,
                          Colors.red),
                    )
        ],
      ),
    );
  }

  Widget criteriaDate() => Column(
        children: [
          ExpansionTile(
              title: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyStyle().txtshadowsIntoLight('Order Summary'),
                    SizedBox(width: 10),
                    MyStyle().txtblack16TH('กำหนดวันที่'),
                  ],
                ),
              ),
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyStyle().txtblack16TH('เริ่มวันที่'),
                      ElevatedButton(
                          onPressed: () {
                            _openStartDatePicker(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyStyle().txtstyle(
                                  mydateFormat(
                                      '${startDate.toLocal()}'.split(' ')[0]),
                                  Colors.black,
                                  14),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                      MyStyle().txtblack16TH('ถึง'),
                      ElevatedButton(
                          onPressed: () {
                            _openEndDatePicker(context);
                          },
                          child: MyStyle().txtstyle(
                              mydateFormat(
                                  '${endDate.toLocal()}'.split(' ')[0]),
                              Colors.black,
                              14),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                    ],
                  ),
                ),
                Container(
                  child: findButton(),
                )
              ]),
        ],
      );

  Widget dataSummary(BuildContext context) => Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: listOrders.length,
              itemBuilder: (context, index) => Card(
                  elevation: 5.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  child: Column(children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: screen * 0.27,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MyStyle().txtstyle(
                                  listOrders[index].strorderDate,
                                  Colors.redAccent[700],
                                  11.0,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            //margin: const EdgeInsets.only(left: 5),
                            //width: screen * 0.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyStyle().txtblack12TH('มูลค่าสุทธิ์'),
                                    SizedBox(width: 5),
                                    MyStyle().txtstyle(
                                      MyCalculate().fmtNumberBath(double.parse(
                                          listOrders[index].ttlGrsAmount)),
                                      Colors.redAccent[700],
                                      12.0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().txtblack12TH(
                                    listOrders[index].ttlitem.toString() +
                                        ' รายการ'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    ExpansionTile(
                      title: Column(
                        children: [
                          Row(
                              //mainAxisAlignment:MainAxisAlignment.end,
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [rowHead('คำสั่งซื้อ')],
                                    )),
                                Expanded(flex: 3, child: rowHead('มูลค่า')),
                                Expanded(flex: 4, child: rowHead('ขนส่ง')),
                                Expanded(flex: 2, child: rowHead('ภษ.')),
                                Expanded(flex: 2, child: rowHead('สุทธิ')),
                              ])
                        ],
                      ),
                      children: [
                        //Divider(thickness: 1),
                        Column(
                          children: listOrders[index]
                              .orddtl
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 3, bottom: 5.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 4,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    MyStyle().txtstyle(
                                                      '${e.seq}. ${e.orderNo}',
                                                      Colors.black,
                                                      9.5,
                                                    )
                                                  ],
                                                )),
                                            Expanded(
                                                flex: 2,
                                                child: rowAlignRight(MyCalculate()
                                                    .fmtNumber(double.parse(
                                                        '${e.ttlNetAmount}')))),
                                            Expanded(
                                                flex: 2,
                                                child: rowAlignRight(
                                                    MyCalculate().fmtNumber(
                                                        double.parse(
                                                            '${e.ttlLogist}')))),
                                            Expanded(
                                                flex: 2,
                                                child: rowAlignRight(MyCalculate()
                                                    .fmtNumber(double.parse(
                                                        '${e.ttlVatAmount}')))),
                                            Expanded(
                                                flex: 3,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: MyStyle().txtstyle(
                                                          MyCalculate().fmtNumber(
                                                              double.parse(
                                                                  '${e.ttlGrsAmount}')),
                                                          Colors.black,
                                                          11),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    )
                  ]))),
          Divider(thickness: 2),
          /*
        Row(
          mainAxisAlignment: MainAxisAlignment.start,          
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: MyStyle().txtTitle('GRS Amount'),
            ),
          ],
        ),*/
          GrsTotalWidget(
              netamount: ttlNetAmount,
              discount: ttlDiscount,
              vatamount: ttlVatAmount,
              logist: ttlLogist,
              grsamount: ttlGrsAmount)
        ],
      );

  Widget rowHead(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack12TH(txt)],
      );

  Widget rowAlignRight(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack14TH(txt)],
      );

  String mydateFormat(String strdate) {
    String retDate = strdate.split('-')[2] +
        '/' +
        strdate.split('-')[1] +
        '/' +
        strdate.split('-')[0];
    return retDate;
  }

  String mydate112(DateTime dt) {
    String dd = (dt.day < 10) ? '0' + dt.day.toString() : dt.day.toString();
    String mm =
        (dt.month < 10) ? '0' + dt.month.toString() : dt.month.toString();
    String yyyy =
        (dt.year > 2500) ? (dt.year - 543).toString() : dt.year.toString();
    return yyyy + mm + dd;
  }

  _openStartDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate:
            DateTime(DateTime.now().year, DateTime.now().month, 1), //minDate,
        lastDate: maxDate);
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  _openEndDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate:
            DateTime(DateTime.now().year, DateTime.now().month, 1), //minDate,
        lastDate: maxDate);
    if (picked != null && picked != startDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Widget findButton() => Container(
      margin: const EdgeInsets.only(bottom: 3),
      width: screen * 0.97,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          findOrder();
        },
        icon: Icon(
          Icons.search,
          color: Colors.black,
          size: 32.0,
        ),
        label: MyStyle().txtstyle('ค้นหา', Colors.black, 14.0),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return Colors
                  .lightGreenAccent[700]; // Use the component's default.
            },
          ),
        ),
      ));
}
