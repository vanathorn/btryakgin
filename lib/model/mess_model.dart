class MessModel {
  String mess='';

  MessModel(this.mess);
  MessModel.fromJson(Map<String, dynamic> json){
    mess = json['mess'];
  }

  Map<String, dynamic> toJson() {
    final data =  Map<String, dynamic>();
    data['mess'] = this.mess;   
    return data;
  }

}