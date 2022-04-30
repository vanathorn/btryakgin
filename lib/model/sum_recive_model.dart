import 'package:yakgin/model/sum_detail_model.dart';

class SumReciveModel {
  String restaurantId;
  String ccode; 
  String strorderDate;
  String sortDate;
  String ttlNetAmount;
  String ttlGrsAmount;
  String ttlitem;
  String detailList;
  List<SumDetailModel> recivedtl=List<SumDetailModel>.empty(growable: true);

  SumReciveModel(
      {this.restaurantId,
      this.ccode,
      this.strorderDate,
      this.sortDate,
      this.ttlNetAmount,
      this.ttlGrsAmount,
      this.ttlitem,
      this.detailList,
      this.recivedtl});

  SumReciveModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    ccode = json['ccode'];
    strorderDate = json['strorderDate'];
    sortDate = json['sortDate'];
    ttlNetAmount = json['ttlNetAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];
    ttlitem = json['ttlitem'];
    detailList = json['detailList'];
    if (json['rcdtl'] != null) {
      recivedtl = List<SumDetailModel>.empty(growable: true);
      json['rcdtl'].forEach((v) {
        recivedtl.add(SumDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['ccode'] = this.ccode;
    data['strorderDate'] = this.strorderDate;
    data['sortDate'] = this.sortDate;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['ttlitem'] = this.ttlitem;
    data['detailList'] = this.detailList;
    data['rcdtl'] = this.recivedtl.map((e) => e.toJson()).toList();
    return data;
  }
}
