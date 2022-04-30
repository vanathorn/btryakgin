import 'package:flutter/material.dart';

class ReportModel {
  String seq;
  String name;
  String image;
  Widget widget;

  ReportModel({this.seq: '', this.name: '', this.image: '', this.widget});

  ReportModel.fromJson(Map<String, dynamic> json) {
    seq = json['seq'];
    name = json['name'];
    image = json['image'];
    widget = json['widget'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seq'] = this.seq;
    data['name'] = this.name;
    data['image'] = this.image;
    data['widget'] = this.widget;
    return data;
  }
}
