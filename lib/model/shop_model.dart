class ShopModel {
  String thainame = '';
  String branchname = '';
  String addrline = '';
  String address = '';
  String build = '';
  String road = '';
  String district = '';
  String amphur = '';
  String province = '';
  String zipcode = '';
  String phone = '';
  String lat = '';
  String lng = '';
  String shoppict = '';
  String banklist = '';

  ShopModel(
      {this.thainame,
      this.branchname,
      this.addrline,
      this.address,
      this.build,
      this.road,
      this.district,
      this.amphur,
      this.province,
      this.zipcode,
      this.phone,
      this.lat,
      this.lng,
      this.shoppict,
      this.banklist
      });

  ShopModel.fromJson(Map<String, dynamic> json) {
    thainame = json['thainame'];
    branchname = json['branchname'];
    addrline = json['addrline'];
    address = json['address'];
    build = '';
    road = '';
    district = '';
    amphur = '';
    province = '';
    zipcode = '';
    if (json['build'] != null) build = json['build'];
    if (json['road'] != null) road = json['road'];
    if (json['district'] != null) district = json['district'];
    if (json['amphur'] != null) amphur = json['amphur'];
    if (json['province'] != null) province = json['province'];
    if (json['zipcode'] != null) zipcode = json['zipcode'];
    phone = json['phone'];
    lat = json['lat'];
    lng = json['lng'];
    shoppict = json['shoppict'];
    banklist = json['banklist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thainame'] = this.thainame;
    data['branchname'] = this.branchname;
    data['addrline'] = this.addrline;
    data['address'] = this.address;
    data['build'] = this.build;
    data['road'] = this.road;
    data['district'] = this.district;
    data['amphur'] = this.amphur;
    data['province'] = this.province;
    data['zipcode'] = this.zipcode;
    data['phone'] = this.phone;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['shoppict'] = this.shoppict;
    data['banklist'] = this.banklist;
    return data;
  }
}
