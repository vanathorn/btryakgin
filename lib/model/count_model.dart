class CountModel {
  String cnt='';

  CountModel(this.cnt);
  CountModel.fromJson(Map<String, dynamic> json){
    cnt = json['cnt'];
  }

  Map<String, dynamic> toJson() {
    final data =  Map<String, dynamic>();
    data['cnt'] = this.cnt;   
    return data;
  }

}