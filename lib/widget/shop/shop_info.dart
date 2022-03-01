import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:btryakgin/model/shop_model.dart';
import 'package:btryakgin/screen/shop/shop_edit_info.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/widget/shop/shop_add_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ShopInfo extends StatefulWidget {
  @override
  _ShopInfoState createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  ShopModel shopModel;
  String ccode;
  String loginName;
  double screen, lat, lng;
  Completer<GoogleMapController> _controller = Completer();

  LocationData currentLocation;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    /*
    location.onLocationChanged.listen((event) {
      lat = event.latitude;
      lng = event.longitude;
    });*/
    getPreferences();
  }

  Future<Null> getPreferences() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      ccode = prefer.getString('pccode');
      readDataShop();
    });
  }

  Future<Null> readDataShop() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'checkShop.aspx?ccode=$ccode';

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      for (var map in result) {
        shopModel = ShopModel.fromJson(map);
        setState(() {
          lat = double.parse(shopModel.lat);
          lng = double.parse(shopModel.lng);
        });
      }
    });
  }

  void routeToShopInfo() {
    Widget widget = shopModel.thainame.isEmpty ? ShopAddInfo() : ShopEditInfo();
    MaterialPageRoute mpageRoute = MaterialPageRoute(
      builder: (context) => widget,
    );
    Navigator.push(context, mpageRoute);
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        shopModel == null
            ? MyStyle().showProgress()
            : shopModel.thainame.isEmpty
                ? showNoData(context)
                : showShopData(context),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton.extended(
                  backgroundColor: Colors.lightGreenAccent[700],
                  onPressed: routeToShopInfo,
                  label: Text('แก้ไข',
                      style: TextStyle(
                        fontFamily: 'thaisanslite',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      )),
                  icon: Icon(Icons.edit, color: Colors.black),
                  splashColor: Colors.cyanAccent[400],
                  foregroundColor: Colors.white,
                  hoverColor: Colors.red,
                  focusColor: Colors.red,
                ),
              ],
            ),
          ],
        )
        /*
          : SingleChildScrollView(
              child: 
                Column(
                    children: <Widget> [                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 0, left: 3),
                                width:150, height: 150,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network('${MyConstant().domain}/${MyConstant().shopimagepath}/${shopModel.shoppict}')
                                  ]
                                ),
                              ),
                            ],
                          ), 
                          Container(
                            margin: const EdgeInsets.only(top: 3, bottom: 3,),
                            width: (screen - 155.0), height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [                              
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3.0, top: 0),
                                    child: 
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                child: Icon(Icons.home, color: MyStyle().primarycolor,)),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(left:5.0),
                                                  child: 
                                                  Column(
                                                    children: [
                                                      //Row(children:<Widget>[MyStyle().titleCenterTH(context, 'ที่อยู่ร้าน ${shopModel.thainame}', 18, Colors.blue)]),
                                                      Row(children:<Widget>[Expanded(child: Text(shopModel.address))]),                    //
                                                    ],
                                                  ),                                                  
                                                )
                                              )                                          
                                            ],                                    
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                child: Icon(Icons.mobile_friendly, color: MyStyle().primarycolor,)),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(left:5.0),
                                                  child: 
                                                  Column(
                                                    children: [                //
                                                      Row(children:<Widget>[Text(shopModel.phone)]),
                                                    ],
                                                  ),                                                  
                                                )
                                              )                                          
                                            ],                                    
                                          ),
                                        ],
                                      ),
                                  ),
                                ]
                              ),
                            )
                          ),
                        ]
                      ),
                      Row(
                        children: [(lat == null) ? MyStyle().showProgress(): showMap()]                         
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FloatingActionButton.extended(                       
                            backgroundColor: Colors.greenAccent[700],
                            icon: Icon(Icons.near_me_disabled_outlined),
                            label: MyStyle().txtstyle('ตำแหน่งฉัน', Colors.black, 12),
                            onPressed: () {
                              _myLocation();
                            },
                          ),
                          FloatingActionButton(
                            child: Icon(Icons.edit),
                            onPressed: () {routeToShopInfo();}
                          ),
                        ],
                      )                                     
                    ],                                
                ),
            ),
          */
      ],
    );
  }

  Widget showNoData(BuildContext context) {
    return MyStyle().titleCenterTH(
        context, 'กรุณาใส่ข้อมูลร้านค้าของคุณ', 20, Colors.black);
  }

  Widget showShopData(BuildContext context) => Column(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                top: 5, bottom: 0, left: 3),
                            width: (!kIsWeb) ? 150 : 300,
                            height: (!kIsWeb) ? 150 : 300,
                            child: Stack(fit: StackFit.expand, children: [
                              Image.network(
                                  '${MyConstant().domain}/${MyConstant().shopimagepath}/${shopModel.shoppict}')
                            ]),
                          ),
                        ],
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 3, bottom: 3),
                          width: (!kIsWeb)
                              ? (screen - 155.0)
                              : (screen - screen * 0.65),
                          height: (!kIsWeb) ? 150 : 300,
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: (!kIsWeb ? 3.0 : 30), top: 0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                child: Icon(
                                              Icons.home_work,
                                              color: MyStyle().primarycolor,
                                            )),
                                            Expanded(
                                                child: Container(
                                              margin:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Column(
                                                children: [
                                                  //Row(children:<Widget>[MyStyle().titleCenterTH(context, 'ที่อยู่ร้าน ${shopModel.thainame}', 18, Colors.blue)]),
                                                  Row(children: <Widget>[
                                                    Expanded(
                                                        child: Text(
                                                            shopModel.address))
                                                  ]), //
                                                ],
                                              ),
                                            ))
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
                                              margin:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Column(
                                                children: [
                                                  //
                                                  Row(children: <Widget>[
                                                    Text(shopModel.phone)
                                                  ]),
                                                ],
                                              ),
                                            ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ))
                    ]),
                Row(children: [
                  (lat == null && !kIsWeb)
                      ? MyStyle().showProgress()
                      : (!kIsWeb)
                          ? showMap()
                          : Text(''),
                ]),
                /*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FloatingActionButton.extended(                       
                            backgroundColor: Colors.greenAccent[700],
                            icon: Icon(Icons.near_me_disabled_outlined),
                            label: MyStyle().txtstyle('ตำแหน่งฉัน', Colors.black, 12),
                            onPressed: () {
                              _myLocation();
                            },
                          ),
                          FloatingActionButton(
                            child: Icon(Icons.edit),
                            onPressed: () {routeToShopInfo();}
                          ),
                        ],
                      ) */
              ],
            ),
          )
        ],
      );

  // Container showImage() {
  //   return Container(
  //     width: !kIsWeb ? (screen * 0.5):(screen * 0.75),
  //     height: !kIsWeb ? double.infinity : 200.0,
  //     margin: EdgeInsets.only(top: 2.0),
  //     child: Image.network(
  //         '${MyConstant().domain}/${MyConstant().shopimagepath}/${shopModel.shoppict}'),
  //   );
  // }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('shopmarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ร้านของ ${shopModel.thainame}',
            snippet: 'ละติจูต=$lat, ลองติจูต=$lng'),
        //onTap: () => _openOnGoogleMapApp(lat, lng),
      )
    ].toSet();
  }

  //_openOnGoogleMapApp(double latitude, double longitude) async {
  //String googleUrl =
  //'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  //if (await canLaunch(googleUrl)) {
  //await launch(googleUrl);
  //} else {
  // Could not open the map.
  //}
  //}

  Container showMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15.0);
    return Container(
      margin: EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 2),
      height: 350,
      width: screen * 0.98,
      child: GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        markers: shopMarker(),
        onMapCreated: (controller) {},
      ),
    );
  }

  /*
  Row addEditInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,//.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right:90.0, bottom: 15.0),
              child: FloatingActionButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    routeToShopInfo();
                  }),
            ),
          ],
        ),
      ],
    );
  }
  */

  Row myLocation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end, //.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 90.0, bottom: 15.0),
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.greenAccent[700],
                    icon: Icon(Icons.near_me_disabled_outlined),
                    label: MyStyle().txtstyle('ตำแหน่งฉัน', Colors.black, 12),
                    onPressed: () {
                      _myLocation();
                    })),
          ],
        ),
      ],
    );
  }

  // Future<Null> getLocation() async {
  // var location = Location();
  // var currentLocation = await location.getLocation();
  // print('lat=$currentLocation.latitude, lng=$currentLocation.longitude');
  // }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        alertDialog(context, 'PERMISSION_DENIED');
      }
      return null;
    }
  }

  Future _myLocation() async {
    GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 18,
    )));
  }
  /*
  Future<Null> _xmyLocation() async {
    LocationData locationData = await MyCalculate().findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
    
      LatLng latLng = LatLng(lat, lng);
      print('******** _myLocation $lat *******');
      CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 18.0);
      return Container(
        margin: EdgeInsets.only(top: 5, left: 15, right: 15),
        height: 300,
        child: GoogleMap(
          initialCameraPosition: cameraPosition,
          mapType: MapType.hybrid,
          //onMapCreated: (controller) {},
        ),
      );
    });
  }
  */

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } catch (ex) {
      return null;
    }
  }
}
