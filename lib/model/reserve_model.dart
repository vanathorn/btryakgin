class ReserveModel {
  String olid='';
  String orderNo='';
  String riderId='';

  ReserveModel(
    this.olid,
    this.orderNo,
    this.riderId
  );
  ReserveModel.fromJson(Map<String, dynamic> json){
    olid = json['olid'];
    orderNo = json['orderNo']; 
    riderId = json['riderId']; 
  }

  Map<String, dynamic> toJson() {
    final data =  Map<String, dynamic>();
    data['olid'] = this.olid;   
    data['orderNo'] = this.orderNo;   
    data['riderId'] = this.riderId;   
    return data;
  }

}