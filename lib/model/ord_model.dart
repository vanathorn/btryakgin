import 'package:btryakgin/model/shoprest_model.dart';

class OrdModel extends ShopRestModel {
  String restaurantId = '';
  String shopName = '';
  int countord = 0;

  OrdModel({this.restaurantId, shopName, countord})
      : super(
          restaurantId: restaurantId,
          cntord: countord,
        );

  //factory
  OrdModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    shopName = json['shopName'];
    countord = 0;

    if (json['countord'] != null && json['countord'] != '') {
      countord = int.parse(json['countord'].toString());
    }
    // return OrdModel(
    //    restaurantId: restaurantId,
    //    shopName: shopName,
    //    countord: countord,
    // );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['shopName'] = this.shopName;
    data['countord'] = this.countord;
    return data;
  }
}
