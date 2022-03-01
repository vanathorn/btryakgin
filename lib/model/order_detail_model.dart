class OrdDetailModel {
  String restaurantId = '';
  String ccode = '';
  String olDid = '';
  String iid = '';
  String seq = '';
  String itemname = '';
  String uname = '';
  double qty = 0;
  double unitprice = 0;
  double netamount = 0;

  OrdDetailModel(this.restaurantId, this.seq, this.itemname, this.qty,
      this.unitprice, this.netamount,
      {String ccode: '', String olDid: '0', String iid: '0'});
  OrdDetailModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    ccode = json['ccode'];
    olDid = json['olDid'];
    iid = json['iid'];
    seq = json['seq'];
    itemname = json['itemname'];
    if (json['qty'] != null && json['qty'] != '') {
      qty = double.parse(json['qty']);
    } else {
      qty = 0.0;
    }
    if (json['unitprice'] != null && json['unitprice'] != '') {
      unitprice = double.parse(json['unitprice']);
    } else {
      unitprice = 0.0;
    }
    if (json['netamount'] != null && json['netamount'] != '') {
      netamount = double.parse(json['netamount']);
    } else {
      netamount = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['ccode'] = this.ccode;
    data['olDid'] = this.olDid;
    data['iid'] = this.iid;
    data['seq'] = this.seq;
    data['itemname'] = this.itemname;
    data['qty'] = this.qty;
    data['unitprice'] = this.unitprice;
    data['netamount'] = this.netamount;
    return data;
  }
}
