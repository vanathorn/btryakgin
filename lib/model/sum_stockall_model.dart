import 'package:yakgin/model/itype_loc_model.dart';

class SumStockAllModel {
  String restaurantId;
  String ccode;
  String locid;
  String loccode;
  String locname;
  String ttltype;
  String itid;
  String itname;
  String ttlitem;
  String detailList;
  List<ITypeLocModel> itypedtl = List<ITypeLocModel>.empty(growable: true);

  SumStockAllModel(
      {this.restaurantId,
      this.ccode,
      this.locid,
      this.loccode,
      this.locname,
      this.ttltype,
      this.itid,
      this.itname,
      this.ttlitem,
      this.detailList,
      this.itypedtl});

  SumStockAllModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    ccode = json['ccode'];
    locid = json['locid'];
    loccode = json['loccode'];
    locname = json['locname'];
    ttltype = json['ttltype'];
    itid = json['itid'];
    itname = json['itname'];
    ttlitem = json['ttlitem'];
    detailList = json['detailList'];
    if (json['itypedtl'] != null) {
      itypedtl = List<ITypeLocModel>.empty(growable: true);
      json['itypedtl'].forEach((v) {
        itypedtl.add(ITypeLocModel.fromJson(v));
      });
    }    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['ccode'] = this.ccode;
    data['locid'] = this.locid;
    data['loccode'] = this.loccode;
    data['locname'] = this.locname;
    data['ttltype'] = this.ttltype;
    data['itid'] = this.itid;
    data['itname'] = this.itname;
    data['ttlitem'] = this.ttlitem;
    data['detailList'] = this.detailList;
    data['itypedtl'] = this.itypedtl.map((e) => e.toJson()).toList();
    return data;
  }
}
