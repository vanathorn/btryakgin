class RiderOrderModel {
  String seq = '';
  String olid = '';
  String orderNo = '';
  double ttlNetAmount = 0;
  double ttlGrsAmount = 0;
  double ttlitem = 0;
  String attlat = '';
  String attlng = '';
  String distiance = '';
  String booktime = '';

  RiderOrderModel(
      this.seq,
      this.olid,
      this.orderNo,
      this.ttlNetAmount,
      this.ttlGrsAmount,
      this.attlat,
      this.attlng,
      this.distiance,
      this.booktime,
      {String ttlitem: '0'}
  );
  RiderOrderModel.fromJson(Map<String, dynamic> json) {
    seq = json['seq'];
    olid = json['olid'];
    orderNo = json['orderNo'];
    if (json['ttlitem'] != null && json['ttlitem'] != '') {
      ttlitem = double.parse(json['ttlitem']);
    } else {
      ttlitem = 0.0;
    }
    if (json['ttlNetAmount'] != null && json['ttlNetAmount'] != '') {
      ttlNetAmount = double.parse(json['ttlNetAmount']);
    } else {
      ttlNetAmount = 0.0;
    }
    if (json['ttlGrsAmount'] != null && json['ttlGrsAmount'] != '') {
      ttlGrsAmount = double.parse(json['ttlGrsAmount']);
    } else {
      ttlGrsAmount = 0.0;
    }
    attlat = json['attlat'];
    attlng = json['attlng'];
    distiance = json['distiance'];
    booktime = json['booktime'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['seq'] = this.seq;
    data['olid'] = this.olid;
    data['orderNo'] = this.orderNo;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['ttlitem'] = this.ttlitem;
    data['attlat'] = this.attlat;
    data['attlng'] = this.attlng;
    data['distiance'] = this.distiance;
    data['booktime'] = this.booktime;
    return data;
  }
}
