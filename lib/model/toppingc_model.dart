class ToppingCModel {
  int topid = 0;
  String toptitle = '';
  String topname = '';
  double addprice = 0;

  ToppingCModel({this.toptitle, this.topid, this.topname, this.addprice});
  ToppingCModel.fromJson(Map<String, dynamic> json) {
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
