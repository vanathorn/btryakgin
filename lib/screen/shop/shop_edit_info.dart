import 'dart:convert';
import 'dart:io' as io;
//import 'dart:io';
// File(_imageUri) conflict with html import 'package:html/html.dart';
//import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:yakgin/model/account_model.dart';
import 'package:yakgin/model/phyimg_model.dart';
import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/state/upimage/image_state.dart' as imgstate;
import 'package:yakgin/state/upimage/imageapi_call.dart';
import 'package:yakgin/state/upimage/upload_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/infosnackbar.dart';
import 'package:yakgin/widget/mysnackbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
//vtr after upgrade import 'package:flutter/rendering.dart';
//vtr after upgrade import 'package:flutter_riverpod/all.dart';

class ShopEditInfo extends StatefulWidget {
  ShopEditInfo();

  @override
  ShopEditInfoState createState() => ShopEditInfoState();
}

class ShopEditInfoState extends State<ShopEditInfo> {
  String ccode, brcode;
  String loginName, loginMobile;
  double lat, lng, screen;
  ShopModel shopModel;
  ShopRestModel restModel = new ShopRestModel();
  String txtName, txtAddress, txtBuild, txtRoad, txtAccno, txtAccname;
  String txtDistrict, txtAmphur, txtProvince, txtZipcode, txtPhone;
  String _txtName, _txtAddress, _txtBuild, _txtRoad;
  String _txtDistrict, _txtAmphur, _txtProvince, _txtZipcode;
  String _txtPhone, _shopImage;
  Location location = Location();

  PickedFile _imageFile;
  String gllery = 'N';
  io.File imgFile;
  final imgPicker = ImagePicker();

  bool getCurrLoc = false;
  bool getMstbank = false;
  String newAcc = '';
  //account bank
  List<AccountModel> listAccbks = List<AccountModel>.empty(growable: true);
  List<AccountModel> listnewAccbk = List<AccountModel>.empty(growable: true);
  //AccbkListStateController listStateController;
  List<AccountModel> listmstBanks = List<AccountModel>.empty(growable: true);
  //AccbkDetailStateController foodController = Get.put(AccbkDetailStateController());

  List<PhyImgModel> lisphyimage = List<PhyImgModel>.empty(growable: true);
  String physicalpath =
      'D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\shop\\';

  @override
  void initState() {
    super.initState();
    findUser();
    location.onLocationChanged.listen((event) {
      if (getCurrLoc) {
        lat = event.latitude;
        lng = event.longitude;
        setState(() {
          getCurrLoc = false;
        });
      }
    });
  }

  Future<Null> findUser() async {
    _imageFile = null;
    imgFile = null;
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      ccode = prefer.getString('pccode');
      brcode = prefer.getString('pbrcode');
      loginName = prefer.getString('pname');
      loginMobile = prefer.getString('pmobile');
      readExistDataShop();
      restModel.restaurantId = restModel.restaurantId;
      restModel.ccode = restModel.ccode;
      restModel.account = listAccbks.toList();
      getMasterBank();
      getPhycicalImagefolder();
    });
  }

  Future<Null> readExistDataShop() async {
    listAccbks.clear();
    _imageFile = null;
    imgFile = null;
    //imageCache.clear();
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkShop.aspx?ccode=$ccode';

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          shopModel = ShopModel.fromJson(map);
          _txtName = shopModel.thainame;
          _txtAddress = shopModel.address;
          _txtBuild = shopModel.build;
          _txtRoad = shopModel.road;
          _txtDistrict = shopModel.district;
          _txtAmphur = shopModel.amphur;
          _txtProvince = shopModel.province;
          _txtZipcode = shopModel.zipcode;
          _txtPhone = shopModel.phone;
          txtName = shopModel.thainame;
          txtAddress = shopModel.address;
          txtBuild = shopModel.build;
          txtRoad = shopModel.road;
          txtDistrict = shopModel.district;
          txtAmphur = shopModel.amphur;
          txtProvince = shopModel.province;
          txtZipcode = shopModel.zipcode;
          txtPhone = shopModel.phone;
          //account bank
          var straccbank = shopModel.banklist.split('*').toList();
          for (int i = 0; i < straccbank.length; i++) {
            var tmp = straccbank[i].split("|");
            listAccbks.add(
                AccountModel(ccode, tmp[0], tmp[1], tmp[2], tmp[3], tmp[4]));
          }
          //
          _shopImage = shopModel.shoppict;
          lat = double.parse(shopModel.lat);
          lng = double.parse(shopModel.lng);
        });
      }
    });
  }

  /*
  Future<Null> getRestutant() async {
    if (restModels.length != 0) {
      restModels.clear();
    }
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/getResturant.aspx?strCondtion=&strOrder=';
    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopRestModel fModels = ShopRestModel.fromJson(map);
          setState(() {
            restModels.add(fModels);
          });
        }
      } else {
        setState(() {
          havemenu = false;
        });
      }
    });
  }

  */

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: MyStyle().txtTH('????????????????????????????????????????????? $loginName', Colors.white),
        ),
        body: shopModel == null
            ? MyStyle().showProgress()
            : Container(
                margin: const EdgeInsets.only(top: 5),
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      inputName(),
                      iputAddress(),
                      inputBuild(),
                      iputRoad(),
                      iputDistrict(),
                      inputAmphur(),
                      iputProvZip(),
                      inputMobile(),
                      buildbtnNew(),
                      (listAccbks.length > 0) ? acountbkList() : Container(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (!kIsWeb) ? galleryPickup() : Text(''),
                            SizedBox(width: 8),
                            Container(
                              //margin: const EdgeInsets.only(top: 5),
                              width: !kIsWeb ? (screen * 0.6) : (300),
                              child: (_imageFile == null)
                                  ? Image.network(
                                      'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/$_shopImage')
                                  : displayImage(), //watchState(),
                            ),
                            (!kIsWeb) ? photoGraphy() : Text(''),
                            SizedBox(width: 8),
                          ]),
                      (lat == null && !kIsWeb)
                          ? MyStyle().showProgress()
                          : (!kIsWeb)
                              ? buildMap()
                              : Text(''),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [currLocButton(), saveButton()],
                      ),
                    ],
                  ),
                )));
  }

  Row buildbtnNew() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            margin: const EdgeInsets.only(left: 8, top: 3),
            width: screen * 0.55,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                  center: Alignment(0, 0),
                  radius: 2.7,
                  colors: <Color>[MyStyle().secondarycolor, Colors.white]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyStyle().txtTH18Dark('???????????????????????????'),
              ],
            )),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 3),
          width: screen * 0.4,
          child: btnNewAccBank(),
        )
      ],
    );
  }

  Expanded watchState() {
    return Expanded(
      child: Consumer(
        builder: (context, watch, _) {
          final _imageUri = watch(imgstate.imageProvider).state;
          final _uploadState = watch(uploadState).state;
          //final _message = watch(resultProvider).state;
          return _imageUri == null
              ? Center(child: MyStyle().txtbodyTH('?????????????????????????????????'))
              : _uploadState == STATE.NORMAL
                  ? Center(child: MyStyle().txtbodyTH('????????????????????????????????????????????????'))
                  : _uploadState == STATE.PICKED
                      ? Image.file(io.File(_imageUri))
                      : _uploadState == STATE.ERROR
                          ? Center(
                              child: MyStyle()
                                  .txtbodyTH('?????????????????????????????????????????????????????????????????????'))
                          : _uploadState == STATE.SUCCESS
                              ? Center(child: Text('??????????????????????????????????????????????????????????????????'))
                              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget displayImage() {
    if (_imageFile == null) {
      return Text("????????????????????????????????????????????????");
    } else {
      return Image.file(imgFile, width: 150, height: 150);
    }
  }

  Widget photoGraphy() => Container(
        //margin: const EdgeInsets.only(top: 25, left: 3),
        //width: 105,
        child: IconButton(
          tooltip: 'Pick Image from Gallery',
          icon: Icon(Icons.camera, size: 48),
          onPressed: () async {
            gllery = 'N';
            takePhoto(ImageSource.camera, 200.0, 200.0); //480.0, 640.0
          },
        ),
      );

  Widget xxxgalleryPickup() => Container(
      margin: const EdgeInsets.only(top: 3, left: 3),
      width: 105,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () async {
          gllery = 'Y';
          var pickedFile = await imgPicker.getImage(
              source: ImageSource.gallery, maxWidth: 200, maxHeight: 200);
          if (pickedFile != null) {
            setState(() {
              _imageFile = pickedFile;
              imgFile = io.File(pickedFile.path);
            });
          }
        },
        label: Text('?????????????????????',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(
          Icons.photo,
          color: Color.fromARGB(255, 60, 212, 250),
          size: 32,
        ),
        splashColor: Colors.blue,
      ));

  Widget saveButton() => FloatingActionButton.extended(
        backgroundColor: MyStyle().savecolor,
        onPressed: () async {
          if (txtName != '' && txtAddress != '' && txtPhone != '') {
            await saveImage(physicalpath);
            await saveData();
            readExistDataShop();
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                MySnackBar.showSnackBar(
                    "?????????????????????????????????????????????\r\n???????????????????????? ????????????????????? ????????????????????????",
                    Icons.contact_phone,
                    strDimiss: '?????????????????????'),
              );
          }
        },
        label: Text('????????????????????????????????????',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(Icons.cloud_done, color: Colors.white),
        splashColor: Colors.cyanAccent[400],
        foregroundColor: Colors.white,
        hoverColor: Color.fromARGB(255, 46, 180, 241),
        focusColor: Colors.red,
      );

  Widget xxxsaveButton() => Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (txtName != '' && txtAddress != '' && txtPhone != '') {
            await saveImage(physicalpath);
            await saveData();
            readExistDataShop();
            // MaterialPageRoute route = MaterialPageRoute(
            //           builder: (context) => MainShop());
            //           Navigator.push(context, route);
            //Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                MySnackBar.showSnackBar(
                    "?????????????????????????????????????????????\r\n???????????????????????? ????????????????????? ????????????????????????",
                    Icons.contact_phone,
                    strDimiss: '?????????????????????'),
              );
          }
        },
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: MyStyle().txtTH('????????????????????????????????????', Colors.white),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color.fromARGB(255, 46, 180, 241);
              return Color.fromARGB(
                  255, 0, 0, 80); // Use the component's default.
            },
          ),
        ),
      ));

  Future<Null> saveData() async {
    bool ok = true;
    String accbankList = '', comm = '';
    for (var j = 0; j < listAccbks.length; j++) {
      accbankList += comm +
          listAccbks[j].bkid +
          '|' +
          listAccbks[j].accno +
          '|' +
          listAccbks[j].accname;
      comm = '*';
    }
    try {
      String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
          'shop/updateShopInfo.aspx?ccode=$ccode&shopname=$txtName' +
          '&address=$txtAddress&build=$txtBuild&road=$txtRoad' +
          '&district=$txtDistrict&amphur=$txtAmphur' +
          '&province=$txtProvince&zipcode=$txtZipcode' +
          '&phone=$txtPhone&lat=${lat.toString()}&lng=${lng.toString()}' +
          '&accbankList=$accbankList';

      Response response = await Dio().get(url);
      if (response.toString() != '') {
        ok = false;
      }
    } catch (ex) {
      ok = false;
    }
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          InfoSnackBar.infoSnackBar('???????????????????????????????????????????????????????????????',
              Icons.sentiment_satisfied_alt), //tackface
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar('!???????????????????????????????????????????????????????????????', Icons.sick),
        );
    }
  }

  Future<Null> saveImage(String physicalpath) async {
    bool saveImage = true;
    if (_imageFile != null) {
      try {
        // context.read(uploadState).state = STATE.UPLOAD;
        // String filePath = gllery == 'Y'
        //     ? context.read(imgstate.imageProvider).state
        //     : _imageFile.path;
        String filePath = imgFile.path;
        var imageUri = await uploadImageShop(
            physicalpath, '$ccode$brcode', filePath, 'Y');
        if (imageUri != null) {
          //print('1 $physicalpath  $imageUri');
          //context.read(uploadState).state = STATE.SUCCESS;
          //context.read(resultProvider).state = imageUri;
          imageCache.clear();
        } else {
          //context.read(uploadState).state = STATE.ERROR;
          saveImage = false;
        }
      } catch (e) {
        saveImage = false;
      }
    }
    if (!saveImage) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar('!????????????????????????????????????/?????????????????????????????????????????????', Icons.sick),
        );
    }
  }

  Widget galleryPickup() => Container(
        //margin: const EdgeInsets.only(top: 3, left: 3),
        //width: 105,
        child: IconButton(
          tooltip: 'Pick Image from Gallery',
          icon: Icon(Icons.photo,
              size: 48), // color: Color.fromARGB(255, 60, 212, 250),),
          onPressed: () async {
            gllery = 'Y';
            var pickedFile = await imgPicker.getImage(
                source: ImageSource.gallery, maxWidth: 200, maxHeight: 200);
            if (pickedFile != null) {
              imgFile = io.File(pickedFile.path);

              var resultCrop = await ImageCropper().cropImage(
                  sourcePath: imgFile.path,
                  aspectRatioPresets: [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9
                  ],
                  androidUiSettings: const AndroidUiSettings(
                      toolbarTitle: 'Cropper',
                      toolbarColor: Colors.deepOrange,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false),
                  iosUiSettings: const IOSUiSettings(
                    minimumAspectRatio: 1.0,
                  ));

              setState(() {
                _imageFile = pickedFile;
                imgFile = io.File(resultCrop.path);
              });
            }
          },
        ),
      );

  Future<Null> takePhoto(
      ImageSource source, double maxWidth, double maxHeight) async {
    try {
      var pickedFile = await imgPicker.getImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        imgFile = io.File(pickedFile.path);

        var resultCrop = await ImageCropper().cropImage(
            sourcePath: imgFile.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
            androidUiSettings: const AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: const IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));

        setState(() {
          _imageFile = pickedFile;
          imgFile = io.File(resultCrop.path);
        });
      }
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
              initialValue: _txtName,
              onChanged: (value) => txtName = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: '????????????????????????',
                prefixIcon: Icon(Icons.home_work, color: MyStyle().darkcolor),
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
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
                //keyboardType: TextInputType.multiline,
                //maxLines: 2,
                initialValue: _txtAddress,
                onChanged: (value) => txtAddress = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '?????????????????????',
                  prefixIcon:
                      Icon(Icons.location_city, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget inputBuild() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
                initialValue: _txtBuild,
                onChanged: (value) => txtBuild = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '???????????????',
                  prefixIcon: Icon(Icons.domain, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().lightcolor),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget iputRoad() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
                keyboardType: TextInputType.streetAddress,
                initialValue: _txtRoad,
                onChanged: (value) => txtRoad = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '?????????',
                  prefixIcon: Icon(Icons.edit_road, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().lightcolor),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget iputDistrict() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
                initialValue: _txtDistrict,
                onChanged: (value) => txtDistrict = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '?????????/????????????',
                  // prefixIcon:
                  //     Icon(Icons.location_city, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().lightcolor),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget inputAmphur() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
                keyboardType: TextInputType.multiline,
                initialValue: _txtAmphur,
                onChanged: (value) => txtAmphur = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '????????????/???????????????',
                  // prefixIcon:
                  //     Icon(Icons.location_city, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().lightcolor),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget iputProvZip() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: !kIsWeb ? (screen * 0.62) : ((screen * 0.64)),
            height: 50,
            child: TextFormField(
                initialValue: _txtProvince,
                onChanged: (value) => txtProvince = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '?????????????????????',
                  // prefixIcon:
                  //     Icon(Icons.location_city, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().lightcolor),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          ),
          SizedBox(width: 10),
          Container(
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.3,
            height: 50,
            child: TextFormField(
                keyboardType: TextInputType.number,
                initialValue: _txtZipcode,
                onChanged: (value) => txtZipcode = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: '????????????????????????????????????',
                  // prefixIcon:
                  //     Icon(Icons.stream, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyStyle().lightcolor),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget inputMobile() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: screen * 0.95,
            height: 50,
            child: TextFormField(
              initialValue: _txtPhone,
              onChanged: (value) => txtPhone = value.trim(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: '??????????????????????????????',
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
        margin: EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyStyle().txtstyle('Lat=$lat Lng=$lng', Colors.black54, 10),
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: cameraPosition,
                mapType: MapType.normal,
                markers: shopMarker(),
                onMapCreated: (controller) {},
              ),
            )
          ],
        ));
  }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('shopmarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: '????????????????????? ${shopModel.thainame}',
            snippet: '?????????????????????=$lat, ????????????????????????=$lng'),
      )
    ].toSet();
  }

  Widget currLocButton() => FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: Icon(
          Icons.near_me_outlined,
          color: Colors.white,
        ),
        label: MyStyle().txtstyle('??????????????????????????????', Colors.white, 11),
        onPressed: () {
          _myLocation();
        },
      );

  Future _myLocation() async {
    // LocationData currentLocation = await getCurrentLocation();
    // setState(() {
    //   lat = currentLocation.latitude;
    //   lng = currentLocation.longitude;
    //   buildMap();
    // });
    getCurrLoc = true;
  }

  /*
  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        alertDialog(context, 'PERMISSION_DENIED');
      }
      return null;
    }
  }
  */

  Container acountbkList() {
    return Container(
        margin: const EdgeInsets.only(top: 5, left: 8.0, right: 8),
        child: Column(
          children: [
            (getMstbank) ? selectBank() : Container(),
            (listnewAccbk != null && listnewAccbk.length > 0)
                ? inputNewAccbk()
                : Container(),
            MyStyle().txtstyle(
                '?????????????????? ????????????????????????????????????????????????????????????  ??????????????????????????????????????????????????????????????????',
                Colors.black,
                10),
            ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: listAccbks.length,
                itemBuilder: (context, index) => Slidable(
                      child: Card(
                        elevation: 5.0,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              //height: 42,
                              margin: const EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyStyle().txtstyle(
                                          listAccbks[index].bkcode,
                                          Colors.blueAccent[700],
                                          12),
                                      SizedBox(width: 15),
                                      MyStyle().txtstyle(
                                          listAccbks[index].accno,
                                          Colors.redAccent[700],
                                          14),
                                    ],
                                  ),
                                  MyStyle().txtH16(listAccbks[index].accname),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.2,
                      secondaryActions: [
                        IconSlideAction(
                            caption: '??????????????????',
                            icon: Icons.delete,
                            color: Colors.red,
                            onTap: () {
                              setState(() {
                                listAccbks.removeAt(index);
                              });
                            })
                      ],
                    )),
            SizedBox(height: 5)
          ],
        ));
  }

  Row btnNewAccBank() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          backgroundColor:
              (getMstbank) ? Colors.redAccent[700] : MyStyle().primarycolor,
          onPressed: toggleMasterBank,
          label: Text((getMstbank) ? '??????????????????' : '??????????????????????????????',
              style: TextStyle(
                fontFamily: 'thaisanslite',
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              )),
          icon:
              Icon((getMstbank) ? Icons.close : Icons.add, color: Colors.white),
          splashColor: Colors.cyanAccent[400],
          foregroundColor: Colors.white,
          hoverColor: Colors.red,
          focusColor: Colors.red,
        ),
      ],
    );
  }

  Column selectBank() {
    listnewAccbk.clear();
    return Column(children: [
      Container(
        /* decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 2.7,
                colors: <Color>[MyStyle().secondarycolor, Colors.white]
              ),
        ),*/
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.pinkAccent[200]),
            SizedBox(width: 20),
            MyStyle().txtTH('??????????????????????????????', Colors.black),
          ],
        ),
      ),
      Divider(thickness: 2),
      ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: listmstBanks.length,
          itemBuilder: (context, index) => InkWell(
                onTap: () {
                  setState(() {
                    listnewAccbk.add(AccountModel(
                        ccode,
                        listmstBanks[index].bkid,
                        listmstBanks[index].bkcode,
                        listmstBanks[index].bkname,
                        '',
                        ''));
                    getMstbank = false;
                    txtAccno = '';
                    txtAccname = '';
                  });
                },
                child: Card(
                    color: Colors.amber[300],
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 5),
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Container(
                      height: 48,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 8),
                              MyStyle().txtstyle(listmstBanks[index].bkcode,
                                  Colors.black38, 14),
                              SizedBox(width: 20),
                              MyStyle().txtblack18TH(listmstBanks[index].bkname)
                            ],
                          ),
                        ],
                      ),
                    )),
              )),
      Divider(thickness: 2),
    ]);
  }

  //List<AccountModel> get newMethod => listmstBanks;

  Container inputNewAccbk() {
    return Container(
        child: Column(
      children: [
        Divider(thickness: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance), // food_bank
            SizedBox(width: 5),
            MyStyle()
                .txtstyle(listnewAccbk[0].bkcode, Colors.redAccent[700], 14),
            SizedBox(width: 10),
            MyStyle().txtblack16TH(listnewAccbk[0].bkname)
          ],
        ),
        inputAccno(),
        inputAccname(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: saveNewAcc(),
        ),
        Divider(thickness: 2)
      ],
    ));
  }

  Row saveNewAcc() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton.extended(
          label: Text('??????????????????',
              style: TextStyle(
                fontFamily: 'thaisanslite',
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              )),
          icon: Icon(Icons.close),
          backgroundColor: Colors.redAccent[700],
          onPressed: () {
            setState(() {
              listnewAccbk.clear();
              getMstbank = false;
            });
          },
        ),
        SizedBox(width: 5),
        FloatingActionButton.extended(
          label: Text('????????????',
              style: TextStyle(
                  fontFamily: 'thaisanslite',
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.white)),
          icon: Icon(Icons.check),
          backgroundColor: Colors.blueAccent[700],
          onPressed: () async {
            String mess = '';

            if ((txtAccno?.isEmpty ?? true) || (txtAccname?.isEmpty ?? true)) {
              mess = '!????????????????????? ???????????????????????????????????? ?????????????????????????????????????????????????????????';
            } else {
              if (txtAccno.length > 13) {
                mess = '!????????????????????????????????????  ???????????????????????? 13 ????????????';
              } else {
                for (var j = 0; j < listAccbks.length; j++) {
                  if (listAccbks[j].accno == txtAccno) {
                    mess = '!???????????????????????????????????? ???????????????????????????????????????';
                    break;
                  }
                }
              }
            }
            if (mess == '') {
              setState(() {
                listAccbks.add(AccountModel(
                    ccode,
                    listnewAccbk[0].bkid,
                    listnewAccbk[0].bkcode,
                    listnewAccbk[0].bkname,
                    txtAccno,
                    txtAccname));
                getMstbank = false;
                listnewAccbk.clear();
                getMstbank = false;
              });
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  MySnackBar.showSnackBar(mess, Icons.comment,
                      strDimiss: '?????????????????????'),
                );
            }
          },
        ),
      ],
    );
  }

  Widget inputAccno() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.95,
            child: TextFormField(
              initialValue: '',
              keyboardType: TextInputType.number,
              onChanged: (value) => txtAccno = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: '????????????????????????????????????',
                prefixIcon: Icon(Icons.fingerprint, color: MyStyle().darkcolor),
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

  Widget inputAccname() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.95,
            child: TextFormField(
              initialValue: '',
              onChanged: (value) => txtAccname = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: '???????????????????????????',
                prefixIcon:
                    Icon(Icons.account_circle, color: MyStyle().darkcolor),
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

  Future<Null> toggleMasterBank() async {
    if (getMstbank) {
      setState(() {
        getMstbank = false;
      });
    } else {
      setState(() {
        getMstbank = true;
      });
    }
  }

  Future<Null> getMasterBank() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/getMstBank.aspx?ccode=$ccode';

    listmstBanks.clear();
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null && result != '') {
        for (var map in result) {
          setState(() {
            AccountModel aModel = AccountModel.fromJson(map);
            listmstBanks.add(AccountModel(
                ccode, aModel.bkid, aModel.bkcode, aModel.bkname, '', ''));
          });
        }
      } else {
        setState(() {
          //
        });
      }
    });
  }

  Future<Null> getPhycicalImagefolder() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/getfolderimage.aspx';

    physicalpath = 'D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\shop\\';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null && result != '') {
        for (var map in result) {
          setState(() {
            PhyImgModel pModel = PhyImgModel.fromJson(map);
            //lisphyimage.add(PhyImgModel(pModel.imageMember, pModel.imageShop, pModel.imageItem));
            physicalpath = pModel.imageShop;
          });
        }
      } else {
        setState(() {
          //
        });
      }
    });
  }
}
