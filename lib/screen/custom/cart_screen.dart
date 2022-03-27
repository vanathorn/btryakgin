import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_elegant_number_button/flutter_elegant_number_button.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yakgin/model/account_model.dart';
import 'package:yakgin/model/login_model.dart';
import 'package:yakgin/model/send_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/model/sum_value.dart';
import 'package:yakgin/screen/custom/send_order.dart';
import 'package:yakgin/screen/custom/user_select_shoptype.dart';
import 'package:yakgin/screen/menu/main_user.dart';
import 'package:yakgin/state/accbk_detail_state.dart';
import 'package:yakgin/state/accbk_list_state.dart';
import 'package:get/get.dart';
//*--  err-firebase import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/view/cart_vm/cart_view_model_imp.dart';
import 'package:yakgin/widget/cart/cart_image_widget.dart';
import 'package:yakgin/widget/cart/cart_total_widget.dart';

class CartDetailScreen extends StatefulWidget {
  @override
  _CartDetailScreenState createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends State<CartDetailScreen> {
  /*--  err-firebase final box = GetStorage(); */
  final CartStateController controller = Get.find();
  final CartViewModelImp cartViewModel = new CartViewModelImp();
  final MainStateController mainStateController = Get.find();

  String loginName = '', loginMobile = '';
  double screen, screenH;
  String strPrice;

  String restLat, restLng;
  double lat1, lng1, latShop, lngShop, distance;
  String strDistance;
  Location location = Location();
  final int startLogist = 30;
  final double iwidth = 100;
  final double iEle = 20;
  int logistCost;
  String strKeyVal = '', nameBVal = '', nameCVal = '', straddonVal = '';

  LoginModel loginModel = new LoginModel();

  SumValue sumValue = new SumValue();
  /* account bank */
  var isExpanAcc = false;
  ShopRestModel shopModel = new ShopRestModel();
  AccbkListStateController listStateController;
  List<AccountModel> listAccbks = List<AccountModel>.empty(growable: true);
  AccbkDetailStateController foodController =
      Get.put(AccbkDetailStateController());
  //

  Widget currentWidget = UserSelectShoptype();
  String mbimage = 'userlogo.png';
  //----------------------------------------------
  _onExpanAccChanged(bool val) {
    setState(() {
      isExpanAcc = val;
    });
  }

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      loginMobile = prefer.getString('pmobile');
      findLatLngofShop();
      findAccountShop();
      getExistSend();
    });
  }

  Future<Null> getExistSend() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getSendLocation.aspx?mobile=$loginMobile';

    await Dio().get(url).then((value) {
      if (value != null && value.toString() != '') {
        var result = json.decode(value.data);
        for (var map in result) {
          setState(() {
            SendModel sModel = SendModel.fromJson(map);
            loginModel.mbname = sModel.name;
            loginModel.mobile = sModel.mobile;
            loginModel.sendaddr = sModel.address;
            //lat = getlat;
            //lng = getlng;
            /*       
            if ((sendModel.lat?.isEmpty ?? true) || (sendModel.lng?.isEmpty ?? true)
                || sendModel.lat=='0' || sendModel.lng=='0'){
              lat = getlat;
              lng = getlng;
              print('***********  A  getlat/getlng = $getlat / $getlng');
            }else{
                lat = double.parse(sendModel.lat);
                lat = double.parse(sendModel.lng);
                print('***********  B');
            }*/
          });
        }
      } else {
        setState(() {
          loginModel.mbname = loginName;
          loginModel.sendaddr = '';
          loginModel.mobile = loginMobile;
        });
      }
    });
  }

  /* account bank */
  Future<Null> findAccountShop() async {
    String restaurantid =
        mainStateController.selectedRestaurant.value.restaurantId;
    String ccode = mainStateController.selectedRestaurant.value.ccode;
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getShopBank.aspx?ccode=' +
        ccode;
    listAccbks.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          AccountModel aModels = AccountModel.fromJson(map);
          listAccbks.add(AccountModel(ccode, aModels.bkid, aModels.bkcode,
              aModels.bkname, aModels.accno, aModels.accname));
        }
        setState(() {
          shopModel.restaurantId = restaurantid;
          shopModel.ccode = ccode;
          shopModel.account = listAccbks.toList();
        });
      }
    });
  }

  Future<Null> findLatLngofShop() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'getShopByType.aspx?ccode=${mainStateController.selectedRestaurant.value.ccode}';

    await Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          ShopModel fModels = ShopModel.fromJson(map);
          restLat = fModels.lat;
          restLng = fModels.lng;
        }
        findLogistCost(restLat, restLng);
      }
    });
  }

  Future<Null> findLogistCost(String restLat, String restLng) async {
    LocationData locationData = await MyCalculate().findLocationData();
    lat1 = locationData.latitude;
    lng1 = locationData.longitude;
    latShop = double.parse(restLat);
    lngShop = double.parse(restLng);
    distance = MyCalculate().calculateDistance(lat1, lng1, latShop, lngShop);
    var myFmt = NumberFormat('##0.0#', 'en_US');
    strDistance = myFmt.format(distance) + ' กม.';
    setState(() {
      logistCost = MyCalculate().calculateLogistic(distance, startLogist);
      sumValue.distiance = distance;
      sumValue.ttlLogist = double.parse(logistCost.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    findLatLngofShop();
    screen = MediaQuery.of(context).size.width;
    screenH = 42;
    listStateController = Get.find();
    listStateController.selectedAccount.value = shopModel;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: MyStyle().headcolor,
          title: Row(
            children: [
              Container(
                height: 38.0,
                width: 38,
                child: FloatingActionButton(
                  backgroundColor: MyStyle().primarycolor,
                  onPressed: () {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => MainUser(),
                    );
                    Navigator.pushAndRemoveUntil(context, route, (route) => false);
                    //MaterialPageRoute route = MaterialPageRoute(builder: (context) => MainUser());
                    //Navigator.push(context, route);
                  },
                  child: Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
              Container(
                width: screen * 0.66,
                child: ListTile(
                    title: Center(
                      child: MyStyle().txtstyle(
                          'ร้าน${mainStateController.selectedRestaurant.value.thainame}',
                          Colors.white,
                          12.0),
                    ),
                    subtitle: Center(
                        child: MyStyle().txtstyle(
                            'เลื่อนขวาไปซ้ายเพื่อลบรายการ',
                            Colors.black,
                            10.0))),
              ),
              controller.getQuantity(mainStateController
                          .selectedRestaurant.value.restaurantId)>0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 38.0,
                          width: 38,
                          child: FloatingActionButton(
                            backgroundColor: Colors.deepOrangeAccent[400],
                            onPressed: () {
                              confirmDelete(controller);
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 32.0,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
          )
          /*
        actions: [
         controller.getQuantity(mainStateController.selectedRestaurant.value.restaurantId) > 0 
          IconButton(onPressed: () {
            confirmDelete(controller);
          }, icon: Icon(Icons.clear),) 
         : Container()         
        ],
        iconTheme: IconThemeData(color: Colors.black)
        */
          ),
      body: controller
                  .getCart(
                      mainStateController.selectedRestaurant.value.restaurantId)
                  .toList()
                  .length >
              0
          ? Obx(() => Column(
                children: [
                  (listAccbks.length > 0) ? buildAccBank() : Container(),
                  Expanded(
                      child: ListView.builder(
                          itemCount: controller
                              .getCart(mainStateController
                                  .selectedRestaurant.value.restaurantId)
                              .toList()
                              .length, //controller.cart.length,
                          itemBuilder: (context, index) => Slidable(
                                child: Card(
                                  elevation: 10.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 3.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(children: [
                                                Text(
                                                    MyUtil().getItemName(controller
                                                        .getCart(
                                                            mainStateController
                                                                .selectedRestaurant
                                                                .value
                                                                .restaurantId)
                                                        .toList()[index]),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'thaisanslite',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black,
                                                      //maxLines: 2, overflow: TextOverflow.ellipsis,
                                                    )),
                                                MyUtil().getOption(controller
                                                            .getCart(mainStateController
                                                                .selectedRestaurant
                                                                .value
                                                                .restaurantId)
                                                            .toList()[index]) !=
                                                        ''
                                                    ? Text(
                                                        MyUtil().getOption(controller
                                                            .getCart(mainStateController
                                                                .selectedRestaurant
                                                                .value
                                                                .restaurantId)
                                                            .toList()[index]),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'thaisanslite',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors
                                                              .blueAccent[700],
                                                        ))
                                                    : Container()
                                              ]),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: CartImageWidget(
                                                cartModel: controller
                                                    .getCart(mainStateController
                                                        .selectedRestaurant
                                                        .value
                                                        .restaurantId)
                                                    .toList()[index],
                                              ),
                                            ),
                                            Expanded(
                                              flex:
                                                  7, //** ยิ่งตัวเลขมาก รูปยิ่งเล็กลง
                                              child: Column(
                                                children: [
                                                  //normal price
                                                  buildElegant(index),
                                                  //special price
                                                  controller
                                                              .getCart(
                                                                mainStateController
                                                                    .selectedRestaurant
                                                                    .value
                                                                    .restaurantId,
                                                              )
                                                              .toList()[index]
                                                              .flagSp ==
                                                          'Y'
                                                      ? buildSpElegant(index)
                                                      : Container(
                                                          child: SizedBox(
                                                              height: 10),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          child: (controller
                                                      .getCart(
                                                        mainStateController
                                                            .selectedRestaurant
                                                            .value
                                                            .restaurantId,
                                                      )
                                                      .toList()[index]
                                                      .priceSp >
                                                  0
                                              ? Container()
                                              : SizedBox(height: 8))),
                                    ],
                                  ),
                                ),
                                actionPane: SlidableDrawerActionPane(),
                                
                                actionExtentRatio: 0.2,
                                secondaryActions: [
                                  IconSlideAction(
                                      caption: 'ลบทิ้ง',
                                      icon: Icons.delete,
                                      color: Colors.red,
                                      onTap: () {
                                        CartModel cModel = controller
                                            .getCart(mainStateController
                                                .selectedRestaurant
                                                .value
                                                .restaurantId)
                                            .toList()[index];
                                        strKeyVal = '${cModel.id}';

                                        cartViewModel.deleteCart(
                                            controller,

                                            mainStateController
                                                .selectedRestaurant
                                                .value
                                                .restaurantId,

                                            controller
                                                .getCart(mainStateController
                                                    .selectedRestaurant
                                                    .value
                                                    .restaurantId)
                                                .toList()[index],

                                            strKeyVal
                                        );
                                        setState(() {});
                                      })
                                ],
                                
                              ))),
                  CartTotalWidget(
                      controller: controller,
                      distance: (strDistance != null ? strDistance : ''),
                      logistCost: '$logistCost'),
                  (kIsWeb)
                      ? nextButton()
                      : (distance != null && distance != 0)
                          ? nextButton()
                          : Container(
                              height: 48, child: MyStyle().showProgress())
                ],
              ))
          : Center(
              child: MyStyle().titleCenterTH(
                  context,
                  'ไม่มีสินค้าในตะกร้า ' +
                      'ร้าน${mainStateController.selectedRestaurant.value.thainame}',
                  18,
                  Colors.red),
            ),
    );
  }

  Row buildElegant(int index) {
    return Row(
      children: [
        Container(
          width: iEle,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 3),
            child: MyStyle().txtstyle('', Colors.black, 10),
          ),
        ),
        Container(
          width: iwidth,
          child: controller
                      .getCart(mainStateController
                          .selectedRestaurant.value.restaurantId)
                      .toList()[index]
                      .quantity >
                  0
              ? normalAmount(controller
                  .getCart(
                    mainStateController.selectedRestaurant.value.restaurantId,
                  )
                  .toList()[index])
              : Container(),
        ),
        normalElegant(
            controller
                .getCart(
                    mainStateController.selectedRestaurant.value.restaurantId)
                .toList()[index],
            index)
      ],
    );
  }

  Row buildSpElegant(int index) {
    return Row(
      children: [
        Container(
          width: iEle,
          child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Icon(
                Icons.monetization_on,
                color: Colors.redAccent[700],
              )),
        ),
        Container(
          width: iwidth,
          child: specialAmount(controller
              .getCart(
                  mainStateController.selectedRestaurant.value.restaurantId)
              .toList()[index]),
        ),
        specialElegant(
            controller
                .getCart(
                    mainStateController.selectedRestaurant.value.restaurantId)
                .toList()[index],
            index)
      ],
    );
  }

  Container normalAmount(CartModel cartModel) {
    return Container(
      child: Row(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(
                '${cartModel.quantity}*${MyCalculate().fmtNumber(cartModel.price)}', //${MyCalculate().currencyFormat.format(controll.cart[index].spprice)}
                style: TextStyle(color: Colors.black, fontSize: 12)),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  '=${MyCalculate().fmtNumberBath(cartModel.quantity * cartModel.price)}',
                  style: TextStyle(color: Colors.black, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Row normalElegant(CartModel cartModelCtl, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElegantNumberButton(
          initialValue: cartModelCtl.quantity,
          minValue: 0,
          maxValue: cartModelCtl.balqty,
          onChanged: (value) {
            cartViewModel.updateQuantity(
                controller,
                mainStateController.selectedRestaurant.value.restaurantId,
                index,
                value.toInt());
            setState(() {});
          },
          decimalPlaces: 0,
          step: 1,
          color: Colors.black12,
          buttonSizeWidth: 40,
          buttonSizeHeight: 40,
          textStyle: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Container specialAmount(CartModel cartModel) {
    return Container(
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(
              '${cartModel.quantitySp}*${MyCalculate().fmtNumber(cartModel.priceSp)}', //${MyCalculate().currencyFormat.format(controll.cart[index].spprice)}
              style: TextStyle(color: Colors.redAccent[700], fontSize: 12),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Text(
                  '=${MyCalculate().fmtNumberBath(cartModel.quantitySp * cartModel.priceSp)}',
                  style: TextStyle(color: Colors.redAccent[700], fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Row specialElegant(CartModel cartModelCtl, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElegantNumberButton(
          initialValue: cartModelCtl.quantitySp,
          minValue: 0,
          maxValue: cartModelCtl.balqty,
          onChanged: (value) {
            cartViewModel.updateQuantitySp(
                controller,
                mainStateController.selectedRestaurant.value.restaurantId,
                index,
                value.toInt());
            setState(() {});
          },
          decimalPlaces: 0,
          step: 1,
          color: Colors.amberAccent[700],
          buttonSizeWidth: 40,
          buttonSizeHeight: 40,
          textStyle: TextStyle(
              fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Row specialPrice(CartModel cartModelCtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: MyStyle().txtTH18Color('พิเศษ', Colors.red[800]),
        ),
        //showPriceCrycle('${foodModel.price}', Colors.black, Colors.white),
        SizedBox(
          width: 10.0,
        ),
        Obx(() => ElegantNumberButton(
              initialValue: cartModelCtl.quantity,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) {
                cartModelCtl.quantity = value.toInt();
                controller.cart.refresh();
              },
              decimalPlaces: 0,
              step: 1,
              color: Colors.amberAccent[400],
              buttonSizeWidth: 48,
              buttonSizeHeight: 48,
              textStyle: TextStyle(
                  fontSize: 18.0,
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold),
            )),
      ],
    );
  }

  /*
  Card totalCart(CartStateController controller, String logistCost){
    double shippingFree = (logistCost !='') ? double.parse(logistCost) : 0;
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TotalItemWidget(
                controller: controller,
                text: 'มูลค่าสินค้า',
                value: controller.sumCart(mainStateController.selectedRestaurant.value.restaurantId),
                isSubTotal: false),
            Divider(thickness: 1),
            TotalItemWidget(
                controller: controller,
                text: 'ค่าขนส่ง',
                value: shippingFree,
                isSubTotal: false),
            Divider(thickness: 1),
            TotalItemWidget(
                controller: controller,
                text: 'ยอดรวม',
                value: (controller.sumCart(mainStateController.selectedRestaurant.value.restaurantId) + shippingFree),
                isSubTotal: true)
          ],
        ),
      ),
    );
  }
  */
  Future<Null> deleteCart(CartStateController controller, int index) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle().txtstyle('คุณต้องการลบ ?', Colors.red, 16.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              //OutlinedButton(
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                      width: screen * 0.28,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        //border: Border.all(color: Colors.greenAccent[400], width: 1,),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: MyStyle()
                          .titleCenter(context, 'ยกเลิก', 16.0, Colors.black))),
              TextButton(
                  onPressed: () async {
                    //***Get.back();
                    Navigator.pop(context);
                    setState(() {
                      //ต้องทำเนื่องจากมีปัญหา *** type 'int' is not subtype of 'double' ***
                    });
                  },
                  child: Container(
                      width: screen * 0.28,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.redAccent[700],
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: MyStyle()
                          .titleCenter(context, 'ยืนยัน', 16.0, Colors.white))),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> confirmDelete(CartStateController controller) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle().txtstyle('คุณต้องการลบ ?', Colors.red, 16.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              //OutlinedButton(
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                      width: screen * 0.28,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        //border: Border.all(color: Colors.greenAccent[400], width: 1,),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: MyStyle()
                          .titleCenter(context, 'ยกเลิก', 16.0, Colors.black))),
              TextButton(
                  onPressed: () async {
                    //print('>>>> ${mainStateController.selectedRestaurant.value.restaurantId}');
                    cartViewModel.clearCart(
                        controller,
                        mainStateController
                            .selectedRestaurant.value.restaurantId,
                        controller
                            .getCart(mainStateController
                                .selectedRestaurant.value.restaurantId)
                            .toList());
                    Navigator.pop(context);
                    setState(() {
                      //ต้องทำเนื่องจากมีปัญหา *** type 'int' is not subtype of 'double' ***
                    });
                  },
                  child: Container(
                      width: screen * 0.28,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.redAccent[700],
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: MyStyle()
                          .titleCenter(context, 'ยืนยัน', 16.0, Colors.white))),
            ],
          )
        ],
      ),
    );
  }

  Widget nextButton() => Container(
      margin: const EdgeInsets.only(bottom: 3),
      width: screen * 0.98,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => SendOrder(mainStateController, controller,
                  cartViewModel, sumValue, loginModel));
          Navigator.push(context, route);
        },
        icon: Icon(
          Icons.house_outlined,
          color: Colors.white,
          size: 32.0,
        ),
        label: MyStyle().txtstyle('สถานที่จัดส่ง', Colors.white, 14.0),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return MyStyle().savecolor; // Use the component's default.
            },
          ),
        ),
      ));

  Container buildAccBank() {
    return Container(
        margin: const EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: 8,
          child: Container(
              padding: EdgeInsets.all(0.0),
              //width: screen*0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(
                    () => ExpansionTile(
                      onExpansionChanged: _onExpanAccChanged,
                      trailing: Switch(
                        value: isExpanAcc,
                        onChanged: (_) {},
                      ),
                      title: MyStyle()
                          .txtstyle(accbank_WORD, Colors.redAccent[700], 14.0),
                      children: [
                        Column(
                          children: listStateController
                              .selectedAccount.value.account
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.account_box,
                                                color: Colors.black),
                                            SizedBox(width: 5),
                                            Container(
                                                width: screen * 0.42,
                                                child: MyStyle().txtstyle(
                                                    '${e.accno}',
                                                    Colors.red,
                                                    13.0)),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: MyStyle().txtstyle(
                                                    '${e.bkname}',
                                                    Colors.black54,
                                                    11.0))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: MyStyle().txtstyle(
                                                  '${e.accname}',
                                                  Colors.black,
                                                  13.0),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  ListTile userSelectShoptypeMenu() => ListTile(
        leading: Icon(Icons.fastfood),
        title: MyStyle().titleDark('ร้านค้า'),
        subtitle: MyStyle().subtitleDark('ร้านค้าที่ร่วมโครงการ'),
        onTap: () {
          setState(() {
            currentWidget = UserSelectShoptype(); //UserResturantMenu();
          });
          Navigator.pop(context);
        },
      );

  Widget homeMenu() {
    return Container(
      decoration: BoxDecoration(color: MyStyle().bgsignout),
      child: ListTile(
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        title: MyStyle().titleLight('โฮมเมนู'),
        subtitle: MyStyle().subtitleLight('Back to home page.'),
        onTap: () => MainUser(),
      ),
    );
  }
}
