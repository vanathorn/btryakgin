class MbtModel {
  int mbtid=0;
  String mbtcode='';
  String mbtname='';
  String mbtlist='';

  MbtModel(this.mbtid, this.mbtcode, this.mbtname);
  MbtModel.fromJson(Map<String, dynamic> json){
    mbtid = int.parse(json['mbtid'].toString());
    mbtcode = json['mbtcode'];
    mbtname = json['mbtname'];
    mbtlist = json['mbtlist'];
  }

  Map<String, dynamic> toJson() {
    final data =  Map<String, dynamic>();
    data['mbtid'] = this.mbtid;
    data['mbtcode'] = this.mbtcode;
    data['mbtname'] = this.mbtname;
    data['mbtlist'] = this.mbtlist;
    return data;
  }

}