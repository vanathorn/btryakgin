import 'package:flutter/material.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/state/main_state.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:get/get.dart';

class CartTotalWidget extends StatelessWidget {
  CartTotalWidget(
      {Key key,
      @required this.controller,
      @required this.distance,
      @required this.logistCost})
      : super(key: key);

  final CartStateController controller;
  final String logistCost;
  final String distance;
  final MainStateController mainStateController = Get.find();

  @override
  Widget build(BuildContext context) {
    double shippingFree = 0;
    try {
      shippingFree = ('$logistCost' != null) ? double.parse('$logistCost') : 0;
    } catch (e) {
      //
    }
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TotalItemWidget(
                controller: controller,
                text: 'มูลค่าสินค้า',
                value: controller.sumCart(
                    mainStateController.selectedRestaurant.value.restaurantId),
                isSubTotal: false),
            Divider(thickness: 1),
            TotalItemWidget(
                controller: controller,
                text: ('$distance' != null && '$distance' != '')
                    ? 'ค่าขนส่ง ($distance)'
                    : 'ค่าขนส่ง',
                value: shippingFree,
                isSubTotal: false),
            Divider(thickness: 1),
            TotalItemWidget(
                controller: controller,
                text: 'ยอดรวม',
                value: (controller.sumCart(mainStateController
                        .selectedRestaurant.value.restaurantId) +
                    shippingFree),
                isSubTotal: true)
          ],
        ),
      ),
    );
  }
}

class TotalItemWidget extends StatelessWidget {
  const TotalItemWidget({
    Key key,
    @required this.controller,
    @required this.text,
    @required this.value,
    @required this.isSubTotal,
  }) : super(key: key);

  final CartStateController controller;
  final String text;
  final double value;
  final bool isSubTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyStyle().txtstyle(
            text,
            (isSubTotal ? Colors.redAccent[700] : Colors.black),
            (isSubTotal ? 15 : 14)),
        MyStyle().txtstyle(
            MyCalculate().fmtNumberBath(value),
            (isSubTotal ? Colors.redAccent[700] : Colors.black),
            (isSubTotal ? 18 : 15))
      ],
    );
  }
}
