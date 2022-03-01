class SumValue {
  double ttlAmount;
  double ttlDiscount;
  double ttlFree;
  double ttlLogist;
  double ttlNetAmount;
  double ttlVatAmount;
  double ttlGrsAmount;
  double vatRate;
  double distiance;

  SumValue(
      {this.ttlAmount,
      this.ttlDiscount,
      this.ttlFree,
      this.ttlLogist,
      this.ttlNetAmount,
      this.ttlVatAmount,
      this.ttlGrsAmount,
      this.vatRate,
      this.distiance});

  SumValue.fromJson(Map<String, dynamic> json) {
    ttlAmount = json['ttlAmount'];
    ttlDiscount = json['ttlDiscount'];
    ttlFree = json['ttlFree'];
    ttlLogist = json['ttlLogist'];
    ttlNetAmount = json['ttlNetAmount'];
    ttlVatAmount = json['ttlVatAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];
    vatRate = json['vatRate'];    
    distiance = json['distiance'];    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ttlAmount'] = this.ttlAmount;
    data['ttlDiscount'] = this.ttlDiscount;
    data['ttlFree'] = this.ttlFree;
    data['ttlLogist'] = this.ttlLogist;   
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlVatAmount'] = this.ttlVatAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['vatRate'] = this.vatRate;
    data['distiance'] = this.distiance;  
    return data;
  }
}
