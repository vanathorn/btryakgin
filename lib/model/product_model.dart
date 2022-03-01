class ProductModel {
  String itid='';
  String itname='';
  String iid='';
  String icode='';
  String iname='';
  String idescription='';
  String price='';
  String uname='';
  String foodpict='';
  String slidepict1='';
  String slidepict2='';

  ProductModel({
      this.itid,
      this.itname,
      this.iid,
      this.icode,
      this.iname,
      this.idescription,
      this.price,
      this.uname,
      this.foodpict,
      this.slidepict1,
      this.slidepict2}
  );

  ProductModel.fromJson(Map<String, dynamic> json) {
    itid = json['itid'];
    itname = json['itname'];
    iid = json['iid'];
    icode = json['icode'];
    iname = json['iname'];
    idescription = json['idescription'];
    price = json['price'];
    uname = json['uname'];
    foodpict = json['foodpict'];
    slidepict1 = json['slidepict1'];
    slidepict2 = json['slidepict2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itid'] = this.itid;
    data['itname'] = this.itname;
    data['iid'] = this.iid;
    data['icode'] = this.icode;
    data['iname'] = this.iname;
    data['idescription'] = this.idescription;
    data['price'] = this.price;
    data['uname'] = this.uname;
    data['foodpict'] = this.foodpict;
    data['slidepict1'] = this.slidepict1;
    data['slidepict2'] = this.slidepict2;
    return data;
  }
}