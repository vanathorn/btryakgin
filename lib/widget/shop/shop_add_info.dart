import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/material.dart';
//vtr after upgrade import 'package:flutter/rendering.dart';
import 'package:yakgin/model/login_model.dart';
import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopAddInfo extends StatefulWidget {
  @override
  _ShopAddInfoState createState() => _ShopAddInfoState();
}

class _ShopAddInfoState extends State<ShopAddInfo> {
  String ccode;
  String loginName, loginMobile;
  String txtName, txtAddress, txtPhone;
  String _txtName, _txtAddress, _txtPhone;
  String urlImage;
  double screen;
  //bool loading = false;
  var lat;
  var lng;
  PickedFile _imageFile;
  File _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    findUser();
    findLocation();
    //getLocation();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      ccode = prefer.getString('pccode');
      loginName = prefer.getString('pname');
      loginMobile = prefer.getString('pmobile');
      findStrConn();
    });
  }

  Future<Null> findStrConn() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkMobile.aspx?Mobile=' +
        loginMobile;
    try {
      Response response = await Dio().get(url);
      if (response.toString().trim() == '') {
        alertDialog(context, '!มือถือไม่ถูกต้อง');
      } else {
        var result = json.decode(response.data);
        for (var map in result) {
          LoginModel loginmodel = LoginModel.fromJson(map);
          if (loginMobile == loginmodel.mobile) {
            ccode = loginmodel.ccode;
          } else {
            alertDialog(context, '!ข้อมูลไม่ถูกต้อง');
            break;
          }
        }
        if (ccode != null) {
          setState(() {
            findData();
          });
        }
      }
    } catch (e) {
      alertDialog(context, '!ไม่สามารถติดต่อ Serverได้');
    }
  }

  Future<Null> findData() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkShop.aspx?ccode=$ccode&strCondtion=';

    try {
      Response response = await Dio().get(url);
      if (response.toString().trim() == '') {
        alertDialog(context, '!Connection ไม่ถูกต้อง');
      } else {
        //String _txtName, _txtAddress, _txtPhone;
        var result = json.decode(response.data);
        for (var map in result) {
          ShopModel shopmodel = ShopModel.fromJson(map);
          _txtName = shopmodel.thainame;
          _txtAddress = shopmodel.address;
          _txtPhone = shopmodel.phone;
        }
        setState(() {
          txtName = _txtName;
          txtAddress = _txtAddress;
          txtPhone = _txtPhone;
        });
      }
    } catch (e) {
      alertDialog(context, '!ไม่สามารถติดต่อ Serverได้');
    }
  }

  Future<Null> getLocation() async {
    var location = Location();
    var currentLocation;
    try {
      currentLocation = await location.getLocation();
    } catch (ex) {
      //
    }
    setState(() {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
  }

  Future<Null> findLocation() async {
    LocationData currentLocation = await findLocationData();
    setState(() {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    return location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: MyStyle().secondarycolor,
        title: MyStyle().txtTH('เพิ่มข้อมูลร้านค้าของ$loginName', Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            inputName(),
            inputAddress(),
            inputMobile(),
            groupImage(),
            (lat == null) ? MyStyle().showProgress() : buildMap(),
            saveInfo()
          ],
        ),
      ),
    );
  }

  Widget saveInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
      child: ElevatedButton.icon(
        //style: ElevatedButton.styleFrom(
        //padding: EdgeInsets.all(2),
        //primary: Colors.green, // background
        //onPrimary: Colors.white, // foreground
        //),
        onPressed: () {
          //if ((txtName ?.isEmpty ?? true) || (txtAddress ?.isEmpty ?? true) || (txtPhone ?.isEmpty ?? true)){
          //alertDialog(context, '!กรุณาใส่ข้อมูลช่องว่าง');
          //}else if (_imageFile == null){
          //alertDialog(context, '!กรุณาเลือกรูปภาพ');
          //} else{
          //uploadImage();
          sendImageToServer();
          //}
        },
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: MyStyle().txtTH('บันทึกข้อมูล', Colors.white),
        style: ButtonStyle(
          //backgroundColor: MaterialStateProperty.all(MyStyle().primarycolor),
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          //textStyle: MaterialStateProperty.all(TextStyle(fontSize: 24, color: Colors.black)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return Colors.green; // Use the component's default.
            },
          ),
        ),
      ),
    );
  }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('shopmarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ร้านของ $loginName',
            snippet: 'ละติจูต=$lat, ลองติจูต=$lng'),
      )
    ].toSet();
  }

  Container buildMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 11.0);

    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15),
      height: 300,
      child: //loading == false ?
          GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        markers: shopMarker(),
        onMapCreated: (controller) {},
      ), //: CircularProgressIndicator(),
      //child: GoogleMap(
      //initialCameraPosition: cameraPosition,
      //mapType: MapType.normal,
      //onMapCreated: (controller) {},
      //),
    );
  }

  Row groupImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            tooltip: 'Pick Image from caremra',
            icon: Icon(
              Icons.linked_camera, //add_a_photo,
              size: 48,
            ),
            onPressed: () => chooseImage(ImageSource.camera, 600.0, 600.0)),
        Container(
          margin: EdgeInsets.only(top: 5, left: 10),
          width: screen * 0.5,
          child: (_imageFile == null)
              ? Image.asset('images/myshop.png')
              : Image.file(File(_imageFile.path)), //_previewImage()
        ),
        Container(
            margin: EdgeInsets.only(right: 15),
            child: IconButton(
                tooltip: 'Pick Image from gallery',
                icon: Icon(
                  Icons.photo,
                  size: 48,
                ),
                onPressed: () =>
                    chooseImage(ImageSource.gallery, 600.0, 600.0)))
      ],
    );
  }

  Future<Null> chooseImage(
      ImageSource source, double maxWidth, double maxHeight) async {
    try {
      //var _imageFile = await ImagePicker()
      final pickedFile = await _picker.getImage(source: source
          //maxWidth: maxWidth,
          //maxHeight: maxHeight,
          //imageQuality: quality,
          );
      setState(() {
        _imageFile = pickedFile;
        _image = File(_imageFile.path);
      });
    } catch (e) {
      //print("Image picker error " + e);
    }
  }

  //Widget _previewImage() {
  //if (_imageFile != null) {
  //return Semantics(
  //child: Image.file(File(_imageFile.path)),
  //label: 'ภาพร้านของ $loginName');
  //} else {
  //return const Text(
  //'You have not yet picked an image.',
  //textAlign: TextAlign.center,
  //);
  //}
  //}

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextField(
              onChanged: (value) => txtName = value.trim(),
              decoration: InputDecoration(
                //hintStyle: TextStyle(color: MyStyle().hintcolor),
                //hintText: 'ชื่อร้าน',

                //labelStyle: TextStyle(
                //fontFamily: 'thaisanslite',
                //fontSize: 26,
                //fontWeight: FontWeight.normal,
                //color: Colors.white70,
                //),
                labelStyle: MyStyle().myLabelStyle(), labelText: 'ชื่อร้าน',
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

  Widget inputAddress() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextField(
              onChanged: (value) => txtAddress = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ที่อยู่ชื่อร้าน',
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
            child: TextField(
              onChanged: (value) => txtPhone = value.trim(),
              keyboardType: TextInputType.number,
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

  Future<Null> sendImageToServer() async {
    //open a bytestream
    //old version var stream = new http.ByteStream(DelegatingStream.typed(_image.openRead()));
    String aspEndPoint =
        '${MyConstant().apipath}.${MyConstant().domain}/uploadImage.aspx';

    var stream = new http.ByteStream(_image.openRead());
    stream.cast();
    final int length = await _image.length();
    // Response response = request.send();
    final request = new http.MultipartRequest(
        'POST', Uri.parse(aspEndPoint)) //Uri.parse(aspEndPoint)
      ..files.add(new http.MultipartFile('Image', stream, length,
          filename: 'test.jpg'));
    http.Response response =
        await http.Response.fromStream(await request.send());
    print(response.statusCode);
    setState(() {
      //
    });
  }

  Future<Null> uploadImage() async {
    if (_imageFile == null) return;
    final String phpEndPoint =
        '${MyConstant().apipath}.${MyConstant().domain}/image.php';
    File file = File(_imageFile.path);
    String base64Image = base64Encode(file.readAsBytesSync());
    String fileName = file.path.split("/").last;

    http.post(phpEndPoint, body: {
      "image": base64Image,
      "name": fileName,
    }).then((res) {
      print(res.statusCode);
    }).catchError((err) {
      print(err);
    });

    Random random = Random();
    int i = random.nextInt(1000000);
    String nameImage = 'shop$i.jpg';
    try {
      //Map<String, dynamic> map = Map();
      //map['file'] = await MultipartFile.fromFile(_imageFile.path, filename: nameImage);
      print('_imageFile.path = $_imageFile.path');
      print('nameImage = $nameImage');
      //FormData formdata = FormData.fromMap(map);
      //await Dio().post(url, data: formdata).then((value) {
      //urlImage = '${MyConstant().apipath}.${MyConstant().domain}/Shop/$nameImage';
      //});
    } catch (ex) {
      //
    }
  }
}
