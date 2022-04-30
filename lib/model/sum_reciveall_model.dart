import 'package:yakgin/model/itype_loc_model.dart';

class SumReciveAllModel {
  String restaurantId;
  String ccode;
  String locid;
  String loccode;
  String locname;
  String ttldate;
  String sortDate;
  String strDate;
  String ttlitem;
  String detailList;
  List<ITypeLocModel> itypedtl = List<ITypeLocModel>.empty(growable: true);

  SumReciveAllModel(
      {this.restaurantId,
      this.ccode,
      this.locid,
      this.loccode,
      this.locname,
      this.ttldate,
      this.sortDate,
      this.strDate,
      this.ttlitem,
      this.detailList,
      this.itypedtl});

  SumReciveAllModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    ccode = json['ccode'];
    locid = json['locid'];
    loccode = json['loccode'];
    locname = json['locname'];
    ttldate = json['ttltype'];
    sortDate = json['sortDate'];
    strDate = json['strorderDate'];
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
    data['ttltype'] = this.ttldate;
    data['sortDate'] = this.sortDate;
    data['strorderDate'] = this.strDate;
    data['ttlitem'] = this.ttlitem;
    data['detailList'] = this.detailList;
    data['itypedtl'] = this.itypedtl.map((e) => e.toJson()).toList();
    return data;
  }
}
