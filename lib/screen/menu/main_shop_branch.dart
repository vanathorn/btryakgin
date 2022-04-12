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
import 'package:yakgin/screen/shop/shop_recive_item.dart';
import 'package:yakgin/screen/shop/shop_select_branch.dart';
import 'package:yakgin/screen/user_edit_info.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/signOut.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:yakgin/widget/branch/branch_order_list.dart';
import 'package:yakgin/widget/branch/branch_order_ship.dart';
import 'package:yakgin/widget/branch/new_ord_branch.dart';
import 'package:yakgin/widget/shop/order_summary.dart';
import 'package:yakgin/widget/shop/shop_info.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
//*** https://mui.com/components/material-icons/

class MainShopBranch extends StatefulWidget {
  @override
  _MainShopBranchState createState() => _MainShopBranchState();
}

class _MainShopBranchState extends State<MainShopBranch> {
  bool loading = true;
  String _shopName, brcode, brname;
  String mbid, loginName, loginMobile, ccode, mbimage = 'userlogo.png';
  Widget currentWidget = GetNewOrderBranch();

  final MainStateController mainStateController = Get.find();
  double hi = 45;

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
      brcode = prefer.getString(MyConstant().keybrcode);
      brname = prefer.getString('pbrname');
      loginMobile = prefer.getString(MyConstant().keymoblie);
      mbid = prefer.getString(MyConstant().keymbid);
      hi = (brcode == MyConstant().headBranch) ? 45 : 55;
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
        '${MyConstant().apipath}.${MyConstant().domain}/branch/countNewOrdBr.aspx?mbid=$mbid&condition=';

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
      appBar: AppBarWithOrderButton(
        title: (loginName != null) ? loginName : '',
        subtitle: (brname != null)
            ? brname
            : '', //+ (brcode !='' ? ' ('+brcode+')' :'') : ''),
        ttlordno: '0', brcode: brcode,
      ),
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
                height: 175,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                child: shopDrawerHeader(name, email, imgwall, mbimage),
                //MyStyle().builderUserAccountsDrawerHeader(name,email,imgwall,mbimage),
              ),
              Container(height: hi, child: newOrderBranchMenu()),
              Container(height: hi, child: orderBranchListMenu()),
              //Container(height: hi, child: shipOrdBrListMenu()),
              Container(height: hi, child: orderSumMenu()),
              Container(height: hi, child: foodCatMenu()),
              Container(height: hi, child: shopInfoMenu()),
              Container(height: hi, child: reciveItemMenu()),
              // (brcode == MyConstant().headBranch)
              //     ? Container(height: hi, child: balItemMenu())
              //     : Container(),
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
                      //width: 30,
                      //height: 30
                    )),
        ),
      ),
    );
  }

  ListTile newOrderBranchMenu() => ListTile(
        leading: Icon(Icons.fastfood),
        title: MyStyle().titleDark('คำสั่งซื้อใหม่'),
        subtitle: MyStyle().subtitleDark('ลูกค้าสั่งซื้อเข้ามาใหม่' +
            (brname != null ? ' (' + brname + ')' : '')),
        onTap: () {
          setState(() {
            currentWidget = GetNewOrderBranch();
          });
          Navigator.pop(context);
        },
      );

  ListTile orderBranchListMenu() => ListTile(
        leading: Icon(Icons.shopping_basket),
        title: MyStyle().titleDark('รายการที่ลูกค้าสั่ง'),
        subtitle: MyStyle().subtitleDark(
            'คำสั่งซื้อทั้งหมด' + (brname != null ? ' (' + brname + ')' : '')),
        onTap: () {
          setState(() {
            currentWidget = BranchOrderList();
          });
          Navigator.pop(context);
        },
      );

  ListTile shipOrdBrListMenu() => ListTile(
        leading: Icon(Icons.shopping_basket),
        title: MyStyle().titleDark('ส่งสินค้าให้ลูกค้า'),
        subtitle: MyStyle().subtitleDark(
            'สินค้าที่แพคแล้ว' + (brname != null ? ' (' + brname + ')' : '')),
        onTap: () {
          setState(() {
            currentWidget = BranchOrderShip();
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
        title: MyStyle().titleDark('รายการสินค้า'),
        subtitle: MyStyle().subtitleDark('แสดงรายการสินค้า'),
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

  ListTile reciveItemMenu() => ListTile(
        leading: Icon(Icons.add_shopping_cart),
        title: MyStyle().titleDark('รับสินค้า'),
        subtitle: MyStyle().subtitleDark('รับสินค้าเข้าร้านสาขา'),
        onTap: () {
          setState(() {
            currentWidget = ShopReciveItem();
          });
          Navigator.pop(context);
        },
      );

  ListTile balItemMenu() => ListTile(
        leading: Icon(Icons.auto_stories),
        title: MyStyle().titleDark('ปรับยอดสินค้า'),
        subtitle: MyStyle().subtitleDark('ปรับยอดสินค้าคงเหลือ'),
        onTap: () {
          setState(() {
            currentWidget = ShopSelectBranch();
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
}
