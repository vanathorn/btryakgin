class SumDetailModel {
  String restaurantId;  
  String seq;
  String itid;
  String itname;
  String iid;
  String iname;
  String qty;
  String uname;

  SumDetailModel(
      this.restaurantId,     
      this.seq,
      { this.itid:'0',
        this.itname:'',
        this.iid:'0',
        this.iname:'',
        this.qty:'0',
        this.uname:''});

  SumDetailModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];    
    seq = json['seq'];
    itid = json['itid'];
    itname = json['itname'];
    iid = json['iid'];
    iname = json['iname'];
    qty = json['qty'];
    uname = json['uname'];  
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;    
    data['seq'] = this.seq;
    data['itid'] = this.itid; 
    data['itname'] = this.itname;
    data['iid'] = this.iid;
    data['iname'] = this.iname;
    data['qty'] = this.qty;
    data['uname'] = this.uname;
    return data;
  }
}
