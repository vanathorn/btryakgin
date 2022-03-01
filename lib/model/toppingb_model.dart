class ToppingBModel {
  int topid = 0;
  String toptitle = '';
  String topname = '';
  double addprice = 0;

  ToppingBModel({this.toptitle, this.topid, this.topname, this.addprice});
  ToppingBModel.fromJson(Map<String, dynamic> json) {
    topid = int.parse(json['topid'].toString());
    toptitle = json['toptitle'];
    topname = json['topname'];
    addprice = 0;
    if (json['addprice'] != null && json['addprice'] != '') {
      addprice = double.parse(json['addprice'].toString());
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['topid'] = this.topid;
    data['toptitle'] = this.toptitle;
    data['topname'] = this.topname;
    data['addprice'] = this.addprice;
    return data;
  }
}
