//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/screen/home.dart';
import 'package:yakgin/state/cart_state.dart';
import 'package:yakgin/view/cart_vm/cart_view_model_imp.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Null> signOut(BuildContext context) async {
  final CartStateController controller = Get.find();
  final CartViewModelImp cartViewModel = new CartViewModelImp();

  SharedPreferences prefer = await SharedPreferences.getInstance();
  prefer.clear();
  //exit(0);

  cartViewModel.resetCart(controller);

  MaterialPageRoute route = MaterialPageRoute(
    builder: (context) => Home(),
  );
  Navigator.pushAndRemoveUntil(context, route, (route) => false);
}
