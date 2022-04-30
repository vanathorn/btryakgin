import 'package:yakgin/model/sum_detail_model.dart';

class SumStockModel {
  String restaurantId;
  String ccode; 
  String itid;
  String itname;
  String ttlitem;
  String detailList;
  List<SumDetailModel> stockdtl = List<SumDetailModel>.empty(growable: true);

  SumStockModel(
      {this.restaurantId,
      this.ccode,
      this.itid,
      this.itname,
      this.ttlitem,
      this.detailList,
      this.stockdtl});

  SumStockModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    ccode = json['ccode'];
    itid = json['itid'];
    itname = json['itname'];
    ttlitem = json['ttlitem'];
    detailList = json['detailList'];
    if (json['stockdtl'] != null) {
      stockdtl = List<SumDetailModel>.empty(growable: true);
      json['stockdtl'].forEach((v) {
        stockdtl.add(SumDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['ccode'] = this.ccode;
    data['itid'] = this.itid;
    data['itname'] = this.itname;
    data['ttlitem'] = this.ttlitem;
    data['detailList'] = this.detailList;
    data['stockdtl'] = this.stockdtl.map((e) => e.toJson()).toList();
    return data;
  }
}
