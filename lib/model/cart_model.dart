import 'package:yakgin/model/food_model.dart';

class CartModel extends FoodModel {
  String strKey = '';
  String topBid = '0', topCid = '0', addonid = '0';
  String nameB = '', nameC = '', straddon = '';
  int quantity = 0;
  int quantitySp = 0;
  String restaurantId = '';
  String shopName = '';
  String flagSp = '';
  double balqty = 0;

  CartModel(
      {strKey,
      ccode,
      id,
      name,
      image,
      price,
      priceSp,
      toppingB,
      toppingC,
      addon,
      description,
      quantity,
      quantitySp,
      topBid,
      topCid,
      addonid,
      nameB,
      nameC,
      straddon,
      shopName,
      this.restaurantId,
      flagSp,
      balqty
      })
      : super(
            ccode: ccode,
            id: id,
            name: name,
            image: image,
            price: price,
            priceSp: priceSp,
            toppingB: toppingB,
            toppingC: toppingC,
            addon: addon,
            description: description
            //ต้องระบุหรือเปล่า ? balqty:balqty
      );

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final strKey = json['strKey'];
    final food = FoodModel.fromJson(json);
    final quantity = json['quantity'];
    final quantitySp = json['quantitySp'];
    final restaurantId = json['restaurantId'];
    final topBid = json['topBid'];
    final topCid = json['topCid'];
    final addonid = json['addonid'];
    final nameB = json['nameB'];
    final nameC = json['nameC'];
    final straddon = json['straddon'];
    final shopName = json['shopName'];

    return CartModel(
        strKey: strKey,
        ccode: food.ccode,
        id: food.id,
        name: food.name,
        image: food.image,
        price: food.price,
        priceSp: food.priceSp,
        toppingB: food.toppingB,
        toppingC: food.toppingC,
        addon: food.addon,
        description: food.description,
        quantity: quantity,
        quantitySp: quantitySp,
        shopName: shopName,
        restaurantId: restaurantId,
        topBid: topBid,
        topCid: topCid,
        addonid: addonid,
        nameB: nameB,
        nameC: nameC,
        straddon: straddon,
        flagSp: food.flagSp,
        balqty:food.balqty
    );        
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['strKey'] = this.strKey;
    data['ccode'] = this.ccode;
    data['iid'] = this.id;
    data['iname'] = this.name;
    data['foodpict'] = this.image;
    data['price'] = this.price;
    data['priceSp'] = this.priceSp;
    data['toppingB'] = this.toppingB.map((e) => e.toJson()).toList();
    data['toppingC'] = this.toppingC.map((e) => e.toJson()).toList();
    data['addon'] = this.addon.map((e) => e.toJson()).toList();
    data['idescription'] = this.description;
    data['quantity'] = this.quantity;
    data['quantitySp'] = this.quantitySp;
    data['restaurantId'] = this.restaurantId;
    data['topBid'] = this.topBid;
    data['topCid'] = this.topCid;
    data['addonid'] = this.addonid;
    data['nameB'] = this.nameB;
    data['nameC'] = this.nameC;
    data['straddon'] = this.straddon;
    data['shopName'] = this.shopName;
    data['flagSp'] = this.flagSp;
    data['maxqty'] = this.balqty;
    return data;
  }
}
