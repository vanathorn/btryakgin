class ShopMenuModel {
  String smid='';
  String smname='';

  ShopMenuModel({
      this.smid,
      this.smname}
  );

  ShopMenuModel.fromJson(Map<String, dynamic> json) {
    smid = json['smid'];
    smname = json['smname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['smid'] = this.smid;
    data['smname'] = this.smname;
    return data;
  }

}
