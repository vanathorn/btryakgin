class SendModel {
  String name;
  String address;
  String mobile;
  String lat='';
  String lng='';

  SendModel({
      this.name,
      this.address,
      this.mobile,
      this.lat,
      this.lng,});

  SendModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
    mobile = json['mobile'];
    lat = json['lat'];
    lng = json['lng'];    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    data['mobile'] = this.mobile;    
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}
