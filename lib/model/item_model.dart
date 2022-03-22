class ItemModel {
  int iid;
  String iname;
  int currqty;
  String uname;

  ItemModel({this.iid: 0, this.iname: '', this.currqty:0});

  ItemModel.fromJson(Map<String, dynamic> json) {
    iid = int.parse(json['iid'].toString());
    iname = json['iname'];
    if (json['currqty'] != null && json['currqty'] !='') {
      currqty = int.parse(json['currqty'].toString());
    }
    uname = json['uname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['iid'] = this.iid;
    data['iname'] = this.iname;
    data['currqty'] = this.currqty;
    data['uname'] = this.uname;
    return data;
  }
}
