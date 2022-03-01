class ProdSlideModel {
  String iid='';
  String iname='';
  String slidephoto='';

  ProdSlideModel({
      this.iid,
      this.iname,
      this.slidephoto}
  );

  ProdSlideModel.fromJson(Map<String, dynamic> json) {
    iid = json['iid'];
    iname = json['iname'];
    slidephoto = json['slidephoto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['iid'] = this.iid;
    data['iname'] = this.iname;
    data['slidephoto'] = this.slidephoto;
    return data;
  }
}