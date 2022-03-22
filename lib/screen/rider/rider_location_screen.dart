import 'package:flutter/material.dart';
import 'package:yakgin/model/delivery_model.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class RiderLocationScreen extends StatefulWidget {
  final DeliveryModel deliModel;
  RiderLocationScreen({Key key, this.deliModel}) : super(key: key);
  @override
  _RiderLocationScreenState createState() => _RiderLocationScreenState();
}

class _RiderLocationScreenState extends State<RiderLocationScreen> {
  DeliveryModel deliModel;
  double screen, lat1, lng1;

  @override
  void initState() {
    super.initState();
    deliModel = widget.deliModel;
    findLatLngRider();
  }

  Future<Null> findLatLngRider() async {
    LocationData locationData = await MyCalculate().findLocationData();
    setState(() {
      deliModel.latRider = locationData.latitude;
      deliModel.lngRider = locationData.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: MyStyle().txtTH('ตำแหน่งลูกค้า และผู้ส่งสินค้า', Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildMap(),
          ],
        ),
      ),
    );
  }

  Container buildMap() {
    LatLng latLng = LatLng(deliModel.latCust, deliModel.lngCust);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 13.0);
    return Container(
      margin: EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 2),
      height: MediaQuery.of(context).size.height * 0.87,
      child: GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        markers: markerSet(),
        onMapCreated: (controller) {},
      ),
    );
  }

  Set<Marker> markerSet() {
    return <Marker>[riderMarker(), customMarker()].toSet();
  }

  Marker riderMarker() {
    return Marker(
      markerId: MarkerId('ridmarker'),
      position: LatLng(deliModel.latRider, deliModel.lngRider),
      icon: BitmapDescriptor.defaultMarkerWithHue(10.0),
      infoWindow: InfoWindow(
          title: 'คุณอยู่ที่นี่',
          snippet: 'ละติจูต=${deliModel.latRider.toString()},' +
              'ลองติจูต=${deliModel.lngRider}'),
    );
  }

  Marker customMarker() {
    return Marker(
      markerId: MarkerId('custmarker'),
      position: LatLng(deliModel.latCust, deliModel.lngCust),
      icon: BitmapDescriptor.defaultMarkerWithHue(150.0),
      infoWindow: InfoWindow(
          title: 'ตำแหน่งของลูกค้า',
          snippet: 'ละติจูต=${deliModel.latCust.toString()}, ' +
              'ลองติจูต=${deliModel.lngCust}'),
    );
  }
}
