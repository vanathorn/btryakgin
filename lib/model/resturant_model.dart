import 'package:btryakgin/model/shoprest_model.dart';

class ResturantModel {
  String key = '', name = '', image = '';
  List<ShopRestModel> shoprests = new List<ShopRestModel>.empty(growable: true);

  ResturantModel({this.name, this.image, this.shoprests});

  ResturantModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    shoprests = json['itcode'];
    if (json['shoprests'] != null) {
      shoprests = List<ShopRestModel>.empty(growable: true);
      json['shoprests'].forEach((v) {
        shoprests.add(ShopRestModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['image'] = this.image;
    data['shoprests'] = this.shoprests.map((e) => e.toJson()).toList();
    return data;
  }
}
