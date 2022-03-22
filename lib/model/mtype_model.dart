import 'package:yakgin/model/mbt_model.dart';

class MTypeModel {
  String mbid = '';
  String mbname = '';
  String mobile = '';
  String decryptpsw = '';
  String mbtlist = '';
  String ctypeDetail = '';
  String resturantid = '';
  String shopname = '';
  List<MbtModel> ctypeDtl = List<MbtModel>.empty(growable: true);

  MTypeModel(
      {this.mbid,
      this.mbname,
      this.mobile,
      this.decryptpsw,
      this.mbtlist,
      this.ctypeDetail,
      this.resturantid,
      this.shopname,
      this.ctypeDtl});
  MTypeModel.fromJson(Map<String, dynamic> json) {
    mbid = json['mbid'].toString();
    mbname = json['mbname'];
    mobile = json['mobile'];
    decryptpsw = json['decryptpsw'];
    mbtlist = json['mbtlist'];
    ctypeDetail = json['ctypeDetail'];
    resturantid = '';
    if (json['resturantid'] != null) resturantid = json['resturantid'];
    shopname = '';
    if (json['shopname'] != null) shopname = json['shopname'];
    if (json['ctypeDtl'] != null) {
      ctypeDtl = List<MbtModel>.empty(growable: true);
      json['ctypeDtl'].forEach((v) {
        ctypeDtl.add(MbtModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['mbid'] = this.mbid;
    data['mbname'] = this.mbname;
    data['mobile'] = this.mobile;
    data['decryptpsw'] = this.decryptpsw;
    data['mbtlist'] = this.mbtlist;
    data['ctypeDetail'] = this.ctypeDetail;
    data['resturantid'] = this.resturantid;
    data['shopname'] = this.shopname;
    data['ctypeDtl'] = this.ctypeDtl.map((e) => e.toJson()).toList();
    return data;
  }
}
