import 'package:yakgin/model/addon_model.dart';
import 'package:yakgin/model/toppingb_model.dart';
import 'package:yakgin/model/toppingc_model.dart';

class FoodModel {
  String ccode, description = '', id = '', name = '', image = '';
  double price = 0, priceSp = 0, favorite = 0, manfavor = 0, addprice = 0;
  int quantity = 0, quantitySp = 0;
  String topaid = '', topbid = '', topcid = '', topdid = '';
  String flagSp = '', auto = '', uname = '';
  double currqty = 0, reqty = 0, balqty = 0;

  List<ToppingBModel> toppingB = List<ToppingBModel>.empty(growable: true);
  List<ToppingCModel> toppingC = List<ToppingCModel>.empty(growable: true);
  List<AddonModel> addon = List<AddonModel>.empty(growable: true);

  FoodModel(
      {this.ccode,
      this.description,
      this.id,
      this.name,
      this.image,
      this.price,
      this.priceSp,
      this.toppingB,
      this.toppingC,
      this.addon,
      this.quantity,
      this.quantitySp,
      this.favorite,
      this.manfavor,
      this.topbid,
      this.topcid,
      this.topdid,
      this.addprice,
      this.flagSp,
      this.auto,
      this.currqty,
      this.balqty,
      this.reqty,
      this.uname});

  FoodModel.fromJson(Map<String, dynamic> json) {
    ccode = json['ccode'];
    description = json['idescription'];
    id = json['iid'];
    name = json['iname'];
    image = json['foodpict'];
    price = 0;
    priceSp = 0;
    quantity = 0;
    quantitySp = 0;
    favorite = 0;
    manfavor = 0;
    topbid = '';
    topcid = '';
    topdid = '';
    addprice = 0;
    flagSp = '';
    auto = '';
    if (json['currqty'] != null && json['currqty'] != '') {
      currqty = double.parse(json['currqty'].toString());
      balqty = currqty;
      reqty = currqty;
    }
    //-------------------------------------------------------
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    }
    if (json['priceSp'] != null && json['priceSp'] != '') {
      priceSp = double.parse(json['priceSp'].toString());
    }
    //-----------------------------------------------------
    if (json['toppingB'] != null) {
      toppingB = List<ToppingBModel>.empty(growable: true);
      json['toppingB'].forEach((v) {
        toppingB.add(ToppingBModel.fromJson(v));
      });
    }
    if (json['toppingC'] != null) {
      toppingC = List<ToppingCModel>.empty(growable: true);
      json['toppingC'].forEach((v) {
        toppingC.add(ToppingCModel.fromJson(v));
      });
    }
    if (json['addon'] != null) {
      addon = List<AddonModel>.empty(growable: true);
      json['addon'].forEach((v) {
        addon.add(AddonModel.fromJson(v));
      });
    }
    if (json['favorite'] != null && json['favorite'] != '') {
      favorite = double.parse(json['favorite'].toString());
    }
    if (json['manfavor'] != null && json['manfavor'] != '') {
      manfavor = double.parse(json['manfavor'].toString());
    }
    //-----------------------------------------------------
    topbid = json['topbid'];
    topcid = json['topcid'];
    topdid = json['topdid'];
    if (json['addprice'] != null) {
      addprice = double.parse(json['addprice'].toString());
    }
    flagSp = json['flagSp'];
    if (json['auto'] != null) {
      auto = json['auto'];
    }
    uname = json['uname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ccode'] = this.ccode;
    data['idescription'] = this.description;
    data['iid'] = this.id;
    data['iname'] = this.name;
    data['foodpict'] = this.image;
    data['price'] = this.price;
    data['priceSp'] = this.priceSp;
    data['toppingB'] = this.toppingB.map((e) => e.toJson()).toList();
    data['toppingC'] = this.toppingC.map((e) => e.toJson()).toList();
    data['addon'] = this.addon.map((e) => e.toJson()).toList();
    data['quantity'] = this.quantity;
    data['quantitySp'] = this.quantitySp;
    data['favorite'] = this.favorite;
    data['manfavor'] = this.manfavor;
    data['topbid'] = this.topbid;
    data['topcid'] = this.topcid;
    data['topdid'] = this.topdid;
    data['addprice'] = this.addprice;
    data['flagSp'] = this.flagSp;
    data['auto'] = this.auto;
    data['currqty'] = this.currqty;
    data['balqty'] = this.balqty;
    data['reqty'] = this.reqty;
    data['uname'] = this.uname;
    return data;
  }
}
