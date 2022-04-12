import 'package:badges/badges.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/screen/custom/cart_screen.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AppBarWithCartButton extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final CartStateController cartStateController = Get.find();
  final MainStateController mainStateController = Get.find();

  AppBarWithCartButton({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //***** automaticallyImplyLeading: false,
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
        Obx(() => Badge(
              position: BadgePosition(top: 8, end: 15),
              animationDuration: Duration(milliseconds: 200),
              animationType: BadgeAnimationType.scale,
              badgeColor: Colors.red[900],
              badgeContent: Text(
                cartStateController
                    .getQuantity(mainStateController
                        .selectedRestaurant.value.restaurantId)
                    .toString(),
                style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
              child: Container(
                margin: EdgeInsets.only(right: 40.0),
                child: IconButton(
                    icon: Icon(
                      Icons.shopping_basket_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (cartStateController.getQuantity(mainStateController
                              .selectedRestaurant.value.restaurantId) >
                          0) {
                        MaterialPageRoute route = MaterialPageRoute(
                          builder: (context) => CartDetailScreen(),
                        );
                        Navigator.push(context, route);
                      } else {
                        //*** ตัวอย่าง *** ดึงค่าจาก async
                        //final loginName = findUser();
                        //loginName.then((e) =>
                        //$e
                        Toast.show(
                            'ไม่มีสินค้าในตะกร้า\r\nร้าน${mainStateController.selectedRestaurant.value.thainame}',
                            context,
                            gravity: Toast.CENTER,
                            backgroundColor: Colors.redAccent[700],
                            textColor: Colors.white);
                        //);
                        //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }),
              ),
            )),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(46.0);

  Future<String> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    return prefer.getString('pname');
  }
}
