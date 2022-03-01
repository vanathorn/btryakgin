import 'package:btryakgin/model/account_model.dart';
import 'package:btryakgin/model/addon_model.dart';
import 'package:btryakgin/model/size_model.dart';

class ShopRestModel {
  String restaurantId = '';
  String thainame = '';
  String branchname = '';
  String address = '';
  String phone = '';
  String lat = '';
  String lng = '';
  String shoppict = '';
  String banklist = '';
  String ccode = '';
  String strconn = '';
  String webpath = '';
  double price = 0;
  List<SizeModel> size = List<SizeModel>.empty(growable: true);
  List<AddonModel> addon = List<AddonModel>.empty(growable: true);
  List<AccountModel> account = List<AccountModel>.empty(growable: true);
  int cntord = 0;
  int cntnewm = 0;

  ShopRestModel(
      {this.restaurantId,
      this.thainame,
      this.branchname,
      this.address,
      this.phone,
      this.lat,
      this.lng,
      this.shoppict,
      this.banklist,
      this.ccode,
      this.strconn,
      this.webpath,
      this.price,
      this.size,
      this.addon,
      this.account,
      this.cntord,
      this.cntnewm});

  ShopRestModel.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurantId'];
    thainame = json['thainame'];
    branchname = json['branchname'];
    address = json['address'];
    phone = json['phone'];
    lat = json['lat'];
    lng = json['lng'];
    shoppict = json['shoppict'];
    banklist = json['banklist'];
    ccode = json['ccode'];
    strconn = json['strconn'];
    webpath = json['webpath'];

    if (json['cntord'] != null) {
      cntord = int.parse(json['cntord'].toString());
    }
    if (json['cntnewm'] != null) {
      cntnewm = int.parse(json['cntnewm'].toString());
    }
    if (json['price'] != null) {
      price = double.parse(json['price'].toString());
    }
    if (json['addon'] != null) {
      addon = List<AddonModel>.empty(growable: true);
      json['addon'].forEach((v) {
        addon.add(AddonModel.fromJson(v));
      });
    }
    if (json['size'] != null) {
      size = List<SizeModel>.empty(growable: true);
      json['size'].forEach((v) {
        size.add(SizeModel.fromJson(v));
      });
    }
    if (json['account'] != null) {
      account = List<AccountModel>.empty(growable: true);
      json['account'].forEach((v) {
        account.add(AccountModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['restaurantId'] = this.restaurantId;
    data['thainame'] = this.thainame;
    data['branchname'] = this.branchname;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['shoppict'] = this.shoppict;
    data['banklist'] = this.banklist;
    data['ccode'] = this.ccode;
    data['strconn'] = this.strconn;
    data['webpath'] = this.webpath;
    data['price'] = this.price;
    data['size'] = this.size.map((e) => e.toJson()).toList();
    data['addon'] = this.addon.map((e) => e.toJson()).toList();
    data['account'] = this.account.map((e) => e.toJson()).toList();
    data['cntord'] = this.cntord;
    data['cntnewm'] = this.cntnewm;
    return data;
  }
}
