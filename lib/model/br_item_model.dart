class BrItemModel {
  String shopname;
  String branchname;
  String iname;
  double qty = 0;
  String uname;
  int iid;
  String seq;

  BrItemModel({
      this.shopname,
      this.branchname,
      this.iname,
      this.qty,
      this.uname,
      this.iid,
      this.seq
  });

  BrItemModel.fromJson(Map<String, dynamic> json) {
    shopname = json['shopname'];
    branchname = json['branchname'];
    iname = json['iname'];
    qty = 0;
    if (json['qty'] != null && json['qty'] != '') {
      qty = double.parse(json['qty'].toString());
    }
    uname = json['uname'];
    iid = 0;
    if (json['iid'] != null && json['iid'] != '') {
      iid = int.parse(json['iid'].toString());
    }
    seq = json['seq'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shopname'] = this.shopname;
    data['branchname'] = this.branchname;
    data['iname'] = this.iname;
    data['qty'] = this.qty;
    data['uname'] = this.uname;
    data['iid'] = this.iid;
    data['seq'] = this.seq;
    return data;
  }
}
