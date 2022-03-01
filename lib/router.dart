import 'package:flutter/material.dart';
import 'package:btryakgin/screen/SingUp.dart';
import 'package:btryakgin/screen/home.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (BuildContext context) => Home(),
  '/signup': (BuildContext context) => SignUp(),
};
