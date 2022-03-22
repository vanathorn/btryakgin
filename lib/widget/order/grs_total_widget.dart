import 'package:flutter/material.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GrsTotalWidget extends StatelessWidget {
  GrsTotalWidget({
    Key key,
    @required this.netamount,
    @required this.discount,
    @required this.vatamount,
    @required this.logist,
    @required this.grsamount,

    //@required this.controller,
  }) : super(key: key);

  //final OrderDetailStateController controller;
  final double netamount;
  final double discount;
  final double vatamount;
  final double logist;
  final double grsamount;
  final MainStateController mainStateController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      elevation: 8,
      child: Container(
          height: 50,
          margin: const EdgeInsets.all(3),
           decoration: BoxDecoration(
            gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 3.0,
                colors: <Color>[Colors.white, Colors.blueAccent]),
          ),
          child: Column(
            //marginSymmetric : EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyStyle().txtshadowsIntoLight('Grs Amount'),
                    TotalItemWidget(
                        text: 'มูลค่าสุทธิ', value: grsamount, isSubTotal: true)
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class TotalItemWidget extends StatelessWidget {
  const TotalItemWidget({
    Key key,
    @required this.text,
    @required this.value,
    @required this.isSubTotal,
  }) : super(key: key);

  final String text;
  final double value;
  final bool isSubTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MyStyle().txtstyle(
            text,
            (isSubTotal ? Colors.redAccent[700] : Colors.black),
            (isSubTotal ? 13 : 13)),
        SizedBox(width: 10),
        MyStyle().txtstyle(
            MyCalculate().fmtNumberBath(value),
            (isSubTotal ? Colors.redAccent[700] : Colors.black),
            (isSubTotal ? 13 : 13))
      ],
    );
  }

  String fmtNumberBath(double decData) {
    String result;
    var myFmt = NumberFormat('#,###,##0.00', 'en_US');
    result = myFmt.format(decData) + ' ฿';
    return result;
  }
}
