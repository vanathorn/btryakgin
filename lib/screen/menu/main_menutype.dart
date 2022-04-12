import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'package:yakgin/screen/custom/cart_screen.dart';
import 'package:yakgin/screen/custom/cart_shop_list.dart';
import 'package:yakgin/screen/custom/user_select_shoptype.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/signOut.dart';

class MainMenuType extends StatefulWidget {
  @override
  _MainMenuTypeState createState() => _MainMenuTypeState();
}

class _MainMenuTypeState extends State<MainMenuType> {
  String strConn, loginName, webPath;
  Widget currentWidget = UserSelectShoptype();

  final CartStateController cartStateController = Get.find();
  final MainStateController mainStateController = Get.find();
  ZoomDrawerController zoomDrawerController;

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      webPath = prefer.getString('pwebpath');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().primarycolor,
        title: MyStyle().txtTH('Wellcome $loginName', Colors.white),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              iconSize: 38,
              onPressed: () => signOut(context))
        ],
      ),
      drawer: buildDrawer('Wellcome', loginName, 'user.jpg'),
      body: currentWidget,
    );
  }

  Drawer buildDrawer(name, email, imgwall) {
    return Drawer(
      child: Stack(
        //ListView
        children: <Widget>[
          Column(
            children: [
              MyStyle().builderUserAccountsDrawerHeader(
                name,
                email,
                imgwall,
                'images/userlogo.png',
              ),
              userSelectShoptypeMenu(),
              //MenuScreen(zoomDrawerController),
              userBasketMenu(),
              userOrderMenu(),
            ],
          ),
          Column(
            //ต้องเปลี่ยนจาก ListView -> Stack ถึงจะ work
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              //Divider(thickness: 1, color: Colors.black12),
              signOutMenu(),
              SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }

  ListTile userSelectShoptypeMenu() => ListTile(
        leading: Icon(Icons.fastfood),
        title: MyStyle().titleDark('ร้านค้า'),
        subtitle: MyStyle().subtitleDark('ร้านค้าที่อยู่ในโครงการ'),
        onTap: () {
          setState(() {
            currentWidget = UserSelectShoptype(); //UserResturantMenu();
          });
          Navigator.pop(context);
        },
      );

  ListTile userBasketMenu() => ListTile(
        leading: Icon(Icons.add_shopping_cart),
        title: MyStyle().titleDark('ตระกร้าสินค้าของคุณ'),
        subtitle:
            MyStyle().subtitleDark('รายการเลือกซื้อสินค้าของคุณที่รอยืนยัน'),
        onTap: () {
          if (cartStateController.getCartShop().toList().length > 0) {
            setState(() {
              currentWidget = CartShopListScreen(); //CartDetailScreen();
            });
            Navigator.pop(context);
          } else {
            Toast.show(
              'ไม่มีสินค้าในตะกร้าของคุณ $loginName',
              context,
              gravity: Toast.CENTER,
              backgroundColor: Colors.redAccent[700],
              textColor: Colors.white,
            );
          }
        },
      );

  ListTile userOrderMenu() => ListTile(
        leading: Icon(Icons.shopping_basket),
        title: MyStyle().titleDark('การซื้อของคุณ'),
        subtitle: MyStyle().subtitleDark('รายการที่คุณสั่งซื้อแล้ว'),
        onTap: () {
          setState(() {
            currentWidget = CartDetailScreen();
          });
          //Navigator.pop(context);
          /*****
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => CartDetailScreen()
          );
          Navigator.push(context, route);
          *******/
        },
      );

  Widget signOutMenu() {
    return Container(
      decoration: BoxDecoration(color: MyStyle().bgsignout),
      child: ListTile(
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        title: MyStyle().titleLight('ออกจากระบบ'),
        subtitle: MyStyle().subtitleLight('Back to home page.'),
        onTap: () => signOut(context),
      ),
    );
  }
}
