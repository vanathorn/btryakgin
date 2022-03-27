import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/user_model.dart';
import 'package:yakgin/screen/SingUp.dart';
import 'package:yakgin/screen/home.dart';
import 'package:yakgin/screen/menu/main_admin.dart';
import 'package:yakgin/screen/menu/main_rider.dart';
import 'package:yakgin/screen/menu/main_shop.dart';
import 'package:yakgin/screen/menu/main_user.dart';
import 'package:yakgin/screen/menu/multi_home.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/widget/mysnackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

//import 'package:flutter_circular_text/circular_text.dart';
//import 'package:flutter_circular_text/circular_text/widget.dart';
//CircleProgress https://stackoverflow.com/questions/58218281/circleprogress-with-custom-strokecap-image-flutter

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  double screen;
  bool redeye = true;
  String mode = 'MOBILE', stepInfo = 'เบอร์มือถือ';
  String txtmobile = '', txtencrypt = '', mobile = '', txtinput = '';
  String txtpin = '', txtencryptpin = '', pin = '';
  final int maxmobile = 10;
  final int maxpin = 4;
  bool valid = false;

  //final CartStateController controller = dget.Get.find();
  //final CartViewModelImp cartViewModel = new CartViewModelImp();

  void _clearNumber() {
    setState(() {
      if (mode == 'MOBILE') {
        mobile = '';
        txtmobile = '';
        txtencrypt = '';
      } else if (mode == 'PIN') {
        setMode('PIN');
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
      } else if (mode == 'PIN') {
        tmp = pin;
        if (tmp.length < maxpin) {
          pin += txtinput;
          setTxtPin();
        }
      } else {
        //
      }
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
      } else if (mode == 'PIN') {
        tmp = pin;
        if (tmp.length > 0) {
          pin = tmp.substring(0, tmp.length - 1);
          setTxtPin();
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
      comm = ' ';
    }
    if (mobile.length == maxmobile) {
      Toast.show(
        'รหัส(PIN Code) 4 หลัก',
        context,
        gravity: Toast.CENTER,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
      );
      setState(() {
        setMode('PIN');
      });
    }
  }

  void setTxtPin() {
    txtpin = '';
    txtencryptpin = '';
    String comm = '';
    for (int i = 0; i < pin.length; i++) {
      txtencryptpin += comm + 'x';
      txtpin += comm + pin.substring(i, i + 1);
      comm = ' ';
    }
    if (pin.length == maxpin) {
      _validData();
    }
  }

  void _validData() {
    if (mode == 'MOBILE') {
      if ((mobile?.isEmpty ?? true) || (mobile.length != maxmobile)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            MySnackBar.showSnackBar(
                "!เบอร์ไม่ครบ $maxmobile หลัก", Icons.app_blocking_outlined,
                strDimiss: 'ลองใหม่'),
          );
        setState(() {
          setMode('MOBILE');
        });
      } else {
        setState(() {
          setMode('PIN');
        });
      }
    } else if (mode == 'PIN') {
      if (pin.length == maxpin) {
        checkAuthen();
      }
    } else {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyStyle().primarycolor,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                          MaterialPageRoute(builder: (value) => SignUp());
                      Navigator.push(context, route);
                    },
                    child: MyStyle().titleLight('สมัครใหม่')))
          ])),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/wallsignin.jpg"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildLogo(),
              //MyStyle().txtbrandsmall('Yakgin'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: txtInfo(stepInfo),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //buildShowMobileNo(),
                  //circularPassword(),
                  //SizedBox(width: 10),
                  (mode == 'PIN')
                      ? buildShowText(txtencryptpin, txtpin)
                      : buildShowText(txtencrypt, txtmobile),
                  buildRedEye(),
                  Container(
                    margin: const EdgeInsets.only(right: 3.0),
                    width: 85,
                    child: (mode == 'MOBILE')
                        ? buildBtnPin()
                        : (mode == 'PIN')
                            ? buildBtnMobile()
                            : Text(''),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Divider(
                  thickness: 1,
                  color: Colors.lightGreen,
                ),
              ),
              Container(
                width: screen * 0.8,
                margin: const EdgeInsets.only(bottom: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildButton('1'),
                        buildButton('2'),
                        buildButton('3'),
                      ],
                    ),
                    SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildButton('4'),
                        buildButton('5'),
                        buildButton('6'),
                      ],
                    ),
                    SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildButton('7'),
                        buildButton('8'),
                        buildButton('9'),
                      ],
                    ),
                    SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        clearButton(),
                        //btnConstrained('0'),
                        buildButton('0'),
                        delButton(),
                        //okButton()
                        /*
                        Container(
                          margin: const EdgeInsets.only(left:8),
                          width: 56,
                          height:56,
                          child: (mode == 'MOBILE')
                              ? buildBtnPin()
                              : (mode == 'PIN')
                                  ? buildBtnMobile()
                                  : Text(''),
                        )*/
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setMode(String setmode) {
    mode = setmode;
    if (setmode == 'MOBILE') {
      stepInfo = 'เบอร์มือถือ';
    } else if (setmode == 'PIN') {
      stepInfo = 'รหัส 4 หลัก';
      pin = '';
      txtencryptpin = '';
      txtpin = '';
    } else {
      //
    }
  }

  void _pinScreen() {
    setState(() {
      setMode('PIN');
    });
  }

  void _monileScreen() {
    setState(() {
      setMode('MOBILE');
    });
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

  FloatingActionButton buildBtnMobile() {
    return FloatingActionButton.extended(
      backgroundColor: MyStyle().savecolor,
      onPressed: _monileScreen,
      label: Text('มือถือ',
          style: TextStyle(
            fontFamily: 'thaisanslite',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          )),
      icon: Icon(
        Icons.mobile_friendly,
        color: Colors.white,
        size: 32,
      ),
      splashColor: Colors.white,
    );
  }

  Widget txtInfo(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: (mode == 'PIN') ? Colors.redAccent[700] : Colors.black,
      ));

  Container buildShowMobileNo() {
    return Container(
        child: (redeye)
            ? Text(
                '$txtencrypt',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff030342),
                  fontWeight: FontWeight.normal,
                ),
              )
            : Text(
                '$txtmobile',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent[700],
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

  GestureDetector buildButton(String txtValue) {
    return GestureDetector(
      // onTap: () {
      //   _incrementMobile(txtValue);
      // },
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
                    color:
                        (mode == 'PIN') ? Colors.redAccent[700] : Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  ConstrainedBox btnConstrained(String txtValue) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 70, height: 70),
      child: ElevatedButton(
        child: Text(
          txtValue,
          style: TextStyle(fontSize: 26),
        ),
        onPressed: () {
          _incrementMobile(txtValue);
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(), //primary: Colors.transparent
          primary: Color.fromRGBO(0, 0, 0, 0.001),
        ),
      ),
    );
  }

  Container delButton() {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: _decrementMobile,
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 14,
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
      width: 54,
      height: 54,
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

  /*
  Container okButton() {
    return Container(
      width: 56,
      height: 56,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent[400],
        onPressed: _validData,
        label: Text('',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(
          Icons.done,
          color: Colors.white,
          size: 32,
        ),
        splashColor: Colors.white,
      ),
    );
  }
  */

  Container buildPassword() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: screen * 0.42,
      height: 64,
      child: TextField(
        readOnly: false,
        onChanged: (value) => txtmobile = value.trim(),
        obscureText: redeye,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          filled: true,
          suffixIcon: IconButton(
            icon: redeye
                ? Icon(Icons.remove_red_eye)
                : Icon(Icons.remove_red_eye_outlined),
            onPressed: () {
              setState(() {
                redeye = !redeye;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textAlign: TextAlign.center,
        cursorColor: Color(0xffffffff),
        style: GoogleFonts.kanit(
            fontStyle: FontStyle.normal,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff000000)),
      ),
    );
  }

  Container buildLogo() {
    return Container(
        width: screen * 0.28,
        //margin: const EdgeInsets.only(top: 0),
        child: MyUtil().showLogo());
  }

  Container buildShowText(String strEncrypt, String strNormal) {
    return Container(
        margin: const EdgeInsets.only(left: 5.0),
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
                  fontSize: 17,
                  color: Color(0xff030342),
                  fontWeight: FontWeight.normal,
                ),
              ));
  }

  TextButton buildRegister() => TextButton(
        onPressed: () => Navigator.pushNamed(context, '/signup'),
        child: Text(
          'Register',
          style: GoogleFonts.kanit(
              fontStyle: FontStyle.normal,
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: MyStyle().blackcolor),
        ),
      );

  Future<Null> checkAuthen() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkMobile.aspx?Mobile=$mobile';
    try {
      Response response = await Dio().get(url);
      //response.headers.add("Access-Control-Allow-Headers", "*");
      //response.headers.add('Access-Control-Allow-Credentials', "true");
      //response.headers
      if (response.toString().trim() == '') {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            MySnackBar.showSnackBar(
                "!มือถือ ($mobile)\r\nไม่ถูกต้อง", Icons.app_blocking_outlined,
                strDimiss: 'ลองใหม่'),
          );
        setState(() {
          setMode('MOBILE');
        });
      } else {
        var result = json.decode(response.data);
        for (var map in result) {
          UserModel usermodel = UserModel.fromJson(map);
          if (mobile == usermodel.mobile) {
            if (pin == usermodel.psw) {
              String chooseCode = usermodel.mbtcode;
              if (chooseCode == 'U') {
                usermodel.webpath = '${MyConstant().fixwebpath}';
                routeToService(MainUser(), usermodel);
              } else if (chooseCode == 'R') {
                routeToService(MainRider(), usermodel);
              } else if (chooseCode == 'S') {
                routeToService(MainShop(), usermodel);
              } else if (chooseCode == 'A') {
                routeToService(MainAdmin(), usermodel);
              } else {
                routeToService(MultiHome(), usermodel);
              }
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  MySnackBar.showSnackBar("! รหัส ไม่ถูกต้อง", Icons.memory,
                      strDimiss: 'ลองใหม่'),
                );
              setState(() {
                setMode('PIN');
              });
            }
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                MySnackBar.showSnackBar(
                    "!เบอร์มือถือไม่ถูกต้อง", Icons.mobile_off,
                    strDimiss: 'ลองใหม่'),
              );
          }
        }
      }
    } catch (e) {
      debugPrint('*** ${e.toString()}');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar("!ติดต่อ Server ไม่ได้", Icons.cloud_off),
        );
    }
  }

  Future<Null> routeToService(Widget myWidget, UserModel userModel) async {
    String token = "";
    try {
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
      prefs.setString('pbrcode', userModel.brcode);
      prefs.setString('pbrname', userModel.brname);
      prefs.setString('pstrconn', userModel.strconn);
      prefs.setString('pwebpath', webpath);

      String loginId = userModel.mbid;
      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      token = await firebaseMessaging.getToken();
      //token = await FirebaseMessaging.instance.getToken();

      print(' SignIn loginId=$loginId ccode=${userModel.ccode} token=$token');
      if (loginId != null &&
          loginId.isNotEmpty &&
          token != null &&
          token.isNotEmpty) {
        String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
            'updateToken.aspx?mbid=$loginId&token=$token';
        await Dio()
            .get(url)
            .then((value) => print('SignIn Update Token Success'));
      }
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => myWidget,
      );
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    } catch (ex) {
      alertDialog(context, 'Sign in : routeToService Error ' + ex.toString());
    }
  }

  /*  Sample CircularText
  Row circularPassword() {
    return Row(
      children: [
        CircularText(
            children: [              
              TextItem(
                  text: Text(
                    "1",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  space: 0,
                  startAngle: -90,
                  startAngleAlignment: StartAngleAlignment.start,
                  direction: CircularTextDirection.clockwise,
              ),              
              TextItem(
                text: (redeye)
                    ? Text(
                        '$txtencrypt',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.redAccent[400],
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    : Text(
                        '$txtmobile',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.green[800],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                space: 35,
                startAngle: 90,
                startAngleAlignment: StartAngleAlignment.center,
                direction: CircularTextDirection.anticlockwise,
              ),
            ],
            radius: 38,
            position: CircularTextPosition.inside,
            backgroundPaint: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..strokeCap = StrokeCap.round
              ..color = Colors.transparent //Color.fromRGBO(255, 300, 10, 0.1),
            ),
      ],
    );
  }
  */
}
