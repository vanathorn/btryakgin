import 'package:btryakgin/model/order_model.dart';

class CartOrderModel extends OrderModel {
  int countord = 0;
  String restaurantId = '';

  CartOrderModel({countord, this.restaurantId})
      : super(
        //
        );

  factory CartOrderModel.fromJson(Map<String, dynamic> json) {
    //final straddon = json['straddon'];

    return CartOrderModel(
      countord: 0,
      //straddon: straddon,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['countord'] = this.countord;
    //data['straddon'] = this.straddon;
    return data;
  }
}
