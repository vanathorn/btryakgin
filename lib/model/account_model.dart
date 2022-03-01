class AccountModel {
  String ccode='';
  String bkid='';
  String bkcode='';
  String bkname='';
  String accno='';
  String accname='';


  AccountModel(this.ccode, this.bkid, this.bkcode, this.bkname, this.accno, this.accname);
  AccountModel.fromJson(Map<String, dynamic> json){
    ccode = json['ccode'];
    bkid = json['bkid']; 
    bkcode = json['bkcode'];    
    bkname = json['bkname']; 
    accno = json['accno']; 
    accname = json['accname'];    

  }

  Map<String, dynamic> toJson() {
    final data =  Map<String, dynamic>();
    data['ccode'] = this.ccode;   
    data['bkid'] = this.bkid;   
    data['bkcode'] = this.bkcode; 
    data['bkname'] = this.bkname; 
    data['accno'] = this.accno;   
    data['accname'] = this.accname; 
    return data;
  }

}