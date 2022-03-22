import 'package:flutter/material.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Null> alertDialog(BuildContext context, String subtitle) async {
  showDialog(
      context: context,
      builder: (context) => SimpleDialog(
              title: ListTile(
                  leading: Image.asset(
                    'images/exclaim.png',
                    height: 32,
                    width: 32,
                  ),
                  title: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        '! ข้อผิดพลาด',
                        style: MyStyle().errStyle(),
                      )),
                  subtitle: MyStyle().subtitleDark('')),
              children: [
                SingleChildScrollView(
                  child: Column(
                      children: [Center(child: MyStyle().txtTHRed(subtitle))]),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Ok',
                    style: GoogleFonts.kanit(
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff000000),
                    ),
                  ),
                )
              ]));
}

Future<Null> noticDialog(
    BuildContext context, String txttitle, String txtbody) async {
  showDialog(
      context: context,
      builder: (context) => SimpleDialog(
              title: ListTile(
                  leading: Image.asset(
                    'images/info.png',
                    height: 32,
                    width: 32,
                  ),
                  title: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 10),
                      child: MyStyle()
                          .txtstyle('$txttitle', Colors.redAccent[700], 12)),
                  subtitle: MyStyle().txtstyle('', Colors.green[900], 12)),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MyStyle().txtblack16TH('$txtbody'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                        width: (MediaQuery.of(context).size.width) * 0.28,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: MyStyle().titleCenter(
                            context, 'รับรู้', 16.0, Colors.white))),
              ]));
}
