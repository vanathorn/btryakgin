import 'package:yakgin/model/sum_detail_model.dart';

class ITypeLocModel {
  String seq = '';
  String loccode = '';
  String itid = '';
  String itname = '';
  String ttlitem = '';
  List<SumDetailModel> stockdtl = List<SumDetailModel>.empty(growable: true);

  ITypeLocModel({this.seq, this.loccode, this.itid, this.itname, this.ttlitem, this.stockdtl});

  ITypeLocModel.fromJson(Map<String, dynamic> json) {
    seq = json['seq'];
    loccode = json['loccode'];
    itid = json['itid'];
    itname = json['itname'];
    ttlitem = json['ttlitem'];
    if (json['stockdtl'] != null) {
      stockdtl = List<SumDetailModel>.empty(growable: true);
      json['stockdtl'].forEach((v) {
        stockdtl.add(SumDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seq'] = this.seq;
    data['loccode'] = this.loccode;
    data['itid'] = this.itid;
    data['itname'] = this.itname;
    data['ttlitem'] = this.ttlitem;
    data['stockdtl'] = this.stockdtl.map((e) => e.toJson()).toList();
    return data;
  }
}
