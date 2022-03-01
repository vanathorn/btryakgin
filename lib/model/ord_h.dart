class OrdHModel {
  String restaurantId;
  String ccode;
  String shopName;
  String mbid;
  String mbname;
  String orderNo;
  String strOrderDate;
  String status;
  String riderStatus;
  String vatRate;
  String ttlAmount;
  String ttlDiscount;
  String ttlFree;
  String ttlLogist;
  String ttlVatAmount;
  String ttlNetAmount;
  String ttlGrsAmount;

  OrdHModel(
      {this.restaurantId,
      this.ccode,
      this.shopName,
      this.mbid,
      this.mbname,
      this.orderNo,
      this.strOrderDate,
      this.status,
      this.riderStatus,
      this.vatRate,
      this.ttlAmount,
      this.ttlDiscount,
      this.ttlFree,
      this.ttlLogist,
      this.ttlVatAmount,
      this.ttlNetAmount,
      this.ttlGrsAmount});

  OrdHModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    ccode = json['ccode'];
    shopName = json['shopName'];
    mbid = json['mbid'];
    mbname = json['mbname'];
    orderNo = json['OrderNo'];
    strOrderDate = json['strOrderDate'];
    status = json['Status'];
    riderStatus = json['riderStatus'];
    vatRate = json['vatRate'];
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
    data['ccode'] = this.ccode;
    data['shopName'] = this.shopName;
    data['mbid'] = this.mbid;
    data['mbname'] = this.mbname;
    data['OrderNo'] = this.orderNo;
    data['strOrderDate'] = this.strOrderDate;
    data['Status'] = this.status;
    data['riderStatus'] = this.riderStatus;
    data['vatRate'] = this.vatRate;
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
