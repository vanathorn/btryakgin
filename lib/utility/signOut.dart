//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/screen/home.dart';
import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/view/cart_vm/cart_view_model_imp.dart';
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
