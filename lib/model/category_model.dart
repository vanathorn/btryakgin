import 'package:yakgin/model/food_model.dart';

class CategoryModel {
  String key = '', name = '', image = '', ttlitem = '0';
  List<FoodModel> foods = new List<FoodModel>.empty(growable: true);
  CategoryModel({this.key, this.name, this.image, this.foods});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    key = json['itid'];
    name = json['itname'];
    image = json['ftypepict'];
    if (json['ttlitem'] != null) {
      ttlitem = json['ttlitem'];
    } else {
      ttlitem = '0';
    }
    if (json['foods'] != null) {
      foods = List<FoodModel>.empty(growable: true);
      json['foods'].forEach((v) {
        foods.add(FoodModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itid'] = this.key;
    data['itname'] = this.name;
    data['ftypepict'] = this.image;
    data['ttlitem'] = this.ttlitem;
    data['foods'] = this.foods.map((e) => e.toJson()).toList();
    return data;
  }
}
