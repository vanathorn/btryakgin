import 'package:flutter/material.dart';

class MenuModel {
  String chooseType;
  String menuName;
  String menuImage;
  Widget menuWidget;

  MenuModel(this.chooseType, this.menuName, this.menuImage, this.menuWidget);

  MenuModel.fromJson(Map<String, dynamic> json) {
    chooseType = json['chooseType'];
    menuName = json['menuName'];
    menuImage = json['menuImage'];
    menuWidget = json['menuWidget'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chooseType'] = this.chooseType;
    data['menuName'] = this.menuName;
    data['menuImage'] = this.menuImage;
    data['menuWidget'] = this.menuWidget;
    return data;
  }
}
