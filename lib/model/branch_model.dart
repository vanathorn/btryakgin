class BranchModel {
  String thainame = '';
  String branchcode = '';
  String branchname = '';
  String address = '';
  String phone = '';
  String lat = '';
  String lng = '';
  String shoppict = ''; 

  BranchModel(
      {this.thainame,
      this.branchcode,
      this.branchname,
      this.address,
      this.phone,
      this.lat,
      this.lng,
      this.shoppict});

  BranchModel.fromJson(Map<String, dynamic> json) {
    thainame = json['thainame'];
    branchcode = json['branchcode'];
    branchname = json['branchname'];
    address = json['address'];
    phone = json['phone'];
    lat = json['lat'];
    lng = json['lng'];
    shoppict = json['shoppict'];    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thainame'] = this.thainame;
    data['branchcode'] = this.branchcode;
    data['branchname'] = this.branchname;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['shoppict'] = this.shoppict;    
    return data;
  }
}
