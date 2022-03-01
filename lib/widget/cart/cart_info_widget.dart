import 'package:flutter/material.dart';
import 'package:flutter_elegant_number_button/flutter_elegant_number_button.dart';
import 'package:btryakgin/model/cart_model.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:btryakgin/utility/mystyle.dart';

class CartInfoWidget extends StatelessWidget {
  const CartInfoWidget(
      {Key key, @required this.controller, @required this.cartModel})
      : super(key: key);

  final CartStateController controller;
  final CartModel cartModel;

  @override
  Widget build(BuildContext context) {
    //double screen = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: MyStyle().txtTH18Dark('ปกติ '),
                ),
                cartModel.quantity > 0
                    ? dispPriceNormal(cartModel)
                    : Container(),
              ],
            ),
          ),
          Expanded(flex: 6, child: Text('2')),
        ],
      ),
    );
  }

  Row normalPrice(CartModel cartModelCtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: MyStyle().txtTH18Dark('ปกติ '),
        ),
        cartModel.quantity > 0 ? dispPriceNormal(cartModel) : Container(),
        SizedBox(
          width: 5.0,
        ),
        //Obx(() =>
        ElegantNumberButton(
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
          buttonSizeWidth: 54,
          buttonSizeHeight: 48,
          textStyle: TextStyle(
              fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
        )
        //),
      ],
    );
  }

  Padding dispPriceNormal(CartModel cartModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(width: 25),
          Container(
            //width: 120,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  '${cartModel.quantity}*${MyCalculate().fmtNumber(cartModel.price)}', //${MyCalculate().currencyFormat.format(controll.cart[index].spprice)}
                  style: TextStyle(color: Colors.black),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          /*
          Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${MyCalculate().fmtNumberBath(cartModel.quantity*cartModel.price)}',
                style: TextStyle(color: Colors.redAccent[700]),
                maxLines: 2, overflow: TextOverflow.ellipsis,)
              ],
            ),
          )*/
        ],
      ),
    );
  }

  Padding dispPriceSpecial(CartModel cartModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(
            Icons.monetization_on_outlined,
            color: Colors.redAccent[700],
          ),
          Container(
            width: 120,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  '${cartModel.quantitySp}*${MyCalculate().fmtNumber(cartModel.priceSp)}', //${MyCalculate().currencyFormat.format(controll.cart[index].spprice)}
                  style: TextStyle(color: Colors.redAccent[700]),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${MyCalculate().fmtNumberBath(cartModel.quantitySp * cartModel.priceSp)}',
                  style: TextStyle(color: Colors.redAccent[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
