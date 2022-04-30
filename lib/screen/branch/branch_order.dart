import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/model/item_model.dart';
import 'package:yakgin/model/login_model.dart';
import 'package:yakgin/model/sum_value.dart';
import 'package:yakgin/screen/menu/main_shop_branch.dart';
import 'package:yakgin/screen/menu/main_shop_head.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/dialig.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/view/cart_vm/cart_view_model_imp.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:yakgin/widget/infosnackbar.dart';

class BranchOrder extends StatefulWidget {
  final MainStateController mainStateController; // = Get.find();
  final CartStateController controller;
  final CartViewModelImp cartViewModel;
  final SumValue sumValue;
  final LoginModel loginModel;
  final String custName;
  final String custMobile;

  BranchOrder(this.mainStateController, this.controller, this.cartViewModel,
      this.sumValue, this.loginModel, this.custName, this.custMobile);
  @override
  _BranchOrderState createState() => _BranchOrderState();
}

class _BranchOrderState extends State<BranchOrder> {
  String restaurantid, mbid, ccode, loginName, loginMobile, brloc;
  double lat = 0.0, lng = 0.0, screen;
  SumValue sumValue;
  CartViewModelImp cartViewModel;
  String txtName, txtMobile;
  final String txtAddress = '', txthhmm = '', attachlocation = 'Y';
  String keyList = '';
  bool isWeb = false;
  bool enoughqty = true;

  Location location = Location();

  MainStateController mainStateController;
  CartStateController controller;
  List<CartModel> cartList = List<CartModel>.empty(growable: true);
  List<ItemModel> itemsList = List<ItemModel>.empty(growable: true);
  List<ItemModel> notenoughList = List<ItemModel>.empty(growable: true);
  LoginModel loginModel;

  @override
  void initState() {
    super.initState();
    mainStateController = widget.mainStateController;
    controller = widget.controller;
    cartViewModel = widget.cartViewModel;
    sumValue = widget.sumValue;
    txtName = widget.custName;
    txtMobile = widget.custMobile;
    restaurantid =
        '${mainStateController.selectedRestaurant.value.restaurantId}';
    loginModel = widget.loginModel;
    initData();
  }

  Future<Null> initData() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      ccode = prefer.getString('pccode');
      brloc = prefer.getString('pbrcode');
      loginName = prefer.getString('pname');
    });
  }

  Future<Null> remainItemList() async {
    String strKey = '', dilim = '';
    cartList.clear();
    cartList = controller
        .getCart(mainStateController.selectedRestaurant.value.restaurantId)
        .toList();

    for (int j = 0; j < cartList.length; j++) {
      strKey += dilim + cartList[j].id;
      dilim = ',';
    }
    keyList = strKey;
    //String ccode = '${mainStateController.selectedRestaurant.value.ccode}';
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'branch/item_remain_brloc.aspx?ccode=$ccode&brloc=$brloc&idlist=$keyList';

    itemsList.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ItemModel fModels = ItemModel.fromJson(map);
          itemsList.add(fModels);
        }
        setState(() {
          //loadding = false;
          //foodListStateController = Get.put(FoodListStateController());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: MyStyle().txtTH('ยืนยันการสั่งซื้อสินค้า', Colors.white),
        ),
        body: loginModel == null
            ? MyStyle().showProgress()
            : enoughqty
                ? getdataInfo()
                : dispnotEnough());
  }

  Widget dispnotEnough() => Column(children: [
        MyStyle().txtTH18Color('สินค้าไม่เพียงพอตามรายการด้านล่าง', Colors.red),
        Row(children: [
          Expanded(flex: 3, child: rowHead('รายการ')),
          Expanded(flex: 3, child: rowHead('คงเหลือ')),
          Expanded(flex: 1, child: rowHead('หน่วย')),
          Expanded(flex: 1, child: rowHead('')),
        ]),
        Divider(thickness: 1),
        notEnoughList(),
        Divider(thickness: 2),
        FloatingActionButton.extended(
          backgroundColor: Colors.red,
          label: Text('สั่งตามจำนวนคงเหลือ',
              style: TextStyle(
                  fontFamily: 'thaisanslite',
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.white)),
          icon: Icon(
            Icons.mark_chat_read,
            color: Colors.white,
          ),
          onPressed: () async {
            Navigator.pop(context);
            sendData();
          },
        ),
      ]);

  SingleChildScrollView notEnoughList() {
    return SingleChildScrollView(
        child: Column(children: [
      ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: notenoughList.length,
        itemBuilder: (context, index) =>
            //padding: const EdgeInsets.only(left:10, top:4, bottom: 4, right:8),
            Container(
          margin: const EdgeInsets.only(left: 10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Expanded(
                        flex: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MyStyle().txtstyle(notenoughList[index].iname,
                                Color.fromARGB(255, 39, 17, 17), 14)
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MyStyle().txtstyle(
                                notenoughList[index].currqty.toString(),
                                Color.fromARGB(255, 39, 17, 17),
                                14)
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MyStyle().txtstyle(notenoughList[index].uname,
                                Color.fromARGB(255, 39, 17, 17), 14)
                          ],
                        ))
                  ])
                ]),
          ),
        ),
      )
    ]));
  }

  SingleChildScrollView getdataInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [
          labelInfo(txtMobile, Icons.mobile_friendly),
          labelInfo(txtName, Icons.face_retouching_natural),
          saveButton()
        ],
      ),
    );
  }

  Widget rowHead(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack12TH(txt)],
      );

  Widget labelInfo(String strtxt, IconData iconData) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(top: 10),
              width: screen * 0.97,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: screen * 0.2,
                    child: Icon(
                      iconData,
                      color: MyStyle().logocolor,
                      size: 32,
                    ),
                  ),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 0),
                          child:
                              MyStyle().txtstyle(strtxt, Colors.black, 18.0)))
                ],
              ))
        ],
      );

  String dtoSFixed2(double val) {
    return val != null ? val.toStringAsFixed(2) : '0';
  }

  Future<Null> validate() async {
    notenoughList.clear();
    //var myFmt = NumberFormat('##0.##', 'en_US');
    //String mess = '', dilim = '';
    for (int j = 0; j < cartList.length; j++) {
      int qty = cartList[j].quantity;
      int qtySp = cartList[j].quantitySp;
      int ttlqty = qty + qtySp;
      if (ttlqty > 0) {
        for (int k = 0; k < itemsList.length; k++) {
          if (itemsList[k].iid.toString() == cartList[j].id) {
            if (ttlqty > itemsList[k].currqty) {
              notenoughList.add(itemsList[k]);
              cartList[j].balqty =
                  double.parse(itemsList[k].currqty.toString());
              setState(() {
                cartViewModel.updateQuantity(
                    controller,
                    mainStateController.selectedRestaurant.value.restaurantId,
                    j,
                    itemsList[k].currqty);
              });
            }
            break;
          }
        }
      }
    }
    for (int index = cartList.length - 1; index > -1; index--) {
      if (cartList[index].balqty == 0) {
        setState(() {
          //cartList.removeAt(index);
          cartViewModel.deleteCart(
              controller,
              mainStateController.selectedRestaurant.value.restaurantId,
              controller
                  .getCart(
                      mainStateController.selectedRestaurant.value.restaurantId)
                  .toList()[index],
              cartList[index].id);
        });
      }
    }
  }

  Future<Null> sendData() async {
    String resturantid =
        mainStateController.selectedRestaurant.value.restaurantId;
    String ttlDiscount = '0.0', ttlFree = '0.0';
    final double distiance = sumValue.distiance;
    final double ttlAmount = controller.sumCart(resturantid);
    DateTime now = DateTime.now();
    String createdDT = DateFormat('MM-dd-yyyy HH:mm:ss.ms').format(now);
    //'11-23-2021 08:44:00.000'

    lat = double.parse(mainStateController.selectedRestaurant.value.lat);
    lng = double.parse(mainStateController.selectedRestaurant.value.lng);

    String ordhead = '$resturantid*$mbid*$txtName*$txtAddress*$txtMobile*' +
        '$txthhmm*' +
        dtoSFixed2(distiance) +
        '*$lat*$lng*' +
        dtoSFixed2(ttlAmount) +
        '*$ttlDiscount*$ttlFree*$loginName*$createdDT';

    int qty = 0;
    int qtySp = 0;
    String strKey = '', delimiter = '';
    String orddetail = '';
    for (int j = 0; j < cartList.length; j++) {
      strKey = cartList[j].strKey;
      qty = cartList[j].quantity;
      qtySp = cartList[j].quantitySp;
      if (qty > 0) {
        orddetail += delimiter +
            strKey +
            '_' +
            qty.toString() +
            '_' +
            cartList[j].price.toString() +
            '_N';
        delimiter = '*';
      }
      if (qtySp > 0) {
        orddetail += delimiter +
            strKey +
            '_' +
            qtySp.toString() +
            '_' +
            cartList[j].priceSp.toString() +
            '_Y';
        delimiter = '*';
      }
    }

    //String ccode = '${mainStateController.selectedRestaurant.value.ccode}';
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'branch/brInsertOrder.aspx?ccode=$ccode&brloc=$brloc&ordhead=$ordhead&orddetail=$orddetail';
    try {
      Response response = await Dio().get(url);
      if (response.toString() == '') {
        //*----- clear cart ----*/
        cartViewModel.clearCart(
            controller,
            mainStateController.selectedRestaurant.value.restaurantId,
            controller
                .getCart(
                    mainStateController.selectedRestaurant.value.restaurantId)
                .toList());

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            InfoSnackBar.infoSnackBar(
                'บันทึกข้อมูลเรียบร้อย', Icons.sentiment_satisfied_alt),
          );

        Widget menuShopWidget = (brloc == '${MyConstant().headBranch}') 
            ? MainShopHead() : MainShopBranch();        
        MaterialPageRoute route =
            MaterialPageRoute(builder: (context) => menuShopWidget);
        Navigator.pushAndRemoveUntil(context, route, (route) => false);

      } else {
        alertDialog(context, response.toString());
      }
    } catch (e) {
      alertDialog(context, '!ทำคำสั่งซื้อไม่สำเร็จ');
    }
  }

  Widget saveButton() => Container(
      margin: const EdgeInsets.only(top: 8, bottom: 3),
      width: screen * 0.95,
      height: 50.0,
      child: ElevatedButton.icon(
        onPressed: () async {
          if ((txtName?.isEmpty ?? true) || (txtMobile?.isEmpty ?? true)) {
            alertDialog(context, 'ระบุข้อมูล ชื่อ สถานที่ เบอร์ติดต่อ ');
          } else {
            if (txtMobile.length < 10) {
              alertDialog(context, '!เบอร์ไม่ถูกต้อง (' + txtMobile + ')');
            } else {
              await remainItemList();
              await validate();
              if (notenoughList.length > 0) {
                setState(() {
                  enoughqty = false;
                });
              } else {
                sendData();
              }
            }
          }
        },
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: MyStyle().txtTH('ยืนยันการสั่งซื้อ', Colors.white),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return Colors.green; // Use the component's default.
            },
          ),
        ),
      ));

  /* account bank
  Container buildAccBank() {
    return Container(
      margin: const EdgeInsets.only(top:5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        elevation: 5,
        child: Container(         
            padding: EdgeInsets.all(0.0),
            width: screen*0.95,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(() => ExpansionTile(
                  title: MyStyle().txtstyle(accbank_WORD, Colors.redAccent[700], 14.0),
                  children: [                 
                    Column(
                      children: 
                      listStateController.selectedAccount.value.account.map((e) => 
                        Padding(
                          padding: const EdgeInsets.only(left:10, bottom: 8.0),
                          child: 
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.account_box, color: Colors.black),
                                    SizedBox(width: 5),
                                    Container(
                                      width:screen*0.3,
                                      child: MyStyle().txtstyle('${e.accno}', Colors.red, 14.0)
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left:5.0),
                                      child: MyStyle().txtstyle('${e.bkname}', Colors.black, 13.0)
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30.0),
                                      child: MyStyle().txtstyle('${e.accname}', Colors.black, 13.0),
                                    )
                                  ],
                                )
                              ],
                            ),                                                
                        )).toList(),
                    )                   
                  ],
                ),)
              ],
            )),
      ));
  }
  */

}
