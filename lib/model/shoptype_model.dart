class ShopTypeModel {
  String stid;
  String stypename;
  String stypepict;

  ShopTypeModel({this.stid, this.stypename, this.stypepict});

  ShopTypeModel.fromJson(Map<String, dynamic> json) {
    stid = json['stid'];
    stypename = json['stypename'];
    stypepict = json['stypepict'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stid'] = this.stid;
    data['stypename'] = this.stypename;
    data['stypepict'] = this.stypepict;
    return data;
  }
}
