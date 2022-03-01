class OneProdSlideModel {
  String iid='';
  String iname='';
  String foodpict='';
  String slidepict1='';
  String slidepict2='';

  OneProdSlideModel({
    this.iid,
    this.iname,
    this.foodpict,
    this.slidepict1,
    this.slidepict2}
  );

  OneProdSlideModel.fromJson(Map<String, dynamic> json) {
    iid = json['iid'] == null ? '0' : json['iid'];
    iname = json['iname'] == null ? '': json['iname'];
    foodpict = json['foodpict'] ==  null ? 'photo256.png': json['foodpict'];
    slidepict1 = json['slidepict1'] ==  null ? 'photo256.png': json['slidepict1'];
    slidepict2 = json['slidepict2'] ==  null ? 'photo256.png' : json['slidepict2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['iid'] = this.iid;
    data['iname'] = this.iname;
    data['foodpict'] = this.foodpict;
    data['slidepict1'] = this.slidepict1;
    data['slidepict2'] = this.slidepict2;
    return data;
  }
}