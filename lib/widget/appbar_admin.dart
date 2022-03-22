import 'package:badges/badges.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/screen/menu/main_admin.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class AppBarAdminButton extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String ttlnewmember;

  final MainStateController mainStateController = Get.find();

  AppBarAdminButton({this.title, this.subtitle, this.ttlnewmember});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: subtitle != ''
          ? ListTile(
              title: MyStyle().txtstyle(title, Colors.white, 14.0),
              subtitle: MyStyle().titleDrawerDark(subtitle))
          : MyStyle().subTitleDrawerLight(title),

      //elevation: 10,
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),

      actions: [
        //Obx(()=>
        Badge(
          position: BadgePosition(top: 8, end: 20),
          animationDuration: Duration(milliseconds: 200),
          animationType: BadgeAnimationType.scale,
          badgeColor: Colors.limeAccent,
          badgeContent: Text(
            '${mainStateController.selectedRestaurant.value.cntnewm}',
            style: GoogleFonts.lato(
                fontStyle: FontStyle.normal,
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.black),
          ),
          child: Container(
            margin: EdgeInsets.only(right: 50.0),
            child: IconButton(
                icon: Icon(
                  Icons.person_pin,
                  color: Colors.black,
                ), //icoms.couter_top
                onPressed: () {
                  if (int.parse(
                          '${mainStateController.selectedRestaurant.value.cntnewm}') >
                      0) {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => MainAdmin(),
                    );
                    Navigator.push(context, route);
                  } else {
                    Toast.show('ไม่มีผู้สมัครใหม่', context,
                        gravity: Toast.CENTER,
                        backgroundColor: Colors.indigoAccent[700],
                        textColor: Colors.white);
                  }
                }),
          ),
        ),
        //),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(46.0);
}
