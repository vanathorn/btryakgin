class ToppingModel {
  String topptitle;
  String listB;
  String listC;
  String listD;
  String favorite;

  ToppingModel({this.listB, this.listC, this.listD});

  ToppingModel.fromJson(Map<String, dynamic> json) {
    topptitle = json['topptitle'];
    listB = json['listB'];
    listC = json['listC'];
    listD = json['listD'];
    favorite = json['favorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['topptitle'] = this..topptitle;
    data['listB'] = this.listB;
    data['listC'] = this.listC;
    data['listD'] = this.listD;
    data['favorite'] = this.favorite;
    return data;
  }
}
