import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/map_sample.dart';
import 'package:yakgin/model/mess_model.dart';
import 'package:yakgin/model/ord_model.dart';
import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/screen/shop/shop_food_category.dart';
import 'package:yakgin/screen/user_edit_info.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/signOut.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:yakgin/widget/shop/get_neworder.dart';
import 'package:yakgin/widget/shop/order_summary.dart';
import 'package:yakgin/widget/shop/shop_info.dart';
import 'package:yakgin/widget/shop/shop_order_list.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
//*** https://mui.com/components/material-icons/

class MainShop extends StatefulWidget {
  @override
  _MainShopState createState() => _MainShopState();
}

class _MainShopState extends State<MainShop> {
  bool loading = true;
  String _shopName;
  String mbid, loginName, loginMobile, ccode, mbimage = 'userlogo.png';
  Widget currentWidget = GetNewOrder(); //ShopFoodCategoryScreen();

  final MainStateController mainStateController = Get.find();

  //final orderStateController = Get.put(OrderStateController());  //count-order
  //OrderStateController ordController = new OrderStateController(); //count-order

  @override
  void initState() {
    super.initState();
    notification();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      ccode = prefer.getString('pccode');
      loginName = prefer.getString('pname');
      loginMobile = prefer.getString(MyConstant().keymoblie);
      mbid = prefer.getString(MyConstant().keymbid);
      findShop();
      getMemberPict();
    });
  }

  Future<Null> notification() async {
    try {
      if (Platform.isAndroid) {
        FirebaseMessaging firebaseMessaging = FirebaseMessaging();
        firebaseMessaging.configure(onLaunch: (message) async {
          //
        }, onResume: (message) async {
          //print('****************** FirebaseMessaging : onResume ${message.toString()}');
          String txtTitle = message['data']['title'];
          String txtBody = message['data']['body'];
          noticDialog(context, txtTitle, txtBody);
        }, onMessage: (message) async {
          //print('****************** FirebaseMessaging : onMessage ${message.toString()}');
          String txtTitle = message['notification']['title'];
          String txtBody = message['notification']['body'];
          noticDialog(context, txtTitle, txtBody);
        });
      } else if (Platform.isIOS) {
        //
      }
    } catch (ex) {
      //
    }
  }

  Future<Null> findShop() async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/checkShop.aspx?ccode=' +
            ccode;
    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null) {
          for (var map in result) {
            setState(() {
              ShopModel shopModel = ShopModel.fromJson(map);
              _shopName = shopModel.thainame;
              loading = false;
            });
          }
        } else {
          setState(() {
            loading = false;
          });
        }
      });
    } catch (ex) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<Null> getMemberPict() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getMbpict.aspx?mbid=$mbid';

    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null && result != '') {
        for (var map in result) {
          setState(() {
            MessModel mModel = MessModel.fromJson(map);
            mbimage = mModel.mess;
          });
        }
      }
    });
  }

  Future<Null> countOrderNo() async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/shop/countOrder.aspx?ccode=' +
            '$ccode&condition=[Status]=0';
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          OrdModel mModel = OrdModel.fromJson(map);
          setState(() {
            mainStateController.selectedRestaurant.value.restaurantId =
                mModel.restaurantId;
            mainStateController.selectedRestaurant.value.cntord =
                mModel.countord;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    countOrderNo();
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: MyStyle().primarycolor,
      //   title: MyStyle().txtTH('Wellcome $loginName', Colors.white),
      //   actions: <Widget>[
      //     Row(
      //       children: [
      //         Container(
      //           width: 80,
      //           child: //Obx(()=>
      //             Badge(
      //                 position: BadgePosition(top:8, end:15),
      //                 animationDuration: Duration(milliseconds: 200),
      //                 animationType: BadgeAnimationType.scale,
      //                 badgeColor: Colors.greenAccent[700],
      //                 badgeContent: Text('87',
      //                     style: TextStyle(
      //                     fontStyle: FontStyle.normal,
      //                     fontSize: 12,
      //                     fontWeight: FontWeight.normal,
      //                     color: Colors.white
      //                   ),
      //                 ),
      //                 child: Container(
      //                   margin: EdgeInsets.only(right:40.0),
      //                   child: IconButton(
      //                     icon: Icon(Icons.online_prediction_rounded, color: Colors.black,),
      //                     onPressed: () {
      //                       // if ( int.parse('87')>0){
      //                       //   MaterialPageRoute route = MaterialPageRoute(
      //                       //   builder: (context) => ShopOrderList(),);
      //                       //   Navigator.push(context, route);
      //                       // }else{
      //                       //   Toast.show('ไม่มีคำสั่งซื้อ\r\nร้าน${mainStateController.selectedRestaurant.value.thainame}', context,
      //                       //       gravity: Toast.CENTER,
      //                       //       backgroundColor: Colors.redAccent[700],
      //                       //       textColor: Colors.white);
      //                       // }
      //                     }
      //                   ),
      //                 ),
      //             ),
      //           //),
      //         ),
      //         IconButton(
      //             icon: Icon(Icons.exit_to_app),
      //             iconSize: 38,
      //             onPressed: () => signOut(context)
      //         ),
      //       ],
      //     )
      //   ],
      // ),
      appBar: AppBarWithOrderButton(
          title: (_shopName != null ? _shopName : ''),
          subtitle: '',
          ttlordno: '0'),
      /*
      appBar: AppBar(
        backgroundColor: MyStyle().primarycolor,
        title: MyStyle().txtTH((_shopName !=null ? 'Wellcome '+_shopName:''), Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 38,
            onPressed: () => signOut(context) //
          )
        ],
      ),
      */
      drawer: buildDrawer('Wellcome', loginName, 'shop.jpg'),
      body: (loading)
          ? MyStyle().showProgress()
          : (_shopName == null)
              ? dispApprove()
              : currentWidget,
    );
  }

  Column dispApprove() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: MyStyle().txtTH(
              'กรุณารอการอนุมัติ(1-2 วัน)\r\nผู้ดูแลระบบ กำลังดำเนินการอยู่ค่ะ\r\n' +
                  'เปิดหน้าจอนี้ไว้(พักหน้าจอ ใช้แอพพิเคชั่นอื่นได้\r\n' +
                  'จะมีการแจ้วเตือนให้ทราบเมื่อดำเนินการเสร็จค่ะ)',
              Colors.red),
        )
      ],
    );
  }

  Drawer buildDrawer(name, email, imgwall) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              Container(
                height: 180,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                child: shopDrawerHeader(name, email, imgwall, mbimage),
                //MyStyle().builderUserAccountsDrawerHeader(name,email,imgwall,mbimage),
              ),
              Container(height: 65, child: newOrderMenu()),
              Container(height: 65, child: orderListMenu()),
              Container(height: 65, child: orderSumMenu()),
              Container(height: 65, child: foodCatMenu()),
              Container(height: 65, child: shopInfoMenu()),
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

  UserAccountsDrawerHeader shopDrawerHeader(name, email, imgwall, logoimage) {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDrawer(imgwall),
      accountEmail: Row(
        children: [
          MyStyle().subtitleDrawer(name == null ? 'Name' : name),
          SizedBox(width: 3),
          MyStyle().titleDrawer(email == null ? 'Email' : email),
        ],
      ),
      accountName: Container(height: 1, child: Text('')),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
              onTap: () {
                setState(() {
                  currentWidget = UserEditInfo(
                      mbid: mbid,
                      loginname: loginName,
                      loginmobile: loginMobile,
                      pictname: mbimage);
                });
                Navigator.pop(context);
              },
              child: logoimage == ''
                  ? Image.asset('userlogo.png')
                  : Image.network(
                      'https://www.${MyConstant().domain}/${MyConstant().memberimagepath}/$logoimage',
                      fit: BoxFit.cover,
                    )),
        ),
      ),
    );
  }

  ListTile newOrderMenu() => ListTile(
        leading: Icon(Icons.fastfood),
        title: MyStyle().titleDark('คำสั่งซื้อใหม่'),
        subtitle: MyStyle().subtitleDark('ลูกค้าสั่งซื้อเข้ามาใหม่'),
        onTap: () {
          setState(() {
            currentWidget = GetNewOrder();
          });
          Navigator.pop(context);
        },
      );

  ListTile orderListMenu() => ListTile(
        leading: Icon(Icons.restaurant_menu),
        title: MyStyle().titleDark('รายการที่ลูกค้าสั่ง'),
        subtitle: MyStyle().subtitleDark('คำสั่งซื้อทั้งหมด'),
        onTap: () {
          setState(() {
            currentWidget = ShopOrderList();
          });
          Navigator.pop(context);
        },
      );

  ListTile orderSumMenu() => ListTile(
        leading: Icon(Icons.photo_filter_outlined), //developer_board
        title: MyStyle().titleDark('สรุปการซื้อรายวัน'),
        subtitle: MyStyle().subtitleDark('ที่ทำรายการจบแล้ว'),
        onTap: () {
          setState(() {
            currentWidget = OrderSummary();
          });
          Navigator.pop(context);
        },
      );
  //SwitchAccessShortcut RamenDining deck

  ListTile foodCatMenu() => ListTile(
        leading: Icon(
            Icons.auto_stories), //menu CircleNotifications FormatIndentIncrease
        title: MyStyle().titleDark('รายการอาหาร'),
        subtitle: MyStyle().subtitleDark('แสดงรายการอาหาร'),
        onTap: () {
          setState(() {
            currentWidget = ShopFoodCategoryScreen();
            //เปลี่ยนจาก ShopFoodMenu() เป็น FoodCategoryScreen();
          });
          Navigator.pop(context);
        },
      );

  ListTile shopInfoMenu() => ListTile(
        leading: Icon(Icons.info),
        title: MyStyle().titleDark('รายละเอียดของร้าน'),
        subtitle: MyStyle().subtitleDark('Detail of Shop.'),
        onTap: () {
          setState(() {
            currentWidget = ShopInfo();
          });
          Navigator.pop(context);
        },
      );

  ListTile testMap() {
    return ListTile(
      leading: Icon(
        Icons.login,
        size: 36,
      ),
      title: MyStyle().titleDark('ทดสอบแผนที่'),
      subtitle: MyStyle().subtitleDark('test google map.'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => MapSample());
        Navigator.push(context, route);
      },
    );
  }

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

  // ListTile signOutMenu() => ListTile(
  //       leading: Icon(Icons.exit_to_app),
  //       title: MyStyle().titleDark('ออกจากระบบ'),
  //       subtitle: MyStyle().subtitleDark('Back to home page.'),
  //       onTap: () => signOut(context),
  //     );
}
