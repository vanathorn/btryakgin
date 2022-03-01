import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/cart_model.dart';
import 'package:btryakgin/model/login_model.dart';
import 'package:btryakgin/model/sum_value.dart';
import 'package:btryakgin/screen/menu/main_user.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/utility/myutil.dart';
import 'package:btryakgin/view/cart_vm/cart_view_model_imp.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SendOrder extends StatefulWidget {
  final MainStateController mainStateController;
  final CartStateController controller;
  final CartViewModelImp cartViewModel;
  final SumValue sumValue;
  final LoginModel loginModel;
  //final bool isWeb;

  SendOrder(this.mainStateController, this.controller, this.cartViewModel,
      this.sumValue, this.loginModel);
  @override
  _SendOrderState createState() => _SendOrderState();
}

class _SendOrderState extends State<SendOrder> {
  String restaurantid, ccode, mbid, loginName, loginMobile;
  double getlat = 0.0, getlng = 0.0, lat = 0.0, lng = 0.0, screen;
  //SendModel sendModel=new SendModel();
  SumValue sumValue;
  CartViewModelImp cartViewModel;
  String txtName, txtAddress, txtMobile, txthhmm = '', attachlocation = 'Y';
  //String _txtName, _txtAddress, _txtMobile;
  DateTime selectedDate = DateTime.now();
  String txtTime = 'ระบุเวลา', createdDT = '';
  String txtSelectDate = '';

  final firstDate = DateTime.now();
  final lastDate = DateTime.now();
  bool settime = false;
  bool isWeb = false;

  Location location = Location();

  MainStateController mainStateController;
  CartStateController controller;
  List<CartModel> cartList = List<CartModel>.empty(growable: true);
  LoginModel loginModel;

  @override
  void initState() {
    super.initState();
    mainStateController = widget.mainStateController;
    controller = widget.controller;
    cartViewModel = widget.cartViewModel;
    sumValue = widget.sumValue;
    //isWeb = widget.isWeb;
    ccode = '${mainStateController.selectedRestaurant.value.ccode}';
    restaurantid =
        '${mainStateController.selectedRestaurant.value.restaurantId}';
    loginModel = widget.loginModel;

    location.onLocationChanged.listen((event) {
      lat = event.latitude;
      lng = event.longitude;
    });
    initData();
  }

  Future<Null> initData() async {
    setState(() {
      // txtSelectDate = '$selectedDate'.split(' ')[0].split('-')[2]
      // +'/'+'$selectedDate'.split(' ')[0].split('-')[1]
      // +'/'+'$selectedDate'.split(' ')[0].split('-')[0];
      txtSelectDate = (selectedDate.day < 10
              ? '0' + selectedDate.day.toString()
              : selectedDate.day.toString()) +
          '/' +
          (selectedDate.month < 10
              ? '0' + selectedDate.month.toString()
              : selectedDate.month.toString()) +
          '/' +
          selectedDate.year.toString();
      getPreferance();
      findLocation();
      //* getExistSend();
      txtName = loginModel.mbname;
      txtAddress = loginModel.sendaddr;
      txtMobile = loginModel.mobile;
    });
  }

  Future<Null> getPreferance() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      mbid = prefer.getString('pid');
      loginName = prefer.getString('pname');
      loginMobile = prefer.getString('pmobile');

      // sendModel.name=loginName;
      // sendModel.address='';
      // sendModel.mobile=loginMobile;

      // _txtName=loginName;
      // _txtAddress='';
      // _txtMobile=loginMobile;
    });
  }
  /* account bank
  Future<Null> findAccountShop() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/getShopBank.aspx?ccode=' +  ccode; 
    listAccbks.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          AccountModel aModels = AccountModel.fromJson(map);
          listAccbks.add(
            AccountModel(
              ccode, aModels.bkid, aModels.bkcode, aModels.bkname, 
              aModels.accno, aModels.accname
            )
          );
        }
        setState(() {
          shopModel.restaurantId=restaurantid;
          shopModel.ccode=ccode;
          shopModel.account = listAccbks.toList();
        });
      }
    });  
  }*/

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
        title: MyStyle().txtTH('การจัดส่งสินค้า', Colors.white),
      ),
      body: loginModel == null
          ? MyStyle().showProgress()
          : SingleChildScrollView(
              child: Column(
                children: [
                  inputName(),
                  iputAddress(),
                  inputMobile(),
                  Container(
                    margin: const EdgeInsets.only(left: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MyStyle().txtbody('ส่ง'),
                        Text('$txtSelectDate',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        Text(txthhmm != '' ? ('$txthhmm') : '',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        specifyTime(),
                      ],
                    ),
                  ),
                  (settime && !kIsWeb)
                      ? Container(
                          child: Text(
                              'ไม่ต่ำกว่า ' +
                                  MyCalculate()
                                      .calculateTime(sumValue.distiance),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black)),
                        )
                      : Container(),
                  (settime && !kIsWeb)
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          width: screen,
                          height: 120,
                          child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: (selectedDate != null &&
                                      selectedDate.toString() != '')
                                  ? selectedDate
                                  : DateTime.now(),
                              //minimumDate: firstDate,
                              //maximumDate: lastDate,
                              onDateTimeChanged: (newDate) {
                                selectedDate = newDate;
                                setState(() {
                                  txthhmm = '$selectedDate'
                                      .split(' ')[1]
                                      .substring(0, 5);
                                  //txthhmm = selectedDate.minute.toString()+':'+selectedDate.second.toString();
                                });
                              }))
                      : Container(),
                  (!isWeb) ? buildMap() : Text(''),
                  buildAttach(),
                  buildSaveButton()
                ],
              ),
            ),
    );
  }

  Widget specifyTime() => Row(
        children: <Widget>[
          (!kIsWeb)
              ? ElevatedButton(
                  onPressed: () {
                    if (settime) {
                      //_openDatePicker(context);
                      setState(() {
                        settime = false;
                        txthhmm = '';
                        txtTime = 'ระบุเวลา';
                      });
                    } else {
                      setState(() {
                        settime = true;
                        txthhmm = '$selectedDate'.split(' ')[1].substring(0, 5);
                        //selectedDate.minute.toString()+':'+selectedDate.second.toString();
                        txtTime = 'ไม่ระบุเวลา';
                      });
                    }
                  },
                  child: MyStyle().txtstyle('$txtTime', Colors.black, 11),
                  style: ElevatedButton.styleFrom(
                      primary: MyStyle().primarycolor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))))
              : Text('')
        ],
      );

  Widget attachLocation() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: screen * 0.95,
            margin: EdgeInsets.only(top: 3, left: 15),
            child: Row(
              children: <Widget>[
                MyStyle().txtbody('ตำแหน่งปัจจุบัน '),
                Transform.scale(
                  scale: 1.8,
                  child: Radio(
                    value: 'Y',
                    groupValue: attachlocation,
                    onChanged: (value) {
                      setState(() {
                        attachlocation = value;
                      });
                    },
                  ),
                ),
                MyStyle().txtbody('แนบไปด้วย '),
                Transform.scale(
                  scale: 1.8,
                  child: Radio(
                    value: 'N',
                    groupValue: attachlocation,
                    onChanged: (value) {
                      setState(() {
                        attachlocation = value;
                      });
                    },
                  ),
                ),
                MyStyle().txtbody('ไม่'),
              ],
            ),
          )
        ],
      );

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.97,
            child: TextFormField(
              initialValue: '${loginModel.mbname}',
              onChanged: (value) => txtName = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ชื่อ',
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
            width: screen * 0.97,
            child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                initialValue: '${loginModel.sendaddr}',
                onChanged: (value) => txtAddress = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: 'สถานที่',
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
                style: TextStyle(
                  //fontSize: 40.0,
                  height: 1.5,
                  //color: Colors.black
                )),
          )
        ],
      );

  Widget inputMobile() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.97,
            child: TextFormField(
              initialValue: '${loginModel.mobile}',
              onChanged: (value) => txtMobile = value.trim(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'เบอร์ติดต่อ',
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

  Widget buildMap() {
    return (lat != 0 && lng != 0) ? drawMap() : MyStyle().showProgress();
  }

  Widget buildAttach() {
    return (lat != 0 && lng != 0 && !kIsWeb) ? attachLocation() : Container();
  }

  Widget buildSaveButton() {
    return ((lat != 0 && lng != 0) || (kIsWeb)) ? saveButton() : Container();
  }

  Container drawMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 11.0);
    return Container(
      margin: EdgeInsets.only(top: 0, left: 5, right: 5),
      height: 250,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        markers: userMarker(),
        onMapCreated: (controller) {},
      ),
    );
  }

  Set<Marker> userMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('shopmarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ตำแหน่งของลูกค้า', // ${sendModel.name}
            snippet: 'ละติจูต=$lat, ลองติจูต=$lng'),
      )
    ].toSet();
  }

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Center(
            child: MyStyle().txtstyle('ยืนยันการสั่งซื้อ?', Colors.red, 16.0)),
        children: <Widget>[
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
                      child: MyStyle()
                          .titleCenter(context, 'ยกเลิก', 16.0, Colors.black))),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    editThread();
                  },
                  child: Container(
                      width: screen * 0.28,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.redAccent[700],
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: MyStyle()
                          .titleCenter(context, 'ยืนยัน', 16.0, Colors.white))),
            ],
          )
        ],
      ),
    );
  }

  String dtoSFixed2(double val) {
    return val != null ? val.toStringAsFixed(2) : '0';
  }

  Future<Null> editThread() async {
    String ccode = mainStateController.selectedRestaurant.value.ccode;
    String resturantid =
        mainStateController.selectedRestaurant.value.restaurantId;
    String attlat = '0', attlng = '0', ttlDiscount = '0.0', ttlFree = '0.0';
    final double distiance = sumValue.distiance;
    final double ttlAmount = controller.sumCart(resturantid);
    if (lat != null && lng != null) {
      if (attachlocation == 'Y') {
        attlat = lat.toString();
        attlng = lng.toString();
      }
    }
    DateTime now = DateTime.now();
    createdDT = DateFormat('MM-dd-yyyy HH:mm:ss.ms')
        .format(now); //'11-23-2021 08:44:00.000'

    String ordhead = resturantid +
        '*' +
        mbid +
        '*' +
        txtName +
        '*' +
        txtAddress +
        '*' +
        txtMobile +
        '*' +
        txthhmm +
        '*' +
        dtoSFixed2(distiance) +
        '*' +
        attlat +
        '*' +
        attlng +
        '*' +
        dtoSFixed2(ttlAmount) +
        '*' +
        ttlDiscount +
        '*' +
        ttlFree +
        '*' +
        loginName +
        '*' +
        createdDT;
    String orddetail =
        ''; //'restaurantId+'_'+'iid'+ '_'+topBid+'_'+topCid+'_'+addonid_qty_unitprice_spFlag;';

    cartList.clear();
    cartList = controller
        .getCart(mainStateController.selectedRestaurant.value.restaurantId)
        .toList();
    int qty = 0;
    int qtySp = 0;
    String strKey = '', delimiter = '';
    for (int j = 0; j < cartList.length; j++) {
      strKey = cartList[j].strKey;
      qty = cartList[j].quantity;
      qtySp = cartList[j].quantitySp; //spFlag
      if (qty > 0) {
        orddetail += delimiter +
            strKey +
            '_' +
            qty.toString() +
            '_' +
            cartList[j].price.toString() +
            '_N'; //cartList[j].price.toStringAsFixed(2)
        delimiter = '*';
      }
      if (qtySp > 0) {
        orddetail += delimiter +
            strKey +
            '_' +
            qtySp.toString() +
            '_' +
            cartList[j].priceSp.toString() +
            '_Y'; //cartList[j].priceSp.toStringAsFixed(2)
        delimiter = '*';
      }
    }
    String url =
        '${MyConstant().domain}/${MyConstant().apipath}/order/insertOrder.aspx?ccode=' +
            ccode +
            '&ordhead=' +
            ordhead +
            '&orddetail=' +
            orddetail;
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        cartViewModel.clearCart(
            controller,
            mainStateController.selectedRestaurant.value.restaurantId,
            controller
                .getCart(
                    mainStateController.selectedRestaurant.value.restaurantId)
                .toList());
        MyUtil().sendNoticToShop(resturantid, '!มีคำสั่งซื้อเข้ามา',
            'จากลูกค้า $loginName ($loginMobile)');
        checkOrder(resturantid, ccode, mbid, createdDT);
      } else {
        alertDialog(context, response.toString());
      }
    } catch (e) {
      alertDialog(context, '!ทำคำสั่งซื้อไม่สำเร็จ');
    }
  }

  Future<Null> checkOrder(
      String resturantid, String ccode, String mbid, String createdDT) async {
    String url =
        '${MyConstant().domain}/${MyConstant().apipath}/order/checkOrdHeadByShop.aspx?ccode=' +
            ccode +
            '&mbid=' +
            mbid +
            '&createdDT=' +
            createdDT;
    try {
      Response response = await Dio().get(url);
      if (response.toString().trim() != '') {
        Toast.show('ส่งคำสั่งซื้อให้ร้านค้าแล้ว', context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (context) => MainUser());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      } else {
        alertDialog(context, '!ตรวจสอบไม่พบคำสั่งซื้อ\r\n(ตรวจสอบกับร้านค้า)');
      }
    } catch (e) {
      alertDialog(
          context, '! ไม่สามารถติดต่อ Serverได้\r\n(ตรวจสอบกับร้านค้า)');
    }
  }

  Widget saveButton() => Container(
      margin: const EdgeInsets.only(top: 8, bottom: 3),
      width: screen * 0.95,
      height: 50.0,
      child: ElevatedButton.icon(
        onPressed: () {
          if ((txtName?.isEmpty ?? true) ||
              (txtAddress?.isEmpty ?? true) ||
              (txtMobile?.isEmpty ?? true)) {
            alertDialog(context, 'ระบุข้อมูล ชื่อ สถานที่ เบอร์ติดต่อ ');
          } else {
            if (txtMobile.length < 10) {
              alertDialog(context, '!เบอร์ไม่ถูกต้อง (' + txtMobile + ')');
            } else {
              String strError = '';
              if ('$txthhmm' != '') {
                strError = MyCalculate()
                    .checkTime(DateTime.now(), '$txthhmm', sumValue.distiance);
              }
              if (strError == '') {
                confirmDialog();
              } else {
                alertDialog(context, '$strError');
              }
            }
          }
        },
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: MyStyle().txtTH('ยืนยันการสั่งซื้อ', Colors.white),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return Colors.green; // Use the component's default.
            },
          ),
        ),
      ));

  /* account bank
  Container buildAccBank() {
    return Container(
      margin: const EdgeInsets.only(top:5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        elevation: 5,
        child: Container(         
            padding: EdgeInsets.all(0.0),
            width: screen*0.95,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(() => ExpansionTile(
                  title: MyStyle().txtstyle(accbank_WORD, Colors.redAccent[700], 14.0),
                  children: [                 
                    Column(
                      children: 
                      listStateController.selectedAccount.value.account.map((e) => 
                        Padding(
                          padding: const EdgeInsets.only(left:10, bottom: 8.0),
                          child: 
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.account_box, color: Colors.black),
                                    SizedBox(width: 5),
                                    Container(
                                      width:screen*0.3,
                                      child: MyStyle().txtstyle('${e.accno}', Colors.red, 14.0)
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left:5.0),
                                      child: MyStyle().txtstyle('${e.bkname}', Colors.black, 13.0)
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30.0),
                                      child: MyStyle().txtstyle('${e.accname}', Colors.black, 13.0),
                                    )
                                  ],
                                )
                              ],
                            ),                                                
                        )).toList(),
                    )                   
                  ],
                ),)
              ],
            )),
      ));
  }
  */

}
