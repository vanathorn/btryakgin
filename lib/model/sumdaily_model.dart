import 'package:btryakgin/model/sumdaily_detail_model.dart';

class SumDailyModel {
  String restaurantId;
  String shopName;
  String ccode; //ccode of Shop
  String strorderDate;
  String sortDate;
  String ttlNetAmount;
  String ttlGrsAmount;
  String ttlitem;
  String detailList;
  List<SumDailyDetailModel> orddtl =
      List<SumDailyDetailModel>.empty(growable: true);

  SumDailyModel(
      {this.restaurantId,
      this.shopName,
      this.ccode,
      this.strorderDate,
      this.sortDate,
      this.ttlNetAmount,
      this.ttlGrsAmount,
      this.ttlitem,
      this.detailList,
      this.orddtl});

  SumDailyModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    shopName = json['shopName'];
    ccode = json['ccode'];
    strorderDate = json['strorderDate'];
    sortDate = json['sortDate'];
    ttlNetAmount = json['ttlNetAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];
    ttlitem = json['ttlitem'];
    detailList = json['detailList'];
    if (json['orddtl'] != null) {
      orddtl = List<SumDailyDetailModel>.empty(growable: true);
      json['orddtl'].forEach((v) {
        orddtl.add(SumDailyDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['shopName'] = this.shopName;
    data['ccode'] = this.ccode;
    data['strorderDate'] = this.strorderDate;
    data['sortDate'] = this.sortDate;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['ttlitem'] = this.ttlitem;
    data['detailList'] = this..detailList;
    data['orddtl'] = this.orddtl.map((e) => e.toJson()).toList();
    return data;
  }
}
