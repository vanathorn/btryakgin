import 'package:flutter/material.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ShopLocation extends StatefulWidget {
  final ShopRestModel restModels;
  ShopLocation({Key key, this.restModels}) : super(key: key);

  @override
  _ShopLocationState createState() => _ShopLocationState();
}

class _ShopLocationState extends State<ShopLocation> {
  ShopRestModel restModels;

  double lat, lng, screen;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    restModels = widget.restModels;
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    lat = double.parse(restModels.lat);
    lng = double.parse(restModels.lng);
    return Scaffold(
      appBar: AppBar(
        title: MyStyle()
            .txtTH('แสดงข้อมูลร้าน ${restModels.thainame}', Colors.white),
      ),
      body: restModels == null
          ? MyStyle().showProgress()
          : SingleChildScrollView(
              child: Column(
                children: [
                  showImage(),
                  inputName(),
                  iputAddress(),
                  inputMobile(),
                  (lat == null) ? MyStyle().showProgress() : buildMap(),
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
                width: screen * 0.65,
                child: (restModels.shoppict != null)
                    ? Image.network(
                        'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${restModels.shoppict}')
                    : Image.network(
                        'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/photo256.png')),
          ],
        ),
      );

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextFormField(
              initialValue: restModels.thainame,
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

  Widget iputAddress() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextFormField(
              initialValue: restModels.address,
              enableInteractiveSelection: false, // will disable paste operation
              focusNode: new AlwaysDisabledFocusNode(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ที่อยู่',
                prefixIcon:
                    Icon(Icons.location_city, color: MyStyle().darkcolor),
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

  Widget inputMobile() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextFormField(
              initialValue: restModels.phone,
              enableInteractiveSelection: false, // will disable paste operation
              focusNode: new AlwaysDisabledFocusNode(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ติดต่อร้าน',
                prefixIcon: Icon(Icons.phone, color: MyStyle().darkcolor),
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

  Container buildMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 11.0);
    return Container(
      margin: EdgeInsets.only(top: 8, left: 25, right: 25),
      height: 300,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        markers: shopMarker(),
        onMapCreated: (controller) {},
      ),
    );
  }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('shopmarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ร้านของ ${restModels.thainame}',
            snippet: 'ละติจูต=$lat, ลองติจูต=$lng'),
      )
    ].toSet();
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
