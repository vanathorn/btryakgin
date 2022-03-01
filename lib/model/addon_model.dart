class AddonModel {
  int optid = 0;
  String optname = '';
  String optcode = '';
  double addprice = 0;
  String toptitle = '';

  AddonModel(
      {this.optid,
      this.optname,
      this.optcode: '',
      this.toptitle: '',
      this.addprice: 0});
  AddonModel.fromJson(Map<String, dynamic> json) {
    optid = int.parse(json['optid'].toString());
    optname = json['optname'];
    optcode = json['optcode'];
    addprice = 0;
    if (json['addprice'] != null && json['addprice'] != '') {
      addprice = double.parse(json['addprice'].toString());
    }
    toptitle = json['toptitle'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['optid'] = this.optid;
    data['optname'] = this.optname;
    data['optcode'] = this.optcode;
    data['addprice'] = this.addprice;
    data['toptitle'] = this.toptitle;
    return data;
  }
}
