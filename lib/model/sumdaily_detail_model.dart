class SumDailyDetailModel {
  String restaurantId;  
  String seq;
  String orderNo;
  String vatRate;
  String ttlitem;
  String ttlAmount;
  String ttlDiscount;
  String ttlFree;
  String ttlLogist;
  String ttlVatAmount;
  String ttlNetAmount;
  String ttlGrsAmount;

  SumDailyDetailModel(
      this.restaurantId,     
      this.seq,
      this.orderNo,
      { this.vatRate:'0.0',
        this.ttlitem:'0',
        this.ttlAmount:'0.0',
        this.ttlDiscount:'0.0',
        this.ttlFree:'0.0',
        this.ttlLogist:'0.0',
        this.ttlVatAmount:'0.0',
        this.ttlNetAmount:'0.0',
        this.ttlGrsAmount:'0.0'}
      );

  SumDailyDetailModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];    
    seq = json['seq'];
    orderNo = json['OrderNo'];
    vatRate = json['vatRate'];
    ttlitem = json['ttlitem'];
    ttlAmount = json['ttlAmount'];
    ttlDiscount = json['ttlDiscount'];
    ttlFree = json['ttlFree'];
    ttlLogist = json['ttlLogist'];
    ttlVatAmount = json['ttlVatAmount'];
    ttlNetAmount = json['ttlNetAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;    
    data['seq'] = this.seq;
    data['OrderNo'] = this.orderNo; 
    data['vatRate'] = this.vatRate;
    data['ttlitem'] = this.ttlitem;
    data['ttlAmount'] = this.ttlAmount;
    data['ttlDiscount'] = this.ttlDiscount;
    data['ttlFree'] = this.ttlFree;
    data['ttlLogist'] = this.ttlLogist;
    data['ttlVatAmount'] = this.ttlVatAmount;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    return data;
  }
}
