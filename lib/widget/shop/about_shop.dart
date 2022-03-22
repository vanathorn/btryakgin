import 'package:flutter/material.dart';
//vtr after upgrade import 'package:flutter/rendering.dart';
import 'package:yakgin/model/account_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/screen/shop/shop_location.dart';
import 'package:yakgin/state/accbk_detail_state.dart';
import 'package:yakgin/state/accbk_list_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';

class AboutShop extends StatefulWidget {
  final ShopRestModel restModel;
  AboutShop({Key key, this.restModel}) : super(key: key);
  @override
  _AboutShopState createState() => _AboutShopState();
}

class _AboutShopState extends State<AboutShop> {
  ShopRestModel restModel;
  double screen, lat1, lng1, latShop, lngShop, distance;
  String strDistance;
  Location location = Location();
  final int startLogist = 30;
  int logistCost;
  // final iswebMobile = kIsWeb &&
  //     (defaultTargetPlatform == TargetPlatform.iOS ||
  //         defaultTargetPlatform == TargetPlatform.android);

  ShopRestModel shopModel = new ShopRestModel();
  var isExpanAcc = false;
  AccbkListStateController listStateController;
  List<AccountModel> listAccbks = List<AccountModel>.empty(growable: true);
  AccbkDetailStateController foodController =
      Get.put(AccbkDetailStateController());

  _onExpanAccChanged(bool val) {
    setState(() {
      isExpanAcc = val;
    });
  }

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    findLat1Lng1();
    listStateController = Get.put(AccbkListStateController());
  }

  Future<Null> findLat1Lng1() async {
    LocationData locationData;
    try {
      locationData = await MyCalculate().findLocationData();
      lat1 = locationData.latitude;
      lng1 = locationData.longitude;
    } catch (ex) {
      lat1 = 0;
      lng1 = 0;
    }
    listAccbks.clear();
    lat1 = locationData.latitude;
    lng1 = locationData.longitude;

    latShop = double.parse(restModel.lat);
    lngShop = double.parse(restModel.lng);
    distance = MyCalculate().calculateDistance(lat1, lng1, latShop, lngShop);
    var myFmt = NumberFormat('##0.0#', 'en_US');
    strDistance = myFmt.format(distance);
    logistCost = MyCalculate().calculateLogistic(distance, startLogist);
    var straccbank = restModel.banklist.split('*').toList();
    for (int i = 0; i < straccbank.length; i++) {
      var tmp = straccbank[i].split("|");
      listAccbks.add(AccountModel(
          restModel.ccode, tmp[0], tmp[1], tmp[2], tmp[3], tmp[4]));
    }
    setState(() {
      shopModel.restaurantId = restModel.restaurantId;
      shopModel.ccode = restModel.ccode;
      shopModel.account = listAccbks.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: restModel == null
          ? MyStyle().showProgress()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(
                      children: [
                        Container(
                          margin:
                              const EdgeInsets.only(top: 5, bottom: 0, left: 3),
                          width: 150,
                          height: 150,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                  'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${restModel.shoppict}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(
                          top: 3,
                          bottom: 3,
                        ),
                        //decoration: new BoxDecoration(color: Colors.grey[100]),
                        width: (screen - 155.0),
                        height: 150,
                        child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 3.0, top: 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              child: Icon(
                                            Icons.home,
                                            color: MyStyle().primarycolor,
                                          )),
                                          Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: MyStyle().txtstyle(
                                                      restModel.address,
                                                      Colors.black54,
                                                      11.0)))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                              child: Icon(
                                            Icons.mobile_friendly,
                                            color: MyStyle().primarycolor,
                                          )),
                                          Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 5.0, top: 8.0),
                                                  child: MyStyle().txtstyle(
                                                      restModel.phone,
                                                      Colors.blue[900],
                                                      15))),
                                        ],
                                      ),
                                      /*  
                                      Row(
                                        children: [
                                          (listAccbks.toList().length == 1) ?
                                            showAccount(0)
                                          : (listAccbks.toList().length == 2) ?
                                            showAccount(0)
                                          : Container()
                                        ],
                                      ),    
                                      Row(
                                        children: [
                                          (listAccbks.toList().length == 2) ?
                                            showAccount(1)
                                          : Container()
                                        ],
                                      ), 
                                      */
                                    ],
                                  ),
                                ),
                              ]),
                        )),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (listAccbks.length > 0) ? buildAccBank() : Container()
                    ],
                  ),
                  Row(
                    children: [
                      buildDistance(),
                      buildLogistic(),
                    ],
                  ),
                  (latShop == null && !kIsWeb)
                      ? MyStyle().showProgress()
                      : (!kIsWeb)
                          ? buildMap()
                          : Text(''),
                ],
              ),
            ),
    );
  }

  Container buildDistance() {
    return Container(
        width: screen * 0.5,
        child: (!kIsWeb)
            ? Stack(
                children: [
                  ListTile(
                      leading: Icon(Icons.directions_bike,
                          color: MyStyle().primarycolor),
                      title: MyStyle().txtbodyTH(
                          distance == null ? '' : '$strDistance กม.')),
                ],
              )
            : Text(''));
  }

  Container buildLogistic() {
    return Container(
        width: screen * 0.5,
        child: (!kIsWeb)
            ? Stack(
                children: [
                  ListTile(
                      leading: Icon(Icons.transfer_within_a_station,
                          color: MyStyle().primarycolor),
                      title: MyStyle().txtbodyTH(
                          logistCost == null ? '' : '$logistCost บาท')),
                ],
              )
            : Text(''));
  }

  Container buildAccBank() {
    listStateController = Get.find();
    listStateController.selectedAccount.value = shopModel;
    return Container(
        margin: const EdgeInsets.only(top: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: 5,
          child: Container(
              padding: EdgeInsets.all(0.0),
              width: screen * 0.975,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => ExpansionTile(
                      onExpansionChanged: _onExpanAccChanged,
                      trailing: Switch(
                        value: isExpanAcc,
                        onChanged: (_) {},
                      ),
                      title: MyStyle()
                          .txtstyle(accbank_WORD, Colors.redAccent[700], 14.0),
                      children: [
                        Column(
                          children: listStateController
                              .selectedAccount.value.account
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, bottom: 8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.account_box,
                                                color: Colors.black),
                                            SizedBox(width: 3),
                                            Container(
                                                width: screen * 0.45,
                                                child: MyStyle().txtstyle(
                                                    '${e.accno}',
                                                    Colors.red,
                                                    13.0)),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    left: 3.0),
                                                child: MyStyle().txtstyle(
                                                    '${e.bkname}',
                                                    Colors.black,
                                                    11.0))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: MyStyle().txtstyle(
                                                  '${e.accname}',
                                                  Colors.black,
                                                  12.0),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  Container showAccount(int index) {
    return Container(
      child: Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.account_box, color: Colors.black),
                Container(
                    width: screen * 0.28,
                    child: MyStyle().txtstyle(
                        '${listAccbks.toList()[index].accno}',
                        Colors.red,
                        14.0)),
                Container(
                    //width:screen*0.2,
                    margin: const EdgeInsets.only(left: 5.0),
                    child: MyStyle().txtstyle(
                        '${listAccbks.toList()[index].bkname}',
                        Colors.black,
                        13.0))
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: MyStyle().txtstyle(
                      '${listAccbks.toList()[index].accname}',
                      Colors.black,
                      13.0),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget showImage() => Container(
        margin: EdgeInsets.only(top: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //image picture
            Container(
                width: screen * 0.4,
                child: (restModel.shoppict != null)
                    ? Image.network(
                        'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${restModel.shoppict}')
                    : Image.network(
                        'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/photo256.png')),
          ],
        ),
      );

  Widget showName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextFormField(
              initialValue: restModel.thainame,
              enableInteractiveSelection: false, // will disable paste operation
              focusNode: new AlwaysDisabledFocusNode(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ชื่อร้าน',
                prefixIcon: Icon(Icons.house, color: MyStyle().darkcolor),
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

  // Container showMap() {
  //   return Container(
  //     child: (latShop == null) ? MyStyle().showProgress() : buildMap(),
  //   );
  // }

  Container buildMap() {
    LatLng latLng = LatLng(latShop, lngShop);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 11.0);
    return Container(
      margin: EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 2),
      height: 325,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        markers: markerSet(),
        onMapCreated: (controller) {},
      ),
    );
  }

  Set<Marker> markerSet() {
    return <Marker>[userMarker(), shopMarker()].toSet();
  }

  Marker shopMarker() {
    return Marker(
      markerId: MarkerId('shopmarker'),
      position: LatLng(latShop, lngShop),
      icon: BitmapDescriptor.defaultMarkerWithHue(10.0),
      infoWindow: InfoWindow(
          title: 'ร้านของ ${restModel.thainame}',
          snippet: 'ละติจูต=$latShop, ลองติจูต=$lngShop'),
    );
  }

  Marker userMarker() {
    return Marker(
      markerId: MarkerId('usermarker'),
      position: LatLng(lat1, lng1),
      icon: BitmapDescriptor.defaultMarkerWithHue(150.0),
      infoWindow: InfoWindow(
          title: 'คุณอยู่ที่นี่', snippet: 'ละติจูต=$lat1, ลองติจูต=$lng1'),
    );
  }
}
