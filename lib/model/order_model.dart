import 'package:yakgin/model/br_item_model.dart';
import 'package:yakgin/model/order_detail_model.dart';

class OrderModel {
  String mbordid;
  String restaurantId;
  String shopName;
  String ccode; //ccode of Shop
  String mbid;
  String mbcode;
  String mbname;
  String mbmobile;
  String contactphone;
  String olid;
  String orderNo;
  String strOrderDate;
  String ordTime;
  String odStatus;
  String rdStatus;
  int stepIn;
  String ridercode;
  String ridername;
  String riderpict;
  String mbpict;
  String statusOrder;
  String statusRider;
  String vatRate;
  String ttlitem;
  String ttlAmount;
  String ttlDiscount;
  String ttlFree;
  String ttlLogist;
  String ttlVatAmount;
  String ttlNetAmount;
  String ttlGrsAmount;
  String detailList;
  String britemList;
  List<OrdDetailModel> orddtl = List<OrdDetailModel>.empty(growable: true);
  List<BrItemModel> brdtl = List<BrItemModel>.empty(growable: true);

  OrderModel(
      {this.mbordid,
      this.restaurantId,
      this.shopName,
      this.ccode,
      this.mbid,
      this.mbcode,
      this.mbname,
      this.mbmobile,
      this.contactphone,
      this.olid,
      this.orderNo,
      this.strOrderDate,
      this.ordTime,
      this.odStatus,
      this.rdStatus,
      this.stepIn,
      this.ridercode,
      this.ridername,
      this.riderpict,
      this.mbpict,
      this.statusOrder,
      this.statusRider,
      this.vatRate,
      this.ttlitem,
      this.ttlAmount,
      this.ttlDiscount,
      this.ttlFree,
      this.ttlLogist,
      this.ttlVatAmount,
      this.ttlNetAmount,
      this.ttlGrsAmount,
      this.detailList,
      this.britemList,
      this.orddtl,
      this.brdtl});

  OrderModel.fromJson(Map<String, dynamic> json) {
    mbordid = json['mbordid'];
    restaurantId = json['restaurantId'];
    shopName = json['shopName'];
    ccode = json['ccode'];
    mbid = json['mbid'];
    if (json['mbcode'] != null) {
      mbcode = json['mbcode'];
    }
    mbname = json['mbname'];
    mbmobile = json['mbmobile'];
    contactphone = json['contactphone'];
    olid = json['olid'];
    orderNo = json['OrderNo'];
    strOrderDate = json['strOrderDate'];
    ordTime = json['ordTime'];
    odStatus = json['odStatus'];
    rdStatus = json['rdStatus'];
    stepIn = int.parse(json['stepIn']);
    if (json['ridercode'] != null) {
      ridercode = json['ridercode'];
    } else {
      ridercode = '';
    }
    if (json['ridername'] != null) {
      ridername = json['ridername'];
    } else {
      ridername = '';
    }
    if (json['riderpict'] != null) {
      riderpict = json['riderpict'];
    } else {
      riderpict = 'userlogo.png';
    }
    if (json['mbpict'] != null) {
      mbpict = json['mbpict'];
    } else {
      mbpict = 'userlogo.png';
    }
    statusOrder = json['statusOrder'];
    statusRider = json['statusRider'];
    vatRate = json['vatRate'];
    ttlitem = '0';
    if (json['ttlitem'] != null && json['ttlitem'] != '') {
      ttlitem = json['ttlitem'];
    }
    ttlAmount = json['ttlAmount'];
    ttlDiscount = json['ttlDiscount'];
    ttlFree = json['ttlFree'];
    ttlLogist = json['ttlLogist'];
    ttlVatAmount = json['ttlVatAmount'];
    ttlNetAmount = json['ttlNetAmount'];
    ttlGrsAmount = json['ttlGrsAmount'];
    detailList = json['detailList'];
    britemList = json['britemList'];
    if (json['orddtl'] != null) {
      orddtl = List<OrdDetailModel>.empty(growable: true);
      json['orddtl'].forEach((v) {
        orddtl.add(OrdDetailModel.fromJson(v));
      });
    }
    if (json['brdtl'] != null) {
      brdtl = List<BrItemModel>.empty(growable: true);
      json['brdtl'].forEach((v) {
        brdtl.add(BrItemModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mbordid'] = this.mbordid;
    data['restaurantId'] = this.restaurantId;
    data['shopName'] = this.shopName;
    data['ccode'] = this.ccode;
    data['mbid'] = this.mbid;
    data['mbname'] = this.mbname;
    data['mbmobile'] = this.mbmobile;
    data['contactphone'] = this.contactphone;
    data['olid'] = this.olid;
    data['OrderNo'] = this.orderNo;
    data['strOrderDate'] = this.strOrderDate;
    data['ordTime'] = this.ordTime;
    data['odStatus'] = this.odStatus;
    data['rdStatus'] = this.rdStatus;
    data['stepIn'] = this.stepIn;
    data['statusOrder'] = this.statusOrder;
    data['statusRider'] = this.statusRider;
    data['vatRate'] = this.vatRate;
    data['ttlitem'] = this.ttlitem;
    data['ttlAmount'] = this.ttlAmount;
    data['ttlDiscount'] = this.ttlDiscount;
    data['ttlFree'] = this.ttlFree;
    data['ttlLogist'] = this.ttlLogist;
    data['ttlVatAmount'] = this.ttlVatAmount;
    data['ttlNetAmount'] = this.ttlNetAmount;
    data['ttlGrsAmount'] = this.ttlGrsAmount;
    data['detailList'] = this.detailList;
    data['britemList'] = this.britemList;
    data['orddtl'] = this.orddtl.map((e) => e.toJson()).toList();
    data['brdtl'] = this.brdtl.map((e) => e.toJson()).toList();
    return data;
  }
}
