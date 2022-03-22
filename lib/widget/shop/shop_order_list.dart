import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

class ShopOrderList extends StatefulWidget {
  @override
  _ShopOrderListState createState() => _ShopOrderListState();
}

class _ShopOrderListState extends State<ShopOrderList> {
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

  /* single check box */
  // var checkBox1Value = true;
  // var checkBox2Value = true;
  // var checkBox3Value = true;
  final double cboxScale = 2.5;
  var cboxValue = [true, true, true, true];

  var checkboxListlabels = [
    'ลูกค้า ส่งคำสั่งซื้อ', //status=0
    'ร้านค้า รับคำสั่งซื้อ', //status=1
    'Rider จองนำส่ง', //status=1 and rider=1
    'Rider ระหว่างนำส่ง' //status=5
  ];
  /* checkbox list
  Map<String, bool> checkboxListValues = {};
  */
  var isExpanH = false;
  _onExpanHChanged(bool val) {
    setState(() {
      isExpanH = val;
    });
  }

  @override
  void initState() {
    super.initState();
    findOrder();
  }

  String getCondition() {
    String condStr = '[Status] not in (3,9)';
    bool cbox0 = cboxValue[0];
    bool cbox1 = cboxValue[1];
    bool cbox2 = cboxValue[2];
    bool cbox3 = cboxValue[3];
    if (cbox0 == false && cbox1 == false && cbox2 == false && cbox3 == false) {
      condStr = '[Status] not in (0,1,3,5,9)';
    } else if (cbox0 == false &&
        cbox1 == false &&
        cbox2 == false &&
        cbox3 == true) {
      condStr += ' and [Status]=5';
    } else if (cbox0 == false &&
        cbox1 == false &&
        cbox2 == true &&
        cbox3 == false) {
      condStr += ' and ([Status]=1 and [riderStatus]=1)';
    } else if (cbox0 == false &&
        cbox1 == false &&
        cbox2 == true &&
        cbox3 == true) {
      condStr += ' and ([Status]=5 or ([Status]=1 and [riderStatus]=1))';
    } else if (cbox0 == false &&
        cbox1 == true &&
        cbox2 == false &&
        cbox3 == false) {
      condStr += ' and [Status]=1';
    } else if (cbox0 == false &&
        cbox1 == true &&
        cbox2 == false &&
        cbox3 == true) {
      condStr += ' and [Status] in (1,5)';
    } else if (cbox0 == false &&
        cbox1 == true &&
        cbox2 == true &&
        cbox3 == false) {
      condStr += ' and ([Status]=1 or ([Status]=1 and [riderStatus]=1))';
    } else if (cbox0 == false &&
        cbox1 == true &&
        cbox2 == true &&
        cbox3 == true) {
      condStr += ' and ([Status] in (1,5) or ([Status]=1 and [riderStatus]=1))';
      //---------------------------
    } else if (cbox0 == true &&
        cbox1 == false &&
        cbox2 == false &&
        cbox3 == false) {
      condStr += ' and [Status]=0';
    } else if (cbox0 == true &&
        cbox1 == false &&
        cbox2 == false &&
        cbox3 == true) {
      condStr += ' and [Status] in (0,5)';
    } else if (cbox0 == true &&
        cbox1 == false &&
        cbox2 == true &&
        cbox3 == false) {
      condStr += ' and ([Status]=0 or ([Status]=1 and [riderStatus]=1))';
    } else if (cbox0 == true &&
        cbox1 == false &&
        cbox2 == true &&
        cbox3 == true) {
      condStr += ' and ([Status] in (0,5) or ([Status]=1 and [riderStatus]=1))';
    } else if (cbox0 == true &&
        cbox1 == true &&
        cbox2 == false &&
        cbox3 == false) {
      condStr += ' and [Status] in (0,1)';
    } else if (cbox0 == true &&
        cbox1 == true &&
        cbox2 == false &&
        cbox3 == true) {
      condStr += ' and [Status] in (0,1,5)';
    } else if (cbox0 == true &&
        cbox1 == true &&
        cbox2 == true &&
        cbox3 == false) {
      condStr += ' and ([Status] in (0,1) or ([Status]=1 and [riderStatus]=1))';
    } else {
      //
    }
    return condStr;
  }

  //เอา mbid ไปหา cid(cid=resturantId)
  Future<Null> findOrder() async {
    listOrders.clear();
    String condStr = getCondition();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/getOrderList.aspx?resturantId=$mbid&condition=' +
        '$condStr&strorder=olid asc';

    //print('*** shop findOrder() $url ***'); //ถ้าไม่พิมม์ อาจจะ ไม่ทำงาน

    ttlVatAmount = 0;
    ttlLogist = 0;
    ttlNetAmount = 0;
    ttlGrsAmount = 0;
    ttlDiscount = 0;
    await Dio().get(url).then((value) {
      if (value != null && value.toString().toString() != '') {
        var result = json.decode(value.data);
        havedata = true;
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

  //shop/shopOrderListList.aspx?mbid=70&orderdate=20211114&condition=[Status]=0
  //DateTime now = DateTime.now();
  //createdDT= DateFormat('MM-dd-yyyy HH:mm:ss.ms').format(now); //'11/10/2021 08:44:00.000'

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [criteriaDate(), showData(context)]),
    ));
  }

  Container showData(BuildContext context) => Container(
          child: Column(children: [
        ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: listOrders.length,
            itemBuilder: (context, index) => Card(
                elevation: 5.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: orderData(index))),
        /*
      Divider(thickness: 2),
      GrsTotalWidget(
        netamount: ttlNetAmount,
        discount: ttlDiscount,
        vatamount: ttlVatAmount,
        logist: ttlLogist,
        grsamount: ttlGrsAmount
      )
      */
      ]));

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
          orderFooter(index),
          orderStep(index),
          orderAction(index),
          SizedBox(height: 5),
        ],
      )
    ]);
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
  /*
  StepsIndicator(
  selectedStep: 1,
  nbSteps: 4,
  selectedStepColorOut: Colors.blue,
  selectedStepColorIn: Colors.white,
  doneStepColor: Colors.blue,
  doneLineColor: Colors.blue,
  undoneLineColor: Colors.red,
  isHorizontal: true,
  lineLength: 40,
  doneStepSize: 10,
  unselectedStepSize: 10,
  selectedStepSize: 14,
  selectedStepBorderSize: 1,
  doneStepWidget: Container(), // Custom Widget 
  unselectedStepWidget: Container(), // Custom Widget 
  selectedStepWidget: Container(), // Custom Widget 
  lineLengthCustomStep: [
    StepsIndicatorCustomLine(nbStep: 3, length: 80)
  ],
  enableLineAnimation: true,
  enableStepAnimation: true,
)
  */

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

  Column orderAction(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            (listOrders[index].odStatus == '0')
                ? cancelAction(index)
                : Container(),
            (listOrders[index].odStatus == '0')
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: reciveAction(index),
                  )
                : Container(),
            (listOrders[index].odStatus == '1' &&
                    listOrders[index].rdStatus == '1')
                ? buildRider(index)
                : Container(),
            (listOrders[index].odStatus == '1')
                ? Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: buildCustom(index))
                : Container()
          ],
        ),
      ],
    );
  }

  Column orderFooter(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: MyStyle().txtbody('มูลค่าสินค้า')),
              Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyStyle().txtblack17TH(MyCalculate().fmtNumber(
                          double.parse(listOrders[index].ttlNetAmount))),
                    ],
                  )),
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: MyStyle().txtbody('ส่วนลด'),
                  )),
              Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyStyle().txtblack17TH(MyCalculate().fmtNumber(
                          double.parse(listOrders[index].ttlDiscount))),
                    ],
                  )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(flex: 2, child: MyStyle().txtbody('ภ.มูลค่าเพิ่ม')),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().txtblack17TH(MyCalculate().fmtNumber(
                        double.parse(listOrders[index].ttlVatAmount))),
                  ],
                )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: MyStyle().txtbody('ค่าขนส่ง'),
                )),
            Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().txtblack17TH(MyCalculate()
                        .fmtNumber(double.parse(listOrders[index].ttlLogist))),
                  ],
                )),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(flex: 4, child: MyStyle().txtbody('')),
            Expanded(
                flex: 2,
                child: MyStyle().txtstyle('มูลค่าสุทธิ์', Colors.red, 12)),
            Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyStyle().txtblack17TH(MyCalculate().fmtNumber(
                        double.parse(listOrders[index].ttlGrsAmount)))
                  ],
                )),
          ]),
        )
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
                                .fmtNumber(double.parse('${e.unitprice}'))),
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
                    '${listOrders[index].mbname} ${listOrders[index].contactphone}',
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
          margin: const EdgeInsets.only(left: 0),
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
          width: screen * 0.28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyStyle().txtstyle(
                listOrders[index].orderNo,
                Colors.black,
                10.5,
              ),
            ],
          ),
        ),
        Container(
          width: screen * 0.32,
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

  Widget criteriaDate() => Column(
        children: [
          ExpansionTile(
              onExpansionChanged: _onExpanHChanged,
              trailing: Switch(
                value: isExpanH,
                onChanged: (_) {},
              ),
              title: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyStyle().txtshadowsIntoLight('Order List.'),
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
              children: [
                Column(children: [
                  selectBox0(),
                  selectBox1(),
                  selectBox2(),
                  selectBox3(),
                ]
                    /*                     /*  sample check box ***** ตัวอย่าง ห้ามลบ ***** */
                      checkboxListlabels
                      .map((label) => 
                        Transform.scale(
                          scale: 1,
                          child: CheckboxListTile(                          
                            title: Text(label),
                            value: checkboxListValues[label] ?? true,
                            onChanged: (newValue) {
                              setState(() {
                                if (checkboxListValues[label] == null) {
                                  checkboxListValues[label] = true;
                                }
                                checkboxListValues[label] = !checkboxListValues[label];
                              });
                            },
                          )
                        )      
                      ).toList()  
                      */
                    ),
              ]),
        ],
      );

  Padding selectBox3() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyStyle().txtblack18TH(checkboxListlabels[3]),
          SizedBox(width: 5),
          Transform.scale(
            scale: cboxScale,
            child: Checkbox(
              activeColor: Colors.black,
              tristate: false,
              value: cboxValue[3] ?? true,
              splashRadius: 30,
              onChanged: (newValue) {
                setState(() {
                  cboxValue[3] = !cboxValue[3];
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding selectBox2() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyStyle().txtblack18TH(checkboxListlabels[2]),
          SizedBox(width: 5),
          Transform.scale(
            scale: cboxScale,
            child: Checkbox(
              activeColor: Colors.black,
              tristate: false,
              value: cboxValue[2] ?? true,
              splashRadius: 30,
              onChanged: (newValue) {
                setState(() {
                  cboxValue[2] = !cboxValue[2];
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding selectBox1() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyStyle().txtblack18TH(checkboxListlabels[1]),
          SizedBox(width: 5),
          Transform.scale(
            scale: cboxScale,
            child: Checkbox(
              activeColor: Colors.black,
              tristate: false,
              value: cboxValue[1] ?? true,
              splashRadius: 30,
              onChanged: (newValue) {
                setState(() {
                  cboxValue[1] = !cboxValue[1];
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding selectBox0() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyStyle().txtblack18TH(checkboxListlabels[0]),
          SizedBox(width: 5),
          Transform.scale(
            scale: cboxScale,
            child: Checkbox(
              activeColor: Colors.black,
              tristate: false,
              value: cboxValue[0] ?? true,
              splashRadius: 30,
              onChanged: (newValue) {
                setState(() {
                  cboxValue[0] = !cboxValue[0];
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /*
  List<Widget> checkboxList() {
    return checkboxListlabels
        .map((label) => CheckboxListTile(
              title: Text(label),
              value: checkboxListValues[label] ?? false,
              onChanged: (newValue) {
                setState(() {
                  if (checkboxListValues[label] == null) {
                    checkboxListValues[label] = true;
                  }
                  checkboxListValues[label] = !checkboxListValues[label];
                });
              },
            ))
        .toList();
  }
  */

  FloatingActionButton cancelAction(int index) {
    return FloatingActionButton.extended(
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
          findOrder();
        });
      },
    );
  }

  FloatingActionButton reciveAction(int index) {
    return FloatingActionButton.extended(
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
    );
  }

  Container buildRider(int index) {
    return Container(
        child: Column(
      children: [
        MyStyle().txtTH18Dark(
            listOrders[index].ridercode + ' ' + listOrders[index].ridername),
        Container(
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://www.${MyConstant().domain}/${MyConstant().memberimagepath}/${listOrders[index].riderpict}'),
            radius: 38,
          ),
        ),
        SizedBox(height: 3),
        FloatingActionButton.extended(
            label: Text('นำส่ง',
                style: TextStyle(
                    fontFamily: 'thaisanslite',
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.white)),
            icon: Icon(Icons.delivery_dining),
            backgroundColor: Colors.black,
            onPressed: () async {
              riderOrder(listOrders[index]);
            }),
      ],
    ));
  }

  Container buildCustom(int index) {
    return Container(
        child: Column(
      children: [
        MyStyle().txtstyle(listOrders[index].mbcode, Colors.redAccent[700], 14),
        Container(
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://www.${MyConstant().domain}/${MyConstant().memberimagepath}/${listOrders[index].mbpict}'),
            radius: 38,
          ),
        ),
        SizedBox(height: 3),
        FloatingActionButton.extended(
          label: Text('ลูกค้ารับ',
              style: TextStyle(
                  fontFamily: 'thaisanslite',
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.white)),
          icon: Icon(
            Icons.face_retouching_natural,
            color: Colors.white,
          ),
          backgroundColor: MyStyle().primarycolor, //Colors.lime[700],
          onPressed: () async {
            finishOrder(listOrders[index]);
          },
        )
      ],
    ));
  }

  Future<Null> riderOrder(OrderModel listord) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String resturantId = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/setStatusRider.aspx?mbordid=' +
        listord.mbordid +
        '&resturantId=' +
        resturantId +
        '&ccode=' +
        listord.ccode +
        '&olid=' +
        listord.olid;
    try {
      Response response = await Dio().get(url);
      if (response != null && response.toString() != '') {
        alertDialog(context, response.toString());
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            InfoSnackBar.infoSnackBar(
                'Rider รับนำส่ง:' + listord.orderNo, Icons.delivery_dining),
          );
        setState(() {
          findOrder();
        });
      }
    } catch (e) {
      alertDialog(context, '!ติดต่อServer ไม่ได้');
    }
  }

  Future<Null> finishOrder(OrderModel listord) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String resturantId = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/setStatusFinish.aspx?mbordid=' +
        listord.mbordid +
        '&resturantId=' +
        resturantId +
        '&ccode=' +
        listord.ccode +
        '&olid=' +
        listord.olid +
        '&remark=ลูกค้ามารับเอง';
    try {
      Response response = await Dio().get(url);
      if (response != null && response.toString() != '') {
        alertDialog(context, response.toString());
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            InfoSnackBar.infoSnackBar(
                'จบคำสั่งซื้อ:' + listord.orderNo, Icons.favorite),
          );
        setState(() {
          findOrder();
        });
      }
    } catch (e) {
      alertDialog(context, '!ติดต่อServer ไม่ได้');
    }
  }

  Future<Null> reciveOrder(OrderModel listord) async {
    //mbid =  mbid ของ Customer
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/setOrderStatus.aspx?mbordid=' +
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
                  'รับคำสั่งซื้อ:' + '${listord.orderNo}',
                  'ร้าน:' + listord.shopName);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'รับคำสั่งซื้อ:' + listord.orderNo, Icons.mark_chat_read),
                );
              setState(() {
                findOrder();
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
                  '*ยกเลิก*คำสั่งซื้อ:' + '${listord.orderNo}',
                  'จากร้าน:' + listord.shopName);
              // Toast.show('ยกเลิกคำสั่งซื้อ:' + listord.orderNo + ' เรียบร้อย',
              //     context);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'ยกเลิกคำสั่งซื้อ:' + listord.orderNo, Icons.cancel),
                );
              setState(() {
                findOrder();
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
