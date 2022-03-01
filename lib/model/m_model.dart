class MModel {
  String listM;

  MModel({this.listM});

  MModel.fromJson(Map<String, dynamic> json) {
    listM = json['mbtlist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mbtlist'] = this.listM;
    return data;
  }
}
