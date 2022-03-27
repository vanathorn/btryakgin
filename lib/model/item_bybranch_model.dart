class ItemByBranchModel {
  String shopname;
  String branchname;
  int iid;
  String iname;
  double qty = 0;
  String uname;
  String seq;

  ItemByBranchModel(
      {this.shopname,
      this.branchname,
      this.iid,
      this.iname,
      this.qty,
      this.uname,
      this.seq});

  ItemByBranchModel.fromJson(Map<String, dynamic> json) {
    shopname = json['shopname'];
    branchname = json['branchname'];
    iid = 0;
    if (json['iid'] != null && json['iid'] != '') {
      iid = int.parse(json['iid'].toString());
    }
    iname = json['iname'];
    qty = 0;
    if (json['qty'] != null && json['qty'] != '') {
      qty = double.parse(json['qty'].toString());
    }
    uname = json['uname'];
    seq = json['seq'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shopname'] = this.shopname;
    data['branchname'] = this.branchname;
    data['iid'] = this.iid;
    data['iname'] = this.iname;
    data['qty'] = this.qty;
    data['uname'] = this.uname;
    data['seq'] = this.seq;
    return data;
  }
}
