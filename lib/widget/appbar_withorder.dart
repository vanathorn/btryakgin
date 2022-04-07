import 'package:badges/badges.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/screen/menu/main_shop_branch.dart';
import 'package:yakgin/screen/menu/main_shop_head.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class AppBarWithOrderButton extends StatelessWidget
  implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String ttlordno;
  final String brcode;
  //* final OrderStateController orderStateController = Get.find();
  final MainStateController mainStateController = Get.find();
  AppBarWithOrderButton({this.title, this.subtitle, this.ttlordno, this.brcode});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: subtitle != ''
          ? MyStyle().subTitleDrawerDark('$title $subtitle')
          // ListTile(
          //   title: MyStyle().titleTH (title, Colors.white),
          //   subtitle: MyStyle().titleDrawerDark(subtitle))
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
          badgeColor: Colors.greenAccent[700],
          badgeContent: Text(
            '${mainStateController.selectedRestaurant.value.cntord}',
            // '${orderStateController.getCountOrder0(
            //      mainStateController.selectedRestaurant.value.restaurantId
            // )}',
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
                  Icons.fastfood,
                  color: Colors.black,
                ), //icoms.couter_top
                onPressed: () {
                  if (int.parse(
                          '${mainStateController.selectedRestaurant.value.cntord}') >
                      0) {
                    //MaterialPageRoute route = MaterialPageRoute(builder: (context) => ShopOrderList(),);
                    //Navigator.pushAndRemoveUntil(context, route, (route) => false);
                    //
                    Widget currentWidget =
                        (brcode == '${MyConstant().keybrcode}')
                            ? MainShopHead()
                            : MainShopBranch();
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => currentWidget,
                    );
                    Navigator.push(context, route);
                  } else {
                    Toast.show(
                        'ไม่มีคำสั่งซื้อ\r\nร้าน ${mainStateController.selectedRestaurant.value.thainame}',
                        context,
                        gravity: Toast.CENTER,
                        backgroundColor: Colors.redAccent[700],
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
