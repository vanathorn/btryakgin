import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/screen/custom/cart_screen.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:get/get.dart';
//*--  err-firebase import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:btryakgin/model/cart_model.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/view/cart_vm/cart_view_model_imp.dart';

class CartShopListScreen extends StatefulWidget {
  @override
  _CartShopListScreenState createState() => _CartShopListScreenState();
}

class _CartShopListScreenState extends State<CartShopListScreen> {
  /*--  err-firebase final box = GetStorage(); */
  final CartViewModelImp cartViewModel = new CartViewModelImp();
  final MainStateController mainStateController = Get.find();
  List<CartModel> cModel = List<CartModel>.empty(growable: true);

  String loginName = '', webPath = '';
  double screen;
  String strPrice;

  String restLat, restLng;
  double lat1, lng1, latShop, lngShop, distance;
  String strDistance;
  Location location = Location();
  final int startLogist = 30;
  double shippingFree = 0;
  int logistCost;

  String strKeyVal = '', nameBVal = '', nameCVal = '', straddonVal = '';

  @override
  void initState() {
    super.initState();
  }

  Future<Null> getCartShop() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    // cModel = controller.getCartShop().toList();
    // CartModel ls =  new CartModel();
    // cModel.forEach((item) {
    //     ls.restaurantId=item.restaurantId;
    //     cModel.add(ls);
    // });
    final CartStateController controller = Get.find();
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: controller.getCartShop().toList().length > 0
          ? Obx(() => Column(
                children: [
                  Container(
                      height: 32,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('กดบนร้านค้าเพื่อดูรายละเอียด',
                              style: TextStyle(
                                fontFamily: 'thaisanslite',
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              )),
                        ],
                      )),
                  Expanded(
                      child: ListView.builder(
                          itemCount: controller.getCartShop().toList().length,
                          itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                mainStateController.selectedRestaurant.value =
                                    controller.getCartShop().toList()[index];
                                MaterialPageRoute route = MaterialPageRoute(
                                  builder: (context) => CartDetailScreen(),
                                );
                                Navigator.push(context, route)
                                    .then((value) => setState(() {
                                          //เพื่อให้ refresh ยอด Summary ใหม่
                                        }));
                              },
                              child: Card(
                                  elevation: 10.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 3.0),
                                  child: Column(children: [
                                    Container(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: screen - (screen * 0.5),
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            child: MyStyle().txtstyle(
                                                '${controller.getCartShop().toList()[index].thainame}',
                                                Colors.black,
                                                12)),
                                        Container(
                                          width: screen - (screen * 0.6),
                                          margin:
                                              const EdgeInsets.only(right: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.mobile_friendly,
                                                  color: Colors.black),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              MyStyle().txtstyle(
                                                  '${controller.getCartShop().toList()[index].phone}',
                                                  Colors.blue[900],
                                                  12),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                    Container(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '${MyConstant().domain}/${MyConstant().shopimagepath}/${controller.getCartShop().toList()[index].shoppict}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Column(children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 32,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Row(
                                                      //mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        totalItemWidget(
                                                            controller,
                                                            'มูลค่าสินค้า ',
                                                            '(ไม่รวมค่าขนส่ง)',
                                                            controller.sumCart(
                                                                controller
                                                                    .getCartShop()
                                                                    .toList()[
                                                                        index]
                                                                    .restaurantId)), // + shippingFree
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]))))),
                ],
              ))
          : Center(
              child: MyStyle().titleCenterTH(
                  context, 'ไม่มีสินค้าในตะกร้า\r\nของคุณ', 18, Colors.red),
            ),
    );
  }

  Widget totalItemWidget(CartStateController controller, String strTxt,
      String strTxt2, double logistCost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            MyStyle().txtstyle(strTxt, Colors.redAccent[700], 12),
            SizedBox(width: 2.0),
            MyStyle().txtbody(strTxt2),
            SizedBox(width: 20.0),
            MyStyle().txtstyle(MyCalculate().fmtNumberBath(logistCost),
                Colors.redAccent[700], 14),
          ],
        ),
      ],
    );
  }
}
