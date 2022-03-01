import 'package:btryakgin/model/rider_order.dart';

class RiderModel {
  String restaurantId;
  String shopName;
  String shopAddress;
  String shopPhone;
  String latShop;
  String lngShop;
  String ccode;
  String distianceR;
  String detailList;
  List<RiderOrderModel> orddtl = List<RiderOrderModel>.empty(growable: true);

  RiderModel(
      {this.restaurantId,
      this.shopName,
      this.shopAddress,
      this.shopPhone,
      this.latShop,
      this.lngShop,
      this.ccode,
      this.distianceR,
      this.detailList,
      this.orddtl});

  RiderModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    shopName = json['shopName'];
    shopAddress = json['shopAddress'];
    shopPhone = json['shopPhone'];
    latShop = json['latShop'];
    lngShop = json['lngShop'];
    ccode = json['ccode'];
    distianceR = json['distianceR'];
    detailList = json['detailList'];
    if (json['orddtl'] != null) {
      orddtl = List<RiderOrderModel>.empty(growable: true);
      json['orddtl'].forEach((v) {
        orddtl.add(RiderOrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['shopName'] = this.shopName;
    data['shopAddress'] = this.shopAddress;
    data['shopPhone'] = this.shopPhone;
    data['latShop'] = this.latShop;
    data['lngShop'] = this.lngShop;
    data['ccode'] = this.ccode;
    data['distianceR'] = this.distianceR;
    data['detailList'] = this.detailList;
    data['orddtl'] = this.orddtl.map((e) => e.toJson()).toList();
    return data;
  }
}
