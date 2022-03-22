import 'package:yakgin/model/addon_model.dart';

class MemTypeModel {
  int mbtid = 0;
  String mbtcode = '';
  String mbtname = '';
  String mbtlist = '';
  List<AddonModel> addonM = List<AddonModel>.empty(growable: true);

  MemTypeModel({this.mbtid, this.mbtcode, this.mbtname, this.addonM});
  MemTypeModel.fromJson(Map<String, dynamic> json) {
    mbtid = int.parse(json['mbtid'].toString());
    mbtcode = json['mbtcode'];
    mbtname = json['mbtname'];
    if (json['mbtlist'] != null) {
      addonM = List<AddonModel>.empty(growable: true);
      json['mbtlist'].forEach((v) {
        addonM.add(AddonModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['mbtid'] = this.mbtid;
    data['mbtcode'] = this.mbtcode;
    data['mbtname'] = this.mbtname;
    data['mblist'] = this.mbtlist;
    data['addonM'] = this.addonM.map((e) => e.toJson()).toList();
    return data;
  }
}
