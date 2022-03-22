import 'package:flutter/material.dart';
import 'package:yakgin/model/delivery_model.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:yakgin/widget/appbar_sample.dart';

class SampleMapScreen extends StatefulWidget {
  SampleMapScreen({Key key}) : super(key: key);
  @override
  _SampleMapScreenState createState() => _SampleMapScreenState();
}

class _SampleMapScreenState extends State<SampleMapScreen> {
  DeliveryModel deliModel = new DeliveryModel();
  double screen, lat1, lng1;

  @override
  void initState() {
    super.initState();
    findLatLngRider();
  }

  Future<Null> findLatLngRider() async {
    try {
      LocationData locationData = await MyCalculate().findLocationData();
      setState(() {
        deliModel.latRider = locationData.latitude; //14.1278335
        deliModel.lngRider = locationData.longitude; //100.6213218
        deliModel.latCust = 14.0730344;
        deliModel.lngCust = 100.6150362;
      });
      debugPrint(
          'LocationData ${locationData.latitude} , ${locationData.longitude}');
    } catch (ex) {
      alertDialog(context, 'LocationData Fail.\r\n' + ex.toString());
      debugPrint('LocationData Fail. ' + ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBarSampleButton(title: 'Google Map Sample.'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (deliModel.latCust != null) ? buildMap() : Container(),
          ],
        ),
      ),
    );
  }

  Drawer buildHomeDrawer(name, email, imgwall) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Column(
            children: [
              MyStyle().homeAccountsDrawerHeader(name, email, imgwall),
            ],
          ),
        ],
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
          snippet: 'ละติจูต=${deliModel.latCust}, ' +
              'ลองติจูต=${deliModel.lngCust}'),
    );
  }
}
