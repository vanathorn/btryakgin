import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/delivery_model.dart';
import 'package:yakgin/model/rider_order.dart';
import 'package:yakgin/screen/rider/rider_location_screen.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/widget/infosnackbar.dart';
import 'package:get/get.dart' as dget;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiderOrderDelivery extends StatefulWidget {
  @override
  _RiderOrderDeliveryState createState() => _RiderOrderDeliveryState();
}

class _RiderOrderDeliveryState extends State<RiderOrderDelivery> {
  bool havedata = true;
  String riderId, txtName = '', txtPhone = '';
  double lat1 = 0.0, lng1 = 0.0;
  double screen,
      ttlDiscount,
      ttlVatAmount,
      ttlNetAmount,
      ttlLogist,
      ttlGrsAmount;
  final MainStateController mainStateController = dget.Get.find();

  List<DeliveryModel> listOrders = List<DeliveryModel>.empty(growable: true);
  List<RiderOrderModel> listDetails =
      List<RiderOrderModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getRiderLocation(); //ได้ Rider's current location  lat1,lng1
    findOrder();
  }

  Future<Null> getRiderLocation() async {
    LocationData locationData = await MyCalculate().findLocationData();
    setState(() {
      lat1 = locationData.latitude;
      lng1 = locationData.longitude;
    });
  }

  String getCondName() {
    String condStr = '';
    if (txtName != '') {
      condStr = txtName;
    }
    return condStr;
  }

  String getCondPhone() {
    String condStr = '';
    if (txtPhone != '') {
      condStr = txtPhone;
    }
    return condStr;
  }

  Future<Null> findOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    riderId = preferences.getString(MyConstant().keymbid);
    listOrders.clear();
    String condName = getCondName();
    String condPhone = getCondPhone();
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/rider/orderDelivery.aspx?riderId=$riderId&condition=' +
        '&condName=' +
        condName +
        '&condPhone=' +
        condPhone;

    //+&orderdate='yyyymmdd'

    listOrders.clear();
    String strDistanceR = '';
    double latcust = 0.0, lngcust = 0.0, distanceR = 0.0;
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null && result.toString() != '[]') {
        var myFmt = NumberFormat('##0.0#', 'en_US');
        for (var map in result) {
          setState(() {
            DeliveryModel mModel = DeliveryModel.fromJson(map);
            latcust = mModel.latCust;
            lngcust = mModel.lngCust;
            distanceR =
                MyCalculate().calculateDistance(lat1, lng1, latcust, lngcust);
            strDistanceR = myFmt.format(distanceR);
            mModel.distianceR = strDistanceR + ' กม.';
            mModel.latRider = lat1;
            mModel.lngRider = lng1;
            listOrders.add(mModel);
            havedata = true;
          });
        }
      } else {
        setState(() {
          txtName = '';
          txtPhone = '';
          havedata = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        criteriaData(),
        listOrders == null ? MyStyle().showProgress() : showData(context)
      ]),
    ));
  }

  Widget criteriaData() => Column(
        children: [
          ExpansionTile(
              title: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyStyle().txtshadowsIntoLight("Order Delivery."),
                    FloatingActionButton.extended(
                      backgroundColor: Colors.lightGreenAccent[700],
                      onPressed: findOrder,
                      label: Text('ค้นหา',
                          style: TextStyle(
                            fontFamily: 'thaisanslite',
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          )),
                      icon: Icon(Icons.refresh, color: Colors.white),
                      splashColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              children: [
                Column(children: [inputName(), inputPhone()]),
              ]),
        ],
      );

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.9,
            child: TextFormField(
              initialValue: ' ',
              onChanged: (value) => txtName = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ชื่อลูกค้า',
                prefixIcon: Icon(Icons.face_retouching_natural,
                    color: MyStyle().darkcolor),
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

  Widget inputPhone() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 8),
            width: screen * 0.9,
            child: TextFormField(
              initialValue: ' ',
              onChanged: (value) => txtPhone = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'เบอร์โทร',
                prefixIcon:
                    Icon(Icons.mobile_friendly, color: MyStyle().darkcolor),
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

  Container showData(BuildContext context) => Container(
          child: Column(children: [
        ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: listOrders.length,
          itemBuilder: (context, index) =>
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MyStyle().primarycolor,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage("images/wheatfilter.jpg"),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                  /*
                    gradient: RadialGradient(
                              center: Alignment(0, -0.33),
                              radius: 2,
                              colors: <Color>[Colors.white, MyStyle().lightcolor]),
                    */
                ),
                margin: const EdgeInsets.only(top: 3, bottom: 3),
                width: screen * 0.98,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 3.0, top: 0),
                          child: Column(
                            children: [
                              dataRow1(index),
                              dataRow2(index),
                              //x Divider(thickness: 1),
                            ],
                          )),
                      //x Divider(thickness: 1)
                    ],
                  ),
                ),
              ),
            ),
            /*
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                margin: const EdgeInsets.only(right: 3),
                width: screen * 0.22,
                child: Column(
                  children: [
                    FloatingActionButton(
                        child: Icon(Icons.delivery_dining),
                        onPressed: () {
                          sendOrderAction(listOrders[index]);
                        }),
                    (listOrders[index].bookTime != '')
                        ? MyStyle().txtblack16TH(
                            'เวลาส่ง ${listOrders[index].bookTime}')
                        : Text(''),
                  ],
                ),
              ),
            ]),
            */
          ]),
        ),
      ]));

  Row dataRow1(int index) {
    return Row(
      children: [
        Expanded(
            child: Container(
          margin: EdgeInsets.only(left: 5.0),
          child: Row(
            //mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            children: [
              MyStyle().txtstyle(
                  listOrders[index].custName, Colors.blueAccent[700], 14),
              SizedBox(width: 8.0),
              MyStyle().txtstyle(
                  listOrders[index].custPhone, Colors.redAccent[700], 14),
            ],
          ),
        ))
      ],
    );
  }

  Row dataRow2(int index) {
    return Row(
      children: [
        Expanded(
            child: Container(
                margin: EdgeInsets.only(left: 5.0),
                child: Column(
                  children: [
                    MyStyle().txtblack16TH(listOrders[index].custAddress),
                    dataBookTime(index),
                    dataRow3(index)
                  ],
                )))
      ],
    );
  }

  Row dataBookTime(int index) {
    return Row(
      children: [
        (listOrders[index].bookTime != '')
            ? MyStyle().txtblack16TH('เวลาส่ง ${listOrders[index].bookTime}')
            : Text(''),
      ],
    );
  }

  Row dataRow3(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (listOrders[index].latCust != 0 && listOrders[index].lngCust != 0)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    FloatingActionButton(
                        backgroundColor: Colors.redAccent[700],
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RiderLocationScreen(
                                      deliModel: listOrders[index])));
                        },
                        child: Icon(Icons.location_pin,
                            color: Colors.white, size: 32.0)),
                    Icon(
                      Icons.delivery_dining,
                      color: Colors.black,
                      size: 28,
                    ),
                    MyStyle().txtbodyTH('${listOrders[index].distianceR}'),
                  ],
                ),
              )
            : Container(child: SizedBox(height: 58)),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FloatingActionButton.extended(
            backgroundColor: Color.fromARGB(255, 26, 26, 199),
            label: MyStyle().txtstyle('ส่งสินค้า', Colors.white, 11),
            icon: Icon(Icons.fastfood),
            onPressed: () async {
              sendOrderAction(listOrders[index]);
            },
          ),
        ),
      ],
    );
  }

  Future<Null> sendOrderAction(DeliveryModel listord) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    riderId = preferences.getString(MyConstant().keymbid);
    String riderName = preferences.getString(MyConstant().keymbname);

    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/rider/sendDelivery.aspx?mbordid=' +
        listord.mbordid +
        '&ccode=' +
        listord.ccode +
        '&olid=' +
        listord.olid +
        '&riderId=' +
        riderId +
        '&restaurantId=' +
        listord.restaurantId +
        '&orderNo=' +
        listord.orderNo;
    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null && result.toString() != '') {
          for (var map in result) {
            DeliveryModel rModel = DeliveryModel.fromJson(map);
            if (rModel.olid == listord.olid &&
                rModel.orderNo == listord.orderNo &&
                rModel.riderId == riderId) {
              MyUtil().sendNoticToShop(
                  listord.restaurantId,
                  'นำส่งคำสั่งซื้อ:' + '${listord.orderNo}',
                  'ชื่อผู้นำส่ง:' + riderName);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'ส่งสินค้า คำสั่งซื้อ:' +
                          '${listord.orderNo}' +
                          ' สำเร็จ',
                      Icons.delivery_dining),
                );
            } else {
              alertDialog(context,
                  '!มีข้อผิดพลาด การนำส่งสินค้า คำสั่งซื้อ: ${listord.orderNo}\r\n(* ติดต่อร้านค้า *)');
            }
            setState(() {
              findOrder();
            });
          }
        } else {
          alertDialog(context, '!ส่งสินค้า *ไม่*สำเร็จ');
        }
      });
    } catch (e) {
      alertDialog(context, '!ติดต่อServer ไม่ได้');
    }
  }
}
