import 'package:flutter/material.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:get/get.dart';

class PayCartTotalWidget extends StatelessWidget {
  PayCartTotalWidget({Key key,
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
