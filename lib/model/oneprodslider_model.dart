class OneProdSlideModel {
  String iid='';
  String iname='';
  String foodpict='';

  OneProdSlideModel({this.iid, this.iname, this.foodpict});

  OneProdSlideModel.fromJson(Map<String, dynamic> json) {
    iid = json['iid'] == null ? '0' : json['iid'];
    iname = json['iname'] == null ? '': json['iname'];
    foodpict = json['foodpict'] ==  null ? 'photo256.png': json['foodpict'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['iid'] = this.iid;
    data['iname'] = this.iname;
    data['foodpict'] = this.foodpict;
    return data;
  }
}