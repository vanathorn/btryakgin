import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_elegant_number_button/flutter_elegant_number_button.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import 'package:yakgin/model/login_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/model/sum_value.dart';
import 'package:yakgin/model/user_model.dart';
import 'package:yakgin/screen/branch/branch_order.dart';
import 'package:yakgin/screen/custom/user_select_shoptype.dart';
import 'package:get/get.dart';
import 'package:yakgin/model/cart_model.dart';
import 'package:yakgin/screen/menu/main_shop_branch.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/view/cart_vm/cart_view_model_imp.dart';
import 'package:yakgin/widget/cart/cart_image_widget.dart';
import 'package:yakgin/widget/cart/pay_cart_total_widget.dart';
import 'package:yakgin/widget/mysnackbar.dart';

class PayCartDetailScreen extends StatefulWidget {
  @override
  _PayCartDetailScreenState createState() => _PayCartDetailScreenState();
}

class _PayCartDetailScreenState extends State<PayCartDetailScreen> {
  /*--  err-firebase final box = GetStorage(); */
  final CartStateController controller = Get.find();
  final CartViewModelImp cartViewModel = new CartViewModelImp();
  final MainStateController mainStateController = Get.find();

  String txtName = '', txtMobile = '';
  double screen, screenH;
  String strPrice;

  final double iEle = 20;
  final double hi = 10;
  final int maxnum = 10;
  String strKeyVal = '', nameBVal = '', nameCVal = '', straddonVal = '';
  SumValue sumValue = new SumValue();
  LoginModel loginModel = new LoginModel();
  ShopRestModel shopModel = new ShopRestModel();
  Widget currentWidget = UserSelectShoptype();
  String mbimage = 'userlogo.png';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    screenH = 42;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white60, //.headcolor,
          title: Row(
            children: [
              Container(
                height: 38.0,
                width: 38,
                child: FloatingActionButton(
                  backgroundColor: MyStyle().primarycolor,
                  onPressed: () {
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) =>
                            MainShopBranch() //ProdCategoryScreen(),
                        );
                    Navigator.pushAndRemoveUntil(
                        context, route, (route) => false);
                  },
                  child: Icon(
                    Icons.home, //shopping_basket,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
              controller.getQuantity(mainStateController
                          .selectedRestaurant.value.restaurantId) >
                      0
                  ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        width: screen * 0.66,
                        margin: const EdgeInsets.only(left: 5.0),
                        child: MyStyle().txtstyle(
                            'เลื่อนขวาไปซ้ายเพื่อลบรายการ', Colors.black, 10.0),
                      ),
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
                    ])
                  : Container()
            ],
          )),
      body: controller
                  .getCart(
                      mainStateController.selectedRestaurant.value.restaurantId)
                  .toList()
                  .length >
              0
          ? Obx(() => Column(
                children: [
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
                                            strKeyVal);
                                        setState(() {});
                                      })
                                ],
                              ))),
                  PayCartTotalWidget(
                      controller: controller, distance: ('0'), logistCost: '0'),
                  (controller.getQuantity(mainStateController
                              .selectedRestaurant.value.restaurantId) >
                          0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                              generalButton(),
                              memberButton(),
                            ])
                      : Container()
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
          width: 100,
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
          width: 100,
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
          maxValue: (cartModelCtl.balqty > 0) ? cartModelCtl.balqty : 0,
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
          maxValue: (cartModelCtl.balqty > 0) ? cartModelCtl.balqty : 0,
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

  Widget generalButton() => Container(
      margin: const EdgeInsets.only(bottom: 3),
      width: screen * 0.45,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          txtName = MyConstant().genMember;
          txtMobile = MyConstant().genMobile;
          MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => BranchOrder(mainStateController, controller,
                  cartViewModel, sumValue, loginModel, txtName, txtMobile));
          Navigator.push(context, route);
        },
        icon: Icon(
          Icons.face,
          color: Colors.white,
          size: 32.0,
        ),
        label: MyStyle().txtstyle(MyConstant().genMember, Colors.white, 14.0),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return Colors.blue;
              return Colors.black; // Use the component's default.
            },
          ),
        ),
      ));

  Widget memberButton() => Container(
      margin: const EdgeInsets.only(bottom: 3),
      width: screen * 0.45,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          dialogGetMember();
        },
        icon: Icon(
          Icons.face_retouching_natural,
          color: Colors.white,
          size: 32.0,
        ),
        label: MyStyle().txtstyle('สมาชิก', Colors.white, 14.0),
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

  Future<Null> dialogGetMember() async {
    txtMobile = '';
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('เบอร์มือถือสมาชิก', style: MyStyle().myLabelStyle())
                    ]),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(txtMobile,
                            style: TextStyle(
                              fontSize: 32.0,
                              color: Colors.red,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              decorationStyle: TextDecorationStyle.solid,
                              letterSpacing: -1.0,
                              wordSpacing: 5.0,
                              fontFamily: 'Arial',
                            )),
                      ],
                    ),
                    SizedBox(height: 5),
                    keyPad(setState),
                    Divider(thickness: 1),
                    cancelButton(context, setState),
                  ],
                ),
              ),
            ));
  }

  Row keyPad(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: screen * 0.63,
          margin: const EdgeInsets.only(bottom: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(setState, '1'),
                  buildButton(setState, '2'),
                  buildButton(setState, '3'),
                ],
              ),
              SizedBox(height: hi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(setState, '4'),
                  buildButton(setState, '5'),
                  buildButton(setState, '6'),
                ],
              ),
              SizedBox(height: hi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(setState, '7'),
                  buildButton(setState, '8'),
                  buildButton(setState, '9'),
                ],
              ),
              SizedBox(height: hi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  clearButton(setState),
                  buildButton(setState, '0'),
                  delButton(setState),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  GestureDetector buildButton(StateSetter setState, String txtValue) {
    return GestureDetector(
      child: InkWell(
        onTap: () {
          String tmp = txtMobile;
          if (tmp.length < maxnum) {
            setState(() {
              txtMobile += txtValue;
              if (txtMobile.length == maxnum) {
                _checkMember();
              }
            });
          }
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.black,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[350],
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(70))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(txtValue,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.normal,
                      color: Colors.redAccent[700])),
            ],
          ),
        ),
      ),
    );
  }

  Container delButton(StateSetter setState) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          String tmp = txtMobile.toString();
          if (tmp.length > 0) {
            setState(() {
              txtMobile = tmp.substring(0, tmp.length - 1);
              //if (txtMobile == '') txtMobile = '';
            });
          }
        },
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(
          Icons.backspace,
          color: Colors.white,
          size: 32,
        ),
        splashColor: Colors.blue,
      ),
    );
  }

  Container clearButton(StateSetter setState) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black54,
        onPressed: () {
          setState(() {
            txtMobile = '';
          });
        },
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            )),
        icon: Icon(
          Icons.clear_all,
          color: Colors.white,
          size: 38,
        ),
        splashColor: Colors.redAccent[400],
      ),
    );
  }

  void _checkMember() {
    if ((txtMobile?.isEmpty ?? true) || (txtMobile.length != maxnum)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar(
              "!เบอร์ไม่ครบ $maxnum หลัก", Icons.app_blocking_outlined,
              strDimiss: 'ลองใหม่'),
        );
      setState(() {
        //
      });
    } else {
      checkAuthen();
    }
  }

  Future<Null> checkAuthen() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'checkMobile.aspx?Mobile=$txtMobile';

    try {
      dio.Response response = await dio.Dio().get(url);
      if (response.toString().trim() == '') {
        Toast.show(
          '!ไม่พบเบอร์มือถือ $txtMobile',
          context,
          gravity: Toast.CENTER,
          backgroundColor: Colors.black,
          textColor: Colors.yellow,
        );
        /* ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            MySnackBar.showSnackBar(
                "!ไม่พบเบอร์มือถือ $txtMobile ในระบบ", Icons.mobile_off,
                strDimiss: 'ลองใหม่'),
          );*/
      } else if (response != null) {
        Navigator.pop(context);
        var result = json.decode(response.data);
        for (var map in result) {
          UserModel usermodel = UserModel.fromJson(map);
          if (txtMobile == usermodel.mobile) {
            txtName = usermodel.mbname;
            MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => BranchOrder(
                    mainStateController,
                    controller,
                    cartViewModel,
                    sumValue,
                    loginModel,
                    txtName,
                    txtMobile));
            //Navigator.push(context, route);
            Navigator.pushAndRemoveUntil(context, route, (route) => true);
            //false หน้าต่อไปจะไม่มี <-
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                MySnackBar.showSnackBar(
                    "!เบอร์มือถือไม่ถูกต้อง", Icons.cloud_off),
              );
          }
        }
      }
    } catch (e) {
      debugPrint('*** ${e.toString()}');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar("!ติดต่อ Server ไม่ได้", Icons.cloud_off),
        );
    }
  }

  Row cancelButton(BuildContext context, StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
                width: screen * 0.25,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: MyStyle()
                    .titleCenter(context, 'ยกเลิก', 14.0, Colors.black))),
      ],
    );
  }
}
