class OrderHead {
  String olid;
  String mbid;
  String orderNo;
  String orderDate;
  String strOrderDate;
  String sortOrderDate;
  String contactTo;
  String contactAddress;
  String contactPhone;
  String bookTime;
  String distiance;
  String lat;
  String lng;
  String vatRate;
  String ttlAmount;
  String ttlDiscount;
  String ttlFree;
  String ttlLogist;
  String ttlVatAmount;
  String ttlNetAmount;
  String ttlGrsAmount;
  String riderid;
  String status;
  String riderStatus;
  String statusOrder;
  String statusRider;
  String createdDT;

  OrderHead(
      {this.olid,
      this.mbid,
      this.orderNo,
      this.orderDate,
      this.strOrderDate,
      this.sortOrderDate,
      this.contactTo,
      this.contactAddress,
      this.contactPhone,
      this.bookTime,
      this.distiance,
      this.lat,
      this.lng,
      this.vatRate,
      this.ttlAmount,
      this.ttlDiscount,
      this.ttlFree,
      this.ttlLogist,
      this.ttlVatAmount,
      this.ttlNetAmount,
      this.ttlGrsAmount,
      this.riderid,
      this.status,
      this.riderStatus,
      this.statusOrder,
      this.statusRider,
      this.createdDT});

  OrderHead.fromJson(Map<String, dynamic> json) {
    olid = json['olid'];
    mbid = json['mbid'];
    orderNo = json['OrderNo'];
    orderDate = json['OrderDate'];
    strOrderDate = json['strOrderDate'];
    sortOrderDate = json['sortOrderDate'];
    contactTo = json['contactTo'];
    contactAddress = json['contactAddress'];
    contactPhone = json['contactPhone'];
    bookTime = json['bookTime'];
    distiance = json['distiance'];
    lat = json['lat'];
    lng = json['lng'];
    vatRate = json['vatRate'];
    ttlAmount = json['ttlAmount'];
    ttlDiscount = json['ttlDiscount'];
    ttlFree = json['ttlFree'];
    ttlLogist = json['ttlLogist'];
    ttlVatAmount = json['ttlVatAmount'];
    ttlNetAmount = json['ttlNetAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];
    riderid = json['riderid'];
    status = json['Status'];
    riderStatus = json['riderStatus'];
    statusOrder = json['StatusOrder'];
    statusRider = json['StatusRider'];
    createdDT = json['createdDT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['olid'] = this.olid;
    data['mbid'] = this.mbid;
    data['OrderNo'] = this.orderNo;
    data['OrderDate'] = this.orderDate;
    data['strOrderDate'] = this.strOrderDate;
    data['sortOrderDate'] = this.sortOrderDate;
    data['contactTo'] = this.contactTo;
    data['contactAddress'] = this.contactAddress;
    data['contactPhone'] = this.contactPhone;
    data['bookTime'] = this.bookTime;
    data['distiance'] = this.distiance;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['vatRate'] = this.vatRate;
    data['ttlAmount'] = this.ttlAmount;
    data['ttlDiscount'] = this.ttlDiscount;
    data['ttlFree'] = this.ttlFree;
    data['ttlLogist'] = this.ttlLogist;
    data['ttlVatAmount'] = this.ttlVatAmount;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['riderid'] = this.riderid;
    data['Status'] = this.status;
    data['riderStatus'] = this.riderStatus;
    data['StatusOrder'] = this.statusOrder;
    data['StatusRider'] = this.statusRider;
    data['createdDT'] = this.createdDT;
    return data;
  }
}
