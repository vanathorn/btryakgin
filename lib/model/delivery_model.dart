class DeliveryModel {
  String mbordid;
  String restaurantId;
  String shopName;
  String ccode;
  String olid;
  String orderNo;
  String odStatus;
  String rdStatus;
  String custName;
  String custAddress;
  String custPhone;
  double latCust;
  double lngCust;
  double latRider;
  double lngRider;
  String ttlNetAmount;
  String ttlGrsAmount;
  String bookTime;
  String distianceR;
  String riderId;
  //List<RiderOrderModel> orddtl = List<RiderOrderModel>.empty(growable: true);

  DeliveryModel({
    this.mbordid,
    this.restaurantId,
    this.shopName,
    this.ccode,
    this.olid,
    this.orderNo,
    this.odStatus,
    this.rdStatus,
    this.custName,
    this.custAddress,
    this.custPhone,
    this.latCust,
    this.lngCust,
    this.latRider,
    this.lngRider,
    this.ttlNetAmount,
    this.ttlGrsAmount,
    this.bookTime,
    this.distianceR,
    this.riderId,
    //this.orddtl
  });

  DeliveryModel.fromJson(Map<String, dynamic> json) {
    latCust = 0.0;
    lngCust = 0.0;
    latRider = 0.0;
    lngRider = 0.0;
    mbordid = json['mbordid'];
    restaurantId = json['restaurantId'];
    shopName = json['shopName'];
    ccode = json['ccode'];
    olid = json['olid'];
    orderNo = json['orderNo'];
    odStatus = json['odStatus'];
    rdStatus = json['rdStatus'];
    custName = json['custName'];
    custAddress = json['custAddress'];
    custPhone = json['custPhone'];
    if (json['latCust'] != null) {
      latCust = double.parse(json['latCust']);
    }
    if (json['lngCust'] != null) {
      lngCust = double.parse(json['lngCust']);
    }
    if (json['latRider'] != null) {
      latRider = double.parse(json['latRider']);
    }
    if (json['lngRider'] != null) {
      lngRider = double.parse(json['lngRider']);
    }
    ttlNetAmount = json['ttlNetAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];
    bookTime = json['bookTime'];
    distianceR = json['distianceR'];
    riderId = json['riderId'];
    /*
    if (json['orddtl'] != null) {
      orddtl = List<RiderOrderModel>.empty(growable: true);
      json['orddtl'].forEach((v) {
        orddtl.add(RiderOrderModel.fromJson(v));
      });
    }
    */
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mbordid'] = this.mbordid;
    data['restaurantId'] = this.restaurantId;
    data['shopName'] = this.shopName;
    data['ccode'] = this.ccode;
    data['olid'] = this.olid;
    data['orderNo'] = this.orderNo;
    data['odStatus'] = this.odStatus;
    data['rdStatus'] = this.rdStatus;
    data['custName'] = this.custName;
    data['custAddress'] = this.custAddress;
    data['custPhone'] = this.custPhone;
    data['latCust'] = this.latCust;
    data['lngCust'] = this.lngCust;
    data['latRider'] = this.latRider;
    data['lngRider'] = this.lngRider;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['bookTime'] = this.bookTime;
    data['distianceR'] = this.distianceR;
    data['riderId'] = this.riderId;
    // data['orddtl'] = this.orddtl.map((e) => e.toJson()).toList();
    return data;
  }
}
