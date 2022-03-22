class ShopTypeModel {
  int stid;
  String stypename;
  String stypepict;
  int seq;

  ShopTypeModel({this.stid, this.stypename, this.stypepict, this.seq});

  factory ShopTypeModel.fromJson(Map<String, dynamic> json) {
    return ShopTypeModel(
      stid: json['stid'] as int,
      stypename: json['stypename'] as String,
      stypepict: json['stypepict'] as String,
      seq: json['seq'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stid'] = this.stid;
    data['stypename'] = this.stypename;
    data['stypepict'] = this.stypepict;
    data['seq'] = this.seq;
    return data;
  }
}
