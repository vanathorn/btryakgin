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

  ProductModel(
      {this.itid,
      this.itname,
      this.iid,
      this.icode,
      this.iname,
      this.idescription,
      this.price,
      this.uname,
      this.foodpict});

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
    return data;
  }
}