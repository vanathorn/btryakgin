import 'package:flutter/material.dart';
import 'package:yakgin/screen/SingUp.dart';
import 'package:yakgin/screen/home.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (BuildContext context) => Home(),
  '/signup': (BuildContext context) => SignUp(),
};
