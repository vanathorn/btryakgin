import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/screen/SignIn.dart';
import 'package:btryakgin/screen/home.dart';
import 'package:btryakgin/widget/mysnackbar.dart';
import 'package:get/get.dart' as dget;
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:btryakgin/model/addon_model.dart';
import 'package:btryakgin/model/login_model.dart';
import 'package:btryakgin/model/m_model.dart';
import 'package:btryakgin/model/user_model.dart';
import 'package:btryakgin/screen/menu/main_rider.dart';
import 'package:btryakgin/screen/menu/main_shop.dart';
import 'package:btryakgin/screen/menu/main_user.dart';
import 'package:btryakgin/screen/menu/multi_home.dart';
import 'package:btryakgin/state/memtype_detail_state.dart';
import 'package:btryakgin/state/memtype_list_state.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/utility/myutil.dart';
import 'package:toast/toast.dart';

//import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  double screen;
  bool redeye = true;
  String _user, user, mobile = '', choosetype;
  String txtmobile = '', txtencrypt = '', txtinput = '';
  String mode = 'MOBILE', pin1 = '', pin2 = '', txtpin1 = '', txtpin2 = '';
  String txtencryptpin1 = '', txtencryptpin2 = '';
  final int maxmobile = 10;
  final int maxpin = 4;
  final double hi = 17;
  String password = '', stepInfo = 'มือถือ';
  //FocusNode myFocusNode;
  var isExpanProf = false;
  var isExpanType = false;
  bool valid = false;
  LoginModel foodModel = new LoginModel();

  MemtypeListStateController listStateController;
  List<AddonModel> addons = List<AddonModel>.empty(growable: true);
  MemTypeDetailStateController foodController =
      dget.Get.put(MemTypeDetailStateController());

  @override
  void initState() {
    super.initState();
    foodModel.mbtid = 0;
    foodModel.mbtname = 'Signup User';
    listStateController = dget.Get.put(MemtypeListStateController());
    getMemberType();
    foodController.selectAddon.clear();
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

  Future<Null> getMemberType() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
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
              foodModel.mbtid = 0;
              foodModel.mbtname = '';
              foodModel.addonM = addons.toList();
              listStateController = dget.Get.find();
              listStateController.selectedMember.value = foodModel;
            });
          }
        }
      });
    } catch (ex) {
      //
    }
  }

  _onExpanProfChanged(bool val) {
    setState(() {
      isExpanProf = val;
      _user = user;
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
                    child: MyStyle().titleDark('เข้าใช้ระบบ')))
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
                buildMTypeChoice(),
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
                    ? MyStyle().txtTH20Dark('ระบุรหัสพิน 4 หลัก')
                    : (mode == 'PIN2')
                        ? MyStyle().txtTH20Dark('ทวนรหัสพินอีกครั้ง')
                        : Text('')
          ],
        ));
  }

  Container buildLogo() {
    return Container(width: screen * 0.3, child: MyUtil().showLogo());
  }

  Container buildProfile() {
    return Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
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
                    children: [buildUser()],
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
                                        label: foodController.selectAddon
                                                .contains(e)
                                            ? MyStyle()
                                                .subTitleDrawerLight(e.optname)
                                            : MyStyle()
                                                .subTitleDrawerDark(e.optname),
                                        selectedColor: Colors.black,
                                        disabledColor: Colors.grey[100],
                                        selected: foodController.selectAddon
                                            .contains(e),
                                        onSelected: (selected) {
                                          setState(() {
                                            selected
                                                ? foodController.selectAddon
                                                    .add(e)
                                                : foodController.selectAddon
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
    valid = false;
    String mess = '';
    String linefeed = '';
    if (user?.isEmpty ?? true) {
      mess = '! ระบุข้อมูลชื่อ';
      linefeed = '\r\n';
    }
    choosetype = '';
    List<AddonModel> addonItems = foodController.selectAddon;
    if (addonItems != null && addonItems.length > 0) {
      addonItems.forEach((addon) {
        choosetype += (choosetype != '' ? '|' : '') + addon.optcode;
      });
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
        mess += linefeed + '! รหัสพินไม่ตรงกัน';
      } else {
        valid = true;
        password = pin1;
        mess = '';
      }
    } else {
      mess += linefeed + '! รหัสพินไม่ครบ ' + maxpin.toString() + ' หลัก';
    }
    return mess;
  }

  Future<Null> checkUser() async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
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
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
        'insertUser.aspx?Name=$user&Psw=$password&Mobile=$mobile&cType=$choosetype';

    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        checkAuthen(mobile, password);
      } else {
        alertDialog(context, response.toString());
      }
    } catch (e) {
      alertDialog(
          context, '!ไม่สามารถติดต่อ Serverได้'); //'!ไม่สามารถติดต่อ Serverได้'
    }
  }

  Future<Null> checkAuthen(String mobile, String password) async {
    String url = '${MyConstant().domain}/${MyConstant().apipath}/' +
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
        'ระบุรหัสพิน 4 หลัก',
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
        'ทบทวนระบุรหัสพินอีกครั้ง',
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
            MySnackBar.showSnackBar('รหัสพินไม่ตรงกัน', Icons.memory,
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
      stepInfo = 'รหัสพิน 4 หลัก';
      pin1 = '';
      pin2 = '';
      txtencryptpin1 = '';
      txtencryptpin2 = '';
      txtpin1 = '';
      txtpin2 = '';
    } else if (setmode == 'PIN2') {
      stepInfo = 'ทบทวนรหัสพิน';
      pin2 = '';
      txtencryptpin2 = '';
      txtpin2 = '';
    } else {
      //
    }
  }
}
