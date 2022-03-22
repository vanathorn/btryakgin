class DDLModel {
  int id;
  String txtvalue;

  DDLModel({this.id:0, this.txtvalue:''});

  DDLModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    txtvalue = json['txtvalue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['txtvalue'] = this.txtvalue;
    return data;
  }
}
