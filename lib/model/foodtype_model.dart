class FoodTypeModel {
  String gcatname='';
  String itid='';
  String itcode='';
  String itname='';
  String itdescription='';
  String ftypepict='';
 
  FoodTypeModel({
    this.gcatname,
    this.itid,
    this.itcode,
    this.itname,
    this.itdescription,
    this.ftypepict}
  );

  FoodTypeModel.fromJson(Map<String, dynamic> json) {
    gcatname = json['gcatname'];
    itid = json['itid'];
    itcode = json['itcode'];
    itname = json['itname'];
    itdescription = json['itdescription'];
    ftypepict = json['ftypepict'];    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gcatname'] = this.gcatname;
    data['itid'] = this.itid;
    data['itcode'] = this.itcode;
    data['itname'] = this.itname;
    data['itdescription'] = this.itdescription;
    data['ftypepict'] = this.ftypepict;  
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'gcatname': gcatname,
      'itid': itid,
      'itcode': itcode,
      'itname': itname,
      'itdescription': itdescription,
      'ftypepict': ftypepict,
    };
  }
  
}
