import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sql_conn/sql_conn.dart';
import 'package:yakgin/screen/SignIn.dart';
import 'package:yakgin/screen/home.dart';
import 'package:yakgin/state/prov_state.dart';
import 'package:yakgin/utility/loader.dart';
import 'package:yakgin/utility/sqlservice.dart';
import 'package:yakgin/widget/mysnackbar.dart';
import 'package:get/get.dart' as dget;
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yakgin/model/addon_model.dart';
import 'package:yakgin/model/login_model.dart';
import 'package:yakgin/model/m_model.dart';
import 'package:yakgin/model/user_model.dart';
import 'package:yakgin/screen/menu/main_rider.dart';
import 'package:yakgin/screen/menu/main_shop.dart';
import 'package:yakgin/screen/menu/main_user.dart';
import 'package:yakgin/screen/menu/multi_home.dart';
import 'package:yakgin/state/memtype_detail_state.dart';
import 'package:yakgin/state/memtype_list_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:toast/toast.dart';

import '../model/ddl_model.dart';

//https://docs.getwidget.dev/gf-radio-listtile/
//https://blog.bajarangisoft.com/blog/how-to-use-radio-button-in-flutter-popup-menu-button
//import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  double screen;
  bool redeye = true;
  String _user, user, mobile = '', choosetype;
  String addrno, vilage, province, ampher, tambun, zipcode;
  String _addrno, _vilage, _zipcode;
  String txtmobile = '', txtencrypt = '', txtinput = '';
  String mode = 'MOBILE', pin1 = '', pin2 = '', txtpin1 = '', txtpin2 = '';
  String txtencryptpin1 = '', txtencryptpin2 = '';
  //int _provno = 0, _ampherno = 0, _tambonno = 0;
  //String _provname = '', _amphername = '', _tambonname = '';
  double lat = 0.0, lng = 0.0;
  final int maxmobile = 10;
  final int maxpin = 4;
  final double hi = 17;
  String password = '', stepInfo = 'มือถือ';
  //FocusNode myFocusNode;
  var isExpanProf = false;
  var isExpanType = false;

  var isExpanP = false;
  var isExpanA = false;
  var isExpanT = false;

  bool valid = false;
  LoginModel loginModel = new LoginModel();

  MemtypeListStateController listStateController;
  List<AddonModel> addons = List<AddonModel>.empty(growable: true);
  MemTypeDetailStateController mbtypeController =
      dget.Get.put(MemTypeDetailStateController());

  ProvDetailStateController provController =
      dget.Get.put(ProvDetailStateController());
  List<DDLModel> listProv = List<DDLModel>.empty(growable: true);
  List<DDLModel> listAmpher = List<DDLModel>.empty(growable: true);
  List<DDLModel> listTambon = List<DDLModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    loginModel.mbtid = 0;
    loginModel.mbtname = 'Signup User';
    listStateController = dget.Get.put(MemtypeListStateController());
    findLocation();
    getMemberType();
    mbtypeController.selectAddon.clear();
    //myFocusNode = FocusNode();
  }

  /*
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }
  */

  @override
  void dispose() {
    SQLService().clearConn();
    super.dispose();
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

  Future<Null> getMemberType() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getMbTypeList.aspx';
    addons.clear();
    try {
      await Dio()
          .get(url,
              options: Options(
                headers: {
                  "Access-Control-Allow-Origin": "*",
                  "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS",
                  "Access-Control-Allow-Headers":
                      "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept",
                  "Access-Control-Allow-Credentials": "true"
                },
              ))
          .then((value) {
        //await Dio().get(url).then((value) {
        //debugPrint('***** value = $value');
        if (value.toString() != 'null') {
          var result = json.decode(value.data);
          for (var map in result) {
            MModel mModel = MModel.fromJson(map);
            String strToppM = mModel.listM.toString();
            var arrM = strToppM.split("*");
            for (int i = 0; i < arrM.length; i++) {
              var tmp = arrM[i].split("|");
              if (tmp[1] != 'M') {
                addons.add(AddonModel(
                    optid: int.parse(tmp[0]),
                    optname: tmp[2],
                    optcode: tmp[1]));
              }
            }
            setState(() {
              loginModel.mbtid = 2;
              loginModel.mbtname = 'ผู้ใช้งาน';
              loginModel.addrno = '';
              loginModel.vilage = '';
              loginModel.province = '0';
              loginModel.ampher = '0';
              loginModel.tambon = '0';
              loginModel.zipcode = '';
              loginModel.addonM = addons.toList();
              listStateController = dget.Get.find();
              listStateController.selectedMember.value = loginModel;
              getProvince();
            });
          }
        }
      });
    } catch (ex) {
      debugPrint('***>>> ${ex.toString()}');
    }
  }

  Future<void> getProvince() async {
    listProv.clear();
    listAmpher.clear();
    listTambon.clear();
    String query =
        "select ProvinceNo,ProvinceName from dbo.Province where enbFlag='Y' " +
            "order by ProvinceName";
    try {
      if (!SqlConn.isConnected) {
        SQLService().connect();
      }
      var value = await SqlConn.readData(query);
      if (value.toString() != 'null') {
        value = value.toString().replaceAll('"', "");
        var x = SQLService().myList(value);
        for (int j = 0; j < x.length; j++) {
          var y = x[j].split(',');
          String _id = y[0].split(':')[1];
          String _txtvalue = y[1].split(':')[1];
          //debugPrint('$_id / $_txtvalue');

          DDLModel ddl = new DDLModel();
          ddl.id = int.parse(_id);
          ddl.txtvalue = _txtvalue;
          setState(() {
            listProv.add(DDLModel(id: ddl.id, txtvalue: ddl.txtvalue));
            provController.ampherno = 0;
            provController.amphername = '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error ' + e.toString());
    } finally {
      //SqlConn.disconnect();
    }
  }

  Future<void> getAmpher() async {
    listAmpher.clear();
    String _provno = provController.provno.toString();
    String query =
        "select AmpherNo,AmpherName from dbo.Ampher where ProvinceNo=" +
            "'$_provno' and enbFlag='Y' order by AmpherName";
    try {
      if (!SqlConn.isConnected) {
        SQLService().connect();
      }
      var value = await SqlConn.readData(query);
      if (value.toString() != 'null') {
        value = value.toString().replaceAll('"', "");
        var x = SQLService().myList(value);
        for (int j = 0; j < x.length; j++) {
          var y = x[j].split(',');
          String _id = y[0].split(':')[1];
          String _txtvalue = y[1].split(':')[1];
          //debugPrint('$_id / $_txtvalue');
          DDLModel ddl = new DDLModel();
          ddl.id = int.parse(_id);
          ddl.txtvalue = _txtvalue;
          setState(() {
            listAmpher.add(DDLModel(id: ddl.id, txtvalue: ddl.txtvalue));
            provController.tambonno = 0;
            provController.tambonname = '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error ' + e.toString());
    } finally {
      //SqlConn.disconnect();
    }
  }

  Future<void> getTumbon() async {
    listTambon.clear();
    String _ampherno = provController.ampherno.toString();
    String query =
        "select TumbonNo,TumbonName from dbo.Tumbon where AmpherNo=" +
            "'$_ampherno' and enbFlag='Y' order by TumbonName";
    try {
      if (!SqlConn.isConnected) {
        SQLService().connect();
      }
      var value = await SqlConn.readData(query);
      if (value.toString() != 'null') {
        value = value.toString().replaceAll('"', "");
        var x = SQLService().myList(value);
        for (int j = 0; j < x.length; j++) {
          var y = x[j].split(',');
          String _id = y[0].split(':')[1];
          String _txtvalue = y[1].split(':')[1];
          //debugPrint('$_id / $_txtvalue');
          DDLModel ddl = new DDLModel();
          ddl.id = int.parse(_id);
          ddl.txtvalue = _txtvalue;
          setState(() {
            listTambon.add(DDLModel(id: ddl.id, txtvalue: ddl.txtvalue));
          });
        }
      }
    } catch (e) {
      debugPrint('Error ' + e.toString());
    } finally {
      //SqlConn.disconnect();
    }
  }

  _onExpanProfChanged(bool val) {
    setState(() {
      isExpanProf = val;
      _user = user;
      _addrno = addrno;
      _vilage = vilage;
      _zipcode = zipcode;
      if (listProv == null || listProv.length < 1) getProvince();
      // provController.provno = _provno;
      // provController.ampherno = _ampherno;
      // provController.tambonno = _tambonno;
      // provController.provname = _provname;
      // provController.amphername = _amphername;
      // provController.tambonname = _tambonname;
      setMode('MOBILE');
    });
  }

  _onExpanTypeChanged(bool val) {
    setState(() {
      isExpanType = val;
      setMode('MOBILE');
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().primarycolor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                MaterialPageRoute route =
                    MaterialPageRoute(builder: (value) => Home());
                Navigator.push(context, route);
              },
              child: MyStyle().titleLight('หน้าหลัก'),
            ),
            Container(
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      MaterialPageRoute route =
                          MaterialPageRoute(builder: (value) => SignIn());
                      Navigator.push(context, route);
                    },
                    child: MyStyle().titleLight('เข้าใช้ระบบ')))
            //Container(child: new Center(child: MyStyle().tpadding: EdgeInsets.fromLTRB(1.0, 2.0, 3.0, 4.0)
            //ex. padding: EdgeInsetsDirectional.only(start: 100, top: 0)
            //ex. padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            //ex. padding: EdgeInsets.fromLTRB(left, 2.0, 3.0, 4.0);
            //ex. margin: EdgeInsets.symmetric(horizontal: 70.0)
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          /*
          gradient: RadialGradient(
              center: Alignment(0, -0.7),
              radius: 0.5,
              colors: <Color>[Colors.white, MyStyle().lightcolor]),
          */
          image: DecorationImage(
            image: AssetImage("images/wall_signup.jpg"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildProfile(),
                //buildMTypeChoice(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    txtInfo(stepInfo),
                    (mode == 'PIN1')
                        ? buildShowText(txtencryptpin1, txtpin1)
                        : (mode == 'PIN2')
                            ? buildShowText(txtencryptpin2, txtpin2)
                            : buildShowText(txtencrypt, txtmobile),
                    buildRedEye(),
                    (mode == 'MOBILE')
                        ? Container(width: 85, child: buildBtnPin())
                        : Container(),
                  ],
                ),
                buildMobile(),
                (pin1 == pin2 && pin1 != '' && valid)
                    ? buildRegister()
                    : messFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FloatingActionButton buildBtnPin() {
    return FloatingActionButton.extended(
      backgroundColor: Color(0xffBFB372),
      onPressed: _pinScreen,
      label: Text('PIN',
          style: TextStyle(
            fontFamily: 'thaisanslite',
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          )),
      icon: Icon(
        Icons.memory,
        color: Colors.black,
        size: 32,
      ),
      splashColor: Colors.blue,
    );
  }

  Widget txtInfo(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: (mode == 'PIN1')
            ? Colors.redAccent[700]
            : (mode == 'PIN2')
                ? Color.fromARGB(255, 1, 61, 28)
                : Colors.black,
      ));

  Container messFooter() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        width: MediaQuery.of(context).size.width,
        height: 38,
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (mode == 'MOBILE')
                ? MyStyle().txtTH20Dark('ระบุชื่อผู้ใช้และเบอร์โทรศัพท์')
                : (mode == 'PIN1')
                    ? MyStyle().txtTH20Dark('ระบุรหัส 4 หลัก')
                    : (mode == 'PIN2')
                        ? MyStyle().txtTH20Dark('ทวนรหัสอีกครั้ง')
                        : Text('')
          ],
        ));
  }

  Container buildLogo() {
    return Container(width: screen * 0.28, child: MyUtil().showLogo());
  }

  Container buildProfile() {
    return Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: 8,
          child: Container(
              //padding: EdgeInsets.all(0.0),
              width: screen * 0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ExpansionTile(
                    onExpansionChanged: _onExpanProfChanged,
                    trailing: Switch(
                      value: isExpanProf,
                      onChanged: (_) {},
                    ),
                    title: MyStyle()
                        .txtstyle('ข้อมูลส่วนตัว', Colors.redAccent[700], 14.0),
                    children: [
                      Column(
                        children: [
                          buildUser(),
                          buildAddrno(),
                          buildVilage(),
                          buildProvince(),
                          buildAmpher(),
                          buildTambon(),
                          provController.ampherno != 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    buildZipcode(),
                                  ],
                                )
                              : Text('')
                        ],
                      )
                    ],
                  ),
                ],
              )),
        ));
  }

  Container buildMTypeChoice() {
    return Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: 8,
          child: Container(
              padding: EdgeInsets.all(0.0),
              width: screen * 0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(
                    () => ExpansionTile(
                      onExpansionChanged: _onExpanTypeChanged,
                      trailing: Switch(
                        value: isExpanType,
                        onChanged: (_) {},
                      ),
                      title: MyStyle()
                          .txtstyle(memtype_WORD, Colors.redAccent[700], 14.0),
                      children: [
                        Wrap(
                          //or Column
                          children: listStateController
                              .selectedMember.value.addonM
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 10, right: 5),
                                    child: ChoiceChip(
                                        label: mbtypeController.selectAddon
                                                .contains(e)
                                            ? MyStyle()
                                                .subTitleDrawerLight(e.optname)
                                            : MyStyle()
                                                .subTitleDrawerDark(e.optname),
                                        selectedColor: Colors.black,
                                        disabledColor: Colors.grey[100],
                                        selected: mbtypeController.selectAddon
                                            .contains(e),
                                        onSelected: (selected) {
                                          setState(() {
                                            selected
                                                ? mbtypeController.selectAddon
                                                    .add(e)
                                                : mbtypeController.selectAddon
                                                    .remove(e);
                                          });
                                        }),
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

  Container buildShowText(String strEncrypt, String strNormal) {
    return Container(
        child: (redeye)
            ? Text(
                strEncrypt,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent[700],
                  fontWeight: FontWeight.normal,
                ),
              )
            : Text(
                strNormal,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff030342),
                  fontWeight: FontWeight.normal,
                ),
              ));
  }

  IconButton buildRedEye() {
    return IconButton(
      icon: redeye
          ? Icon(Icons.remove_red_eye)
          : Icon(Icons.remove_red_eye_outlined),
      onPressed: () {
        setState(() {
          redeye = !redeye;
        });
      },
    );
  }

  Container buildUser() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white70,
      ),
      margin: EdgeInsets.all(5),
      width: screen * 0.9,
      height: 54,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        initialValue: _user,
        onChanged: (value) => user = value.trim(),
        autofocus: true,
        decoration: InputDecoration(
          labelStyle: MyStyle().myLabelStyle(),
          labelText: 'ชื่อผู้ใช้งาน',
          prefixIcon: Icon(Icons.account_circle, color: MyStyle().darkcolor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().lightcolor),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyStyle().darkcolor),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        cursorColor: Color(0xffffffff),
        style: GoogleFonts.kanit(
            fontStyle: FontStyle.normal,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff000000)),
      ),
    );
  }

  Container buildAddrno() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white70,
      ),
      margin: EdgeInsets.all(5),
      width: screen * 0.9,
      height: 54,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        initialValue: _addrno,
        onChanged: (value) => addrno = value
            .trim()
            .removeAllWhitespace
            .replaceAll('"', "")
            .replaceAll("'", ""),
        autofocus: true,
        decoration: InputDecoration(
          labelStyle: MyStyle().myLabelStyle(),
          labelText: 'เลขที่',
          //prefixIcon: Icon(Icons.account_circle, color: MyStyle().darkcolor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().lightcolor),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyStyle().darkcolor),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        cursorColor: Color(0xffffffff),
        style: GoogleFonts.kanit(
            fontStyle: FontStyle.normal,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff000000)),
      ),
    );
  }

  Container buildVilage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white70,
      ),
      margin: EdgeInsets.all(5),
      width: screen * 0.9,
      height: 54,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        initialValue: _vilage,
        onChanged: (value) => vilage = value
            .trim()
            .removeAllWhitespace
            .replaceAll('"', "")
            .replaceAll("'", ""),
        autofocus: true,
        decoration: InputDecoration(
          labelStyle: MyStyle().myLabelStyle(),
          labelText: 'หมู่บ้าน',
          //prefixIcon: Icon(Icons.account_circle, color: MyStyle().darkcolor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().lightcolor),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyStyle().darkcolor),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        cursorColor: Color(0xffffffff),
        style: GoogleFonts.kanit(
            fontStyle: FontStyle.normal,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff000000)),
      ),
    );
  }

  Container buildZipcode() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white70,
      ),
      margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
      width: screen * 0.35,
      height: 54,
      child: TextFormField(
        keyboardType: TextInputType.number,
        initialValue: _zipcode,
        onChanged: (value) => zipcode = value.trim(),
        autofocus: true,
        decoration: InputDecoration(
          labelStyle: MyStyle().myLabelStyle(),
          labelText: 'รหัสไปรษณีย์',
          //prefixIcon: Icon(Icons.account_circle, color: MyStyle().darkcolor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().lightcolor),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyStyle().darkcolor),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        cursorColor: Color(0xffffffff),
        style: GoogleFonts.kanit(
            fontStyle: FontStyle.normal,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff000000)),
      ),
    );
  }

  Container buildProvince() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
        ),
        margin: EdgeInsets.all(5),
        width: screen * 0.9,
        //child: PopupMenuItem(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              listProv.length > 0
                  ? Obx(() => ExpansionTile(
                      title: MyStyle().txtblack16TH('จังหวัด'),
                      children: listProv
                          .map(
                            (e) => RadioListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [MyStyle().txtTH20Dark(e.txtvalue)],
                                ),
                                value: e,
                                groupValue: provController.selectProv.value,
                                onChanged: (value) {
                                  setState(() {
                                    //_province = e.id.toString();
                                    provController.selectProv.value = value;
                                    provController.provno = e.id;
                                    provController.provname = e.txtvalue;
                                    //_provno = e.id;
                                    //_provname = e.txtvalue;
                                    getAmpher();
                                  });
                                }),
                          )
                          .toList()))
                  : Loader()
            ])
        //)
        );
  }

  Container buildAmpher() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
        ),
        margin: EdgeInsets.all(5),
        width: screen * 0.9,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              listAmpher.length > 0
                  ? Obx(() => ExpansionTile(
                      title: MyStyle().txtblack16TH('อำเภอ'),
                      children: listAmpher
                          .map(
                            (e) => RadioListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [MyStyle().txtTH20Dark(e.txtvalue)],
                              ),
                              value: e,
                              groupValue: provController.selectAmpher.value,
                              onChanged: (value) {
                                setState(() {
                                  provController.selectAmpher.value = value;
                                  provController.ampherno = e.id;
                                  provController.amphername = e.txtvalue;
                                  //_ampherno = e.id;
                                  //_amphername = e.txtvalue;
                                  getTumbon();
                                });
                              },
                            ),
                          )
                          .toList()))
                  : Container()
            ]));
  }

  Container buildTambon() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
        ),
        margin: EdgeInsets.all(5),
        width: screen * 0.9,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              listTambon.length > 0
                  ? Obx(() => ExpansionTile(
                      title: MyStyle().txtblack16TH('ตำบล'),
                      children: listTambon
                          .map(
                            (e) => RadioListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [MyStyle().txtTH20Dark(e.txtvalue)],
                              ),
                              value: e,
                              groupValue: provController.selectTambon.value,
                              onChanged: (value) {
                                setState(() {
                                  provController.selectTambon.value = value;
                                  provController.tambonno = e.id;
                                  provController.tambonname = e.txtvalue;
                                  //_tambonno = e.id;
                                  //_tambonname = e.txtvalue;
                                });
                              },
                            ),
                          )
                          .toList()))
                  : Container()
            ]));
  }

  Container buildMobile() {
    return Container(
      width: screen * 0.75,
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton('1'),
              buildButton('2'),
              buildButton('3'),
            ],
          ),
          SizedBox(height: hi),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton('4'),
              buildButton('5'),
              buildButton('6'),
            ],
          ),
          SizedBox(height: hi),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton('7'),
              buildButton('8'),
              buildButton('9'),
            ],
          ),
          SizedBox(height: hi),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              clearButton(),
              buildButton('0'),
              delButton(),
            ],
          ),
        ],
      ),
    );
  }

  Container buildRegister() {
    return Container(
        margin: EdgeInsets.only(top: 10),
        width: screen * 0.95,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            String mess = validData();
            if (mess == '') {
              checkUser();
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  MySnackBar.showSnackBar(mess, Icons.sick,
                      strDimiss: 'ลองใหม่'),
                );
            }
          },
          child: MyStyle().titleLight('ลงทะเบียน'),
          style: ElevatedButton.styleFrom(
              primary: MyStyle().darkcolor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        ));
  }

  String validData() {
    // pin1 = '1234';
    // pin2 = '1234';
    // mobile = '0863836099';
    // user = 'vanathorn';
    // addrno = '103/33';
    // vilage = 'กลอรี่เฮาท์โครงการ1';
    // provController.provno = 12;
    //---------------------------------
    valid = false;
    String mess = '';
    String linefeed = '';
    if (user?.isEmpty ?? true) {
      mess = '! ระบุข้อมูลชื่อ';
      linefeed = '\r\n';
    }
    choosetype = 'U';
    // List<AddonModel> addonItems = mbtypeController.selectAddon;
    // if (addonItems != null && addonItems.length > 0) {
    //   addonItems.forEach((addon) {
    //     choosetype += (choosetype != '' ? '|' : '') + addon.optcode;
    //   });
    // }
    if ((addrno?.isEmpty ?? true)) {
      mess += linefeed + '! ระบุบ้านเลขที่';
      linefeed = '\r\n';
    }
    if ((vilage?.isEmpty ?? true)) {
      mess += linefeed + '! ระบุชื่อหมู่บ้าน';
      linefeed = '\r\n';
    }
    if (provController.provno == 0) {
      mess += linefeed + '! ระบุจังหวัด';
      linefeed = '\r\n';
    }
    if (zipcode != null && zipcode != '' && zipcode.length != 5) {
      mess += linefeed + '! รหัสไปรษณีย์ไม่ถูกต้อง';
      linefeed = '\r\n';
    }
    if ((choosetype?.isEmpty ?? true)) {
      mess += linefeed + '! เลือกประเภทสมาชิก';
      linefeed = '\r\n';
    }
    if (mobile.length != maxmobile) {
      mess += linefeed + '! เบอร์ไม่ถูกต้อง (' + mobile + ')';
      linefeed = '\r\n';
    }
    if (mess != '') return mess;
    //-------------------------
    if ((pin1.length == maxpin) && (pin2.length == maxpin)) {
      if (pin1 != pin2) {
        mess += linefeed + '! รหัสไม่ตรงกัน';
      } else {
        valid = true;
        password = pin1;
        mess = '';
      }
    } else {
      mess += linefeed + '! รหัสไม่ครบ ' + maxpin.toString() + ' หลัก';
    }
    return mess;
  }

  Future<Null> checkUser() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'JsonCheckMobile.aspx?Mobile=$mobile';
    try {
      Response response = await Dio().get(url);
      if (response.toString().trim() == '[]') {
        registerTread();
      } else {
        alertDialog(context, '! ' + mobile + ' ถูกลงทะเบียนแล้ว');
        setState(() {
          setMode('MOBILE');
        });
      }
    } catch (e) {
      alertDialog(context, '!ไม่สามารถติดต่อ Server ได้');
    }
  }

  Future<Null> registerTread() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'insertUser.aspx?Name=$user&Psw=$password&Mobile=$mobile&cType=$choosetype';

    String _ampher = '';
    String _tambon = '';
    String _zipcode = '';
    if (provController.ampherno != 0) _ampher = provController.amphername;
    if (provController.tambonno != 0) _tambon = provController.tambonname;
    if (zipcode != null && zipcode != '' && zipcode.length == 5) {
      _zipcode = zipcode;
    }
    String strExec = "update dbo.MemberCustomer set addrno='$addrno'," +
        "vilage='$vilage'," +
        "lat='" +
        lat.toString() +
        "',lng='" +
        lng.toString() +
        "'," +
        "province='${provController.provname}'";

    if (_ampher != '') strExec += ",ampher='$_ampher' ";
    if (_tambon != '') strExec += ",tambon='$_tambon' ";
    if (_zipcode != '') strExec += ",zipcode='$_zipcode' ";
    strExec += " where Mobile='$mobile' ";
    //debugPrint('***** 2. strExec = $strExec');
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        SQLService().execute(strExec);
        checkAuthen(mobile, password);
      } else {
        alertDialog(context, response.toString());
      }
    } catch (e) {
      alertDialog(
          context, '!ไม่สามารถติดต่อ Serverได้'); //'!ไม่สามารถติดต่อ Serverได้'
    } finally {
      //SqlConn.disconnect();
    }
  }

  Future<Null> checkAuthen(String mobile, String password) async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkLogin.aspx?Mobile=$mobile&Psw=$password';

    try {
      Response response = await Dio().get(url);
      var result = json.decode(response.data);
      for (var map in result) {
        //cartViewModel.resetCart(controller);
        UserModel usermodel = UserModel.fromJson(map);
        if (mobile == usermodel.mobile && password == usermodel.psw) {
          String chooseType = usermodel.mbtcode;
          if (choosetype?.isEmpty ?? true) {
            alertDialog(context, '!ประเภทผู้ใช้งานไม่ถูกต้อง');
          } else {
            MyUtil().sendNoticToAdmin('!มีผู้ลงทะเบียนใหม่',
                'ชื่อ:${usermodel.mbname} ${usermodel.mobile}');
            usermodel.webpath = '${MyConstant().fixwebpath}';
            if (chooseType == 'U') {
              routeToService(MainUser(), usermodel);
            } else if (chooseType == 'R') {
              routeToService(MainRider(), usermodel);
            } else if (chooseType == 'S') {
              routeToService(MainShop(), usermodel);
            } else {
              //='M'
              routeToService(MultiHome(), usermodel);
            }
          }
        } else {
          alertDialog(context, '!ข้อมูลไม่ถูกต้อง');
        }
      }
    } catch (e) {
      alertDialog(context, '!ไม่สามารถติดต่อ Serverได้');
    }
  }

  Future<Null> routeToService(Widget myWidget, UserModel userModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String webpath = (userModel.webpath != '')
        ? userModel.webpath
        : '${MyConstant().fixwebpath}';
    prefs.setString('pid', userModel.mbid);
    prefs.setString('pchooseCode', userModel.mbtcode);
    prefs.setString('pchooseType', userModel.mbtname);
    prefs.setString('pname', userModel.mbname);
    prefs.setString('pmobile', userModel.mobile);
    prefs.setString('pccode', userModel.ccode);
    prefs.setString('pstrconn', userModel.strconn);
    prefs.setString('pwebpath', webpath);
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  GestureDetector buildButton(String txtValue) {
    return GestureDetector(
      child: InkWell(
        onTap: () {
          _incrementMobile(txtValue);
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.black,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[350],
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(70))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(txtValue,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    color: (mode == 'PIN1')
                        ? Colors.redAccent[700]
                        : (mode == 'PIN2')
                            ? Color.fromARGB(255, 1, 61, 28)
                            : Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Container delButton() {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: _decrementMobile,
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(
          Icons.backspace,
          color: Colors.white,
          size: 32,
        ),
        splashColor: Colors.blue,
      ),
    );
  }

  Container clearButton() {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      width: 56,
      height: 56,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black54,
        onPressed: _clearNumber,
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            )),
        icon: Icon(
          Icons.clear_all,
          color: Colors.white,
          size: 38,
        ),
        splashColor: Colors.redAccent[400],
      ),
    );
  }

  void _clearNumber() {
    setState(() {
      if (mode == 'MOBILE') {
        mobile = '';
        txtmobile = '';
        txtencrypt = '';
      } else if (mode == 'PIN1') {
        setMode('PIN1');
      } else if (mode == 'PIN2') {
        setMode('PIN2');
      } else {
        //
      }
    });
  }

  void _incrementMobile(String txtinput) {
    setState(() {
      String tmp = '';
      if (mode == 'MOBILE') {
        tmp = mobile;
        if (tmp.length < maxmobile) {
          mobile += txtinput;
          setTxtMobile();
        }
      } else if (mode == 'PIN1') {
        tmp = pin1;
        if (tmp.length < maxpin) {
          pin1 += txtinput;
          setTxtPin1();
        }
      } else if (mode == 'PIN2') {
        tmp = pin2;
        if (tmp.length < maxpin) {
          pin2 += txtinput;
          setTxtPin2();
        }
      } else {
        //
      }
    });
  }

  void _pinScreen() {
    setState(() {
      setMode('PIN1');
    });
  }

  void _decrementMobile() {
    setState(() {
      String tmp = '';
      if (mode == 'MOBILE') {
        tmp = mobile;
        if (tmp.length > 0) {
          mobile = tmp.substring(0, tmp.length - 1);
          setTxtMobile();
        }
      } else if (mode == 'PIN1') {
        tmp = pin1;
        if (tmp.length > 0) {
          pin1 = tmp.substring(0, tmp.length - 1);
          setTxtPin1();
        }
      } else if (mode == 'PIN2') {
        if (tmp.length > 0) {
          pin2 = tmp.substring(0, tmp.length - 1);
          setTxtPin2();
        }
      } else {
        //
      }
    });
  }

  void setTxtMobile() {
    txtmobile = '';
    txtencrypt = '';
    String comm = '';
    for (int i = 0; i < mobile.length; i++) {
      txtencrypt += comm + 'x';
      txtmobile += comm + mobile.substring(i, i + 1);
      comm = '';
    }
    if (mobile.length == maxmobile) {
      Toast.show(
        'รหัส 4 หลัก',
        context,
        gravity: Toast.CENTER,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
      );
      setState(() {
        setMode('PIN1');
      });
    }
  }

  void setTxtPin1() {
    txtpin1 = '';
    txtencryptpin1 = '';
    String comm = '';
    for (int i = 0; i < pin1.length; i++) {
      txtencryptpin1 += comm + 'x';
      txtpin1 += comm + pin1.substring(i, i + 1);
      comm = ' ';
    }
    if (pin1.length == maxpin) {
      Toast.show(
        'ทบทวนรหัส 4 หลัก อีกครั้ง',
        context,
        gravity: Toast.CENTER,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
      );
      setState(() {
        setMode('PIN2');
      });
    }
  }

  void setTxtPin2() {
    txtpin2 = '';
    txtencryptpin2 = '';
    String comm = '';
    for (int i = 0; i < pin2.length; i++) {
      txtencryptpin2 += comm + 'x';
      txtpin2 += comm + pin2.substring(i, i + 1);
      comm = ' ';
    }
    if (pin2.length == maxpin) {
      if (pin1 == pin2) {
        String mess = validData();
        if (mess == '') {
          setState(() {
            valid = true;
          });
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              MySnackBar.showSnackBar(mess, Icons.app_blocking_outlined,
                  strDimiss: 'ลองใหม่'),
            );
          setState(() {
            setMode('MOBILE');
          });
        }
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            MySnackBar.showSnackBar('รหัสไม่ตรงกัน', Icons.memory,
                strDimiss: 'ลองใหม่'),
          );
        setState(() {
          setMode('PIN1');
        });
      }
    }
  }

  void setMode(String setmode) {
    mode = setmode;
    if (setmode == 'MOBILE') {
      stepInfo = 'มือถือ';
    } else if (setmode == 'PIN1') {
      stepInfo = 'รหัส 4 หลัก';
      pin1 = '';
      pin2 = '';
      txtencryptpin1 = '';
      txtencryptpin2 = '';
      txtpin1 = '';
      txtpin2 = '';
    } else if (setmode == 'PIN2') {
      stepInfo = 'ทบทวนรหัส 4 หลัก';
      pin2 = '';
      txtencryptpin2 = '';
      txtpin2 = '';
    } else {
      //
    }
  }

  Future<Null> clearConnection() async {
    SQLService().clearConn();
  }
}
