//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/screen/menu/main_user.dart';
import 'package:yakgin/view/menu_vm/menu_viewmodel.dart';
import 'package:get/get.dart';

class MenuViewModelImp implements MenuViewModel {
  final BuildContext context;
  const MenuViewModelImp({Key key, this.context});

  @override
  void navigateScreen() {
    //Get.to(()=> MainUser());
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => MainUser(),
    );
    Navigator.push(context, route);
  }

  @override
  void backToRestaurantList() {
    Get.back(closeOverlays: true, canPop: false);
  }
}
