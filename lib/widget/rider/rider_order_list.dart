import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/count_model.dart';
import 'package:btryakgin/model/reserve_model.dart';
import 'package:btryakgin/model/rider_model.dart';
import 'package:btryakgin/model/rider_order.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/utility/myutil.dart';
import 'package:btryakgin/widget/infosnackbar.dart';
import 'package:get/get.dart' as dget;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiderOrderList extends StatefulWidget {
  @override
  _RiderOrderListState createState() => _RiderOrderListState();
}

class _RiderOrderListState extends State<RiderOrderList> {
  bool havedata = true;
  String mbid, strDistanceR;
  double screen, lat1, lng1, latShop, lngShop, distanceR;
  final MainStateController mainStateController = dget.Get.find();

  List<RiderModel> listOrders = List<RiderModel>.empty(growable: true);
  List<RiderOrderModel> listDetails =
      List<RiderOrderModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getRiderLocation(); //ได้ Rider's current location  lat1,lng1
    findOrder();
  }

  Future<Null> countOrderNo() async {
    String url =
        '${MyConstant().domain}/${MyConstant().apipath}/rider/countOrdRider.aspx';
    //&condition=convert(varchar,OrderDate,112)='20211127';
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          CountModel mModel = CountModel.fromJson(map);
          setState(() {
            mainStateController.selectedRestaurant.value.cntord =
                int.parse(mModel.cnt);
          });
        }
      }
    });
  }

  Future<Null> findOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().domain}/${MyConstant().apipath}' +
        '/rider/riderOrderList.aspx';
    //[Status]=1 and riderid=0
    listOrders.clear();
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null) {
        var myFmt = NumberFormat('##0.0#', 'en_US');
        for (var map in result) {
          setState(() {
            RiderModel mModel = RiderModel.fromJson(map);

            latShop = double.parse(mModel.latShop);
            lngShop = double.parse(mModel.lngShop);
            distanceR =
                MyCalculate().calculateDistance(lat1, lng1, latShop, lngShop);
            strDistanceR = myFmt.format(distanceR);
            mModel.distianceR = strDistanceR;

            listDetails.clear();
            var detailList = mModel.detailList.split('*').toList();
            // olid +"|" + orderNo + "|" + ttlNetAmount + "|" + ttlGrsAmount + "|" + ttlitem + "|" + lat + "|" + lng + "|" + distiance + "|" + booktime;
            for (int i = 0; i < detailList.length; i++) {
              var tmp = detailList[i].split("|");
              listDetails.add(RiderOrderModel(
                  (i + 1).toString(),
                  tmp[0],
                  tmp[1],
                  double.parse(tmp[2]),
                  double.parse(tmp[3]),
                  tmp[5],
                  tmp[6],
                  tmp[7],
                  tmp[8]));
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

  Future<Null> getRiderLocation() async {
    LocationData locationData = await MyCalculate().findLocationData();
    setState(() {
      lat1 = locationData.latitude;
      lng1 = locationData.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    /*
    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 3, right: 3, top: 2),
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyStyle().txtTitle("Order for Booking."),
              FloatingActionButton.extended(
                backgroundColor: Colors.lightGreenAccent[700],
                onPressed: findOrder,
                label: Text('ปัจจุบัน/ค้นหา',
                    style: TextStyle(
                      fontFamily: 'thaisanslite',
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    )),
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 46),
          child: 
            listOrders == null ? MyStyle().showProgress() : showData(context)          
        )
      ],
    );
    */
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [searchButton(), showData(context)]),
    ));
  }

  Widget searchButton() => Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyStyle().txtTitle("Order for Booking."),
            FloatingActionButton.extended(
              backgroundColor: Colors.lightGreenAccent[700],
              onPressed: findOrder,
              label: Text('ปัจจุบัน',
                  style: TextStyle(
                    fontFamily: 'thaisanslite',
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  )),
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
      ]);

  Container showData(BuildContext context) => Container(
        child: Column(
          children: [
            //Expanded(
            //child:
            ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: listOrders.length,
                itemBuilder: (context, index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: screen * 0.7,
                                margin: const EdgeInsets.only(left: 3),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      MyStyle().txtstyle(
                                          listOrders[index].shopName,
                                          Colors.blueAccent[700],
                                          15),
                                      SizedBox(width: 8),
                                      MyStyle()
                                          .txtbody(listOrders[index].shopPhone),
                                    ])),
                            Container(
                              width: screen * 0.25,
                              margin: const EdgeInsets.only(right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MyStyle().txtbody(
                                      '${listOrders[index].distianceR} กม.')
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 5, top: 3, bottom: 3),
                          child: SingleChildScrollView(
                            child: MyStyle()
                                .txtbody(listOrders[index].shopAddress),
                          ),
                        ),
                        headTable(),
                        detailTable(index),
                        Divider(thickness: 2),
                        SizedBox(height: 15)
                      ],
                    ))
          ],
        ),
      );

  Container detailTable(int index) {
    return Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: listOrders[index].orddtl.toList().length,
            itemBuilder: (context, index2) => Column(children: <Widget>[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(
                      children: [
                        Container(
                          margin:
                              const EdgeInsets.only(top: 5, bottom: 0, left: 0),
                          width: screen * 0.73,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: detailRow1(index2, index),
                              ),
                              //detailRow2(index, index2)
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(
                          left: 0,
                          top: 5,
                          bottom: 5,
                        ),
                        width: screen * 0.23,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton.extended(
                                label: MyStyle()
                                    .txtstyle('Book', Colors.white, 11),
                                icon: Icon(Icons.shop),
                                onPressed: () async {
                                  reserveOrder(listOrders[index],
                                      listOrders[index].orddtl[index2]);
                                },
                              ),
                            ])),
                  ])
                ])));
  }

  Row detailRow2(int index, int index2) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Expanded(
          flex: 2,
          child: MyStyle().txtstyle(
              '  ' +
                  MyCalculate().fmtNumberBath(double.parse(
                      '${listOrders[index].orddtl[index2].ttlGrsAmount}')),
              Colors.black,
              11)),
      Expanded(
        flex: 1,
        child: MyStyle().txtstyle(
            '${listOrders[index].orddtl[index2].booktime}',
            Colors.redAccent[700],
            11),
      ),
      Expanded(
        flex: 1,
        child: Text(''),
      ),
    ]);
  }

  Row detailRow1(int index2, int index) {
    return Row(children: [
      Expanded(
          flex: 2,
          child: MyStyle().txtblack14TH(
              '${index2 + 1} ${listOrders[index].orddtl[index2].orderNo}')),
      Expanded(
          flex: 2,
          child: rowAlignRight(
              '${listOrders[index].orddtl[index2].distiance} กม.')),
      Expanded(
        flex: 1,
        child: MyStyle().txtstyle(
            '  ${listOrders[index].orddtl[index2].booktime}',
            Colors.redAccent[700],
            10),
      ),
    ]);
  }

  Container headTable() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: MyStyle().primarycolor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: rowAlignCenter('คำสั่งซื้อ')),
          Expanded(flex: 1, child: MyStyle().txtblack14TH('ระยะทาง')),
          Expanded(flex: 1, child: MyStyle().txtblack14TH('ส่งเวลา')),
          Expanded(flex: 1, child: rowAlignCenter('จอง')),
          //Expanded( flex: 3, child: rowAlignRight(MyCalculate().fmtNumber(double.parse('${e.ttlNetAmount}')))),
        ],
      ),
    );
  }

  Future<Null> reserveOrder(RiderModel listord, RiderOrderModel orddtl) async {
    //mbid =  mbid ของ Customer
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String riderId = preferences.getString(MyConstant().keymbid);
    String riderName = preferences.getString(MyConstant().keymbname);

    String url = '${MyConstant().domain}/${MyConstant().apipath}' +
        '/rider/reserveOrder.aspx?resturantId=' +
        listord.restaurantId +
        '&ccode=' +
        listord.ccode +
        '&olid=' +
        orddtl.olid +
        '&riderId=' +
        riderId;
    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null && result.toString() != '') {
          for (var map in result) {
            ReserveModel rModel = ReserveModel.fromJson(map);
            //print('******* rModel.orderNo=${rModel.orderNo}   rModel.riderId=${rModel.riderId}  ****');
            if (rModel.orderNo == orddtl.orderNo && rModel.riderId == riderId) {
              MyUtil().sendNoticToShop(
                  listord.restaurantId,
                  'จองนำส่งคำสั่งซื้อ:' + '${orddtl.orderNo}',
                  'ชื่อผู้จองนำส่ง:' + riderName);
              // Toast.show(
              //     'จองนำส่ง คำสั่งซื้อ:' + '${orddtl.orderNo}' + ' สำเร็จ',
              //     context);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'จองนำส่ง คำสั่งซื้อ:' + '${orddtl.orderNo}' + ' สำเร็จ',
                      Icons.delivery_dining),
                );
            } else {
              alertDialog(context,
                  '!คำสั่งซื้อ: ${orddtl.orderNo} ถูกจองก่อนหน้านี้แล้ว\r\n(!จอง *ไม่*สำเร็จ)');
            }
            setState(() {
              findOrder();
            });
            //MaterialPageRoute route = MaterialPageRoute(builder: (context) => MainRider());
            //Navigator.push(context, route);
          }
        } else {
          alertDialog(context, '!จอง *ไม่*สำเร็จ');
        }
      });
    } catch (e) {
      alertDialog(context, '!ติดต่อServer ไม่ได้');
    }
  }

  /*
  Future<Null> checkReserve(RiderModel listord) async {
    String url =
        '${MyConstant().domain}/${MyConstant().apipath}/shop/checkOrdStatus.aspx?ccode=' +
            listord
                .ccode; // +'&olid='+listord.olid+'&orderno='+listord.orderNo;
    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null) {
          for (var map in result) {
            StatusModel mModel = StatusModel.fromJson(map);
            if (mModel.status == recive_order_status) {
              //MyUtil().sendNoticToCustRider(listord.mbid,'Reserve ส่งคำสั่งซื้อ:'+'${listord.orderNo}','ร้าน:'+listord.shopName);
              //Toast.show('Reserve ส่งคำสั่งซื้อ '+ listord.orderNo +' เรียบร้อย', context);
              setState(() {
                findOrder();
              });
            } else {
              //alertDialog(context, '!Reserve คำสั่งซื้อ '+listord.orderNo+'\r\nผิดพลาดกรุณาตรวจสอบ');
            }
          }
        } else {
          //alertDialog(context, '!ไม่พบคำสั่งซื้อ '+listord.orderNo);
        }
      });
    } catch (e) {
      alertDialog(context,
          '!ตรวจสอบสถานะคำสั่งซื้อไม่ได้\r\n(ไม่สามารถติดต่อ Serverได้)');
    }
  }
  */

  Widget rowAlignRight(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack14TH(txt)],
      );

  Widget rowAlignCenter(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
}
