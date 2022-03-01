import 'package:flutter/material.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; //FontFeature

class MyStyle {
  Color primarycolor = Color(0xffBFB372);
  Color secondarycolor = Color.fromARGB(0, 4, 4, 236);
  Color darkcolor = Color(0xff030342);
  Color lightcolor = Color(0xffeadd94);
  Color blackcolor = Color(0xff000000);
  Color whitecolor = Color(0xffffffff);
  Color hintcolor = Color(0xffb8bbbc);
  Color logocolor = Color(0xff0a0a77);
  Color headcolor = Colors.deepPurpleAccent;
  Color menubgcolor = Color(0xffBFB372);
  Color icondrawercolor = Color(0xff7f0000);
  Color coloroverlay = Color(0x99333639);
  Color savecolor = Color.fromARGB(255, 0, 0, 80);
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget showProgress() {
    return Center(child: CircularProgressIndicator());
  }

  Widget mobileProgress(bool isweb) {
    return Center(child: isweb ? Text('') : CircularProgressIndicator());
  }

  Widget txtbrandsty(String strtxt) => Text(strtxt,
      style: GoogleFonts.lato(
          fontStyle: FontStyle.normal,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primarycolor,
          fontFeatures: [
            FontFeature.enable('subs'),
          ]));

  Widget txtTitle(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'Holligate',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: logocolor,
      ));

  Widget txtshadowsIntoLight(String strtxt) => Text(strtxt,
      style: GoogleFonts.shadowsIntoLight(
          fontStyle: FontStyle.normal,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: blackcolor,
          fontFeatures: [
            FontFeature.enable('subs'),
          ]));

  Widget txtprice(String strtxt) => Text(strtxt,
      style: GoogleFonts.lato(
          fontStyle: FontStyle.normal,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: blackcolor,
          fontFeatures: [
            FontFeature.enable('subs'),
          ]));

  Widget txtbrand(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'Berdiri',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: logocolor,
      ));

  Widget txtbrandsmall(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'Berdiri',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: logocolor,
      ));

  Widget txtbrandwhite(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'Berdiri',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ));

  Widget titleH1(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: primarycolor,
      ));

  Widget titleH2(String strtxt) => Text(
        strtxt,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: primarycolor),
      );

  Widget txt15(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: headcolor,
      ));

  Widget txtH16(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));

  Widget txtTH18Dark(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget txtTH18Light(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ));

  Widget txtTH20Dark(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget txtTH20Light(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ));

  Widget txtTH18Color(String strtxt, Color txtcolor) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: txtcolor,
      ));

  Widget txtbody(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));

  Widget titleH5(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: Colors.lightBlue,
      ));

  Widget titleDrawer(String strtxt) => Text(strtxt,
      style: GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xff0a0a77),
      ));

  Widget titleDrawerLight(String strtxt) => Text(strtxt,
      style: TextStyle(
          fontFamily: 'thaisanslite',
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
          color: Colors.white));

  Widget subTitleDrawerLight(String strtxt) => Text(strtxt,
      style: TextStyle(
          fontFamily: 'thaisanslite',
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          color: Colors.white));

  Widget titleDrawerDark(String strtxt) => Text(strtxt,
      style: TextStyle(
          fontFamily: 'thaisanslite',
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
          color: Colors.black));

  Widget subTitleDrawerDark(String strtxt) => Text(strtxt,
      style: TextStyle(
          fontFamily: 'thaisanslite',
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          color: Colors.black));

  Widget subtitleDrawer(String strtxt) => Text(strtxt,
      style: GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.black45,
      ));

  Widget titleCenter(
      BuildContext context, String strtxt, double fsize, Color txtcolor) {
    return Center(
        child: Container(
      child: Text(strtxt,
          style: GoogleFonts.kanit(
            fontStyle: FontStyle.normal,
            fontSize: fsize,
            fontWeight: FontWeight.normal,
            color: txtcolor,
          )),
    ));
  }

  Widget titleCenterTH(
      BuildContext context, String strtxt, double fsize, Color txtcolor) {
    return Center(
        child: Container(
      //width: MediaQuery.of(context).size.width*0.5,
      child: Text(strtxt,
          style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: fsize,
              fontWeight: FontWeight.normal,
              color: txtcolor)),
    ));
  }

  Widget titleDark(String strtxt) => Text(strtxt,
      style: GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xff000000),
      ));

  Widget subtitleDark(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black26,
      ));

  Widget titleLight(String strtxt) => Text(strtxt,
      style: GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xffffffff),
      ));

  Widget subtitleLight(String strtxt) => Text(strtxt,
      style: GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: Colors.white54,
      ));

  Widget titleTH(String strtxt, Color txtcolor) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: txtcolor,
      ));

  Widget txtstyle(String strtxt, Color txtcolor, double txtsize) => Text(strtxt,
      style: GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: txtsize,
        fontWeight: FontWeight.normal,
        color: txtcolor,
      ));
  Widget txtblack12TH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget txtwhite14TH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ));
  Widget txtblack14TH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget txtblack16TH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget txtblack17TH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 17,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget txtblack18TH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));
  Widget signout(String strtxt) => Text(strtxt,
      style: GoogleFonts.kanit(
          fontStyle: FontStyle.normal,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Color(0xffffffff),
          fontFeatures: [
            FontFeature.enable('subs'),
          ]));

  Widget subSignout(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ));

  Widget txtTH(String strtxt, Color txtcolor) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: txtcolor,
      ));

  Widget txtbodyTH(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ));

  Widget txtTHRed(String strtxt) => Text(strtxt,
      style: TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.red.shade800,
      ));

  void get hintStyle => (GoogleFonts.kanit(
        fontStyle: FontStyle.normal,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xff000000),
      ));

  TextStyle errStyle() => TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

  TextStyle infoStyle() => TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.blueAccent[700],
      );

  TextStyle errStyleSymbol() => TextStyle(
        fontFamily: 'Holligate',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.red.shade700,
      );

  TextStyle myLabelStyle() => TextStyle(
        fontFamily: 'thaisanslite',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black54,
      );

  BoxDecoration boxDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white70,
      );

  BoxDecoration myBoxDrawer(String imgwall) {
    return BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/$imgwall'), fit: BoxFit.cover));
  }

  UserAccountsDrawerHeader builderAdminAccountsDrawerHeader(
      name, email, imgwall, logoimage) {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDrawer(imgwall),
      accountEmail: MyStyle().titleDrawer(email == null ? 'Email' : email),
      currentAccountPicture: CircleAvatar(
        //radius: (64),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(logoimage)),
      ),
      accountName: MyStyle().subtitleDrawer(name == null ? 'Name' : name),
    );
  }

  //**** version befor ****
  UserAccountsDrawerHeader builderUserAccountsDrawerHeader(
      name, email, imgwall, logoimage) {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDrawer(imgwall),
      accountEmail: MyStyle().titleDrawer(email == null ? 'Email' : email),
      accountName: MyStyle().subtitleDrawer(name == null ? 'Name' : name),
      //***** name คือ email  Email คือ  user  *****
      currentAccountPicture: CircleAvatar(
        //radius: (64),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: logoimage == ''
                ? Image.asset('userlogo.png')
                : Image.network(
                    '${MyConstant().domain}/${MyConstant().memberimagepath}/$logoimage',
                    fit: BoxFit.cover,
                  )),
      ),
    );
  }

  UserAccountsDrawerHeader homeAccountsDrawerHeader(name, email, imgwall) {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDrawer(imgwall),
      accountEmail: MyStyle().titleDrawer(''),
      accountName: MyStyle().subtitleDrawer(''),
    );
  }

  // void showInSnackBar(String value) {
  //   _scaffoldKey.currentState.showSnackBar(new SnackBar(
  //       content: new Text(value)
  //   ));
  // }

  MyStyle();
}
