import 'package:flutter/material.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/screen/custom/advice_food_screen.dart';
import 'package:yakgin/screen/custom/category_screen.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/widget/shop/about_shop.dart';
import 'package:yakgin/widget/appbar_withcart.dart';
import 'package:get/get.dart';

class UerRestFood extends StatefulWidget {
  final ShopRestModel restModel;
  UerRestFood({Key key, this.restModel}) : super(key: key);
  @override
  _UerRestFoodState createState() => _UerRestFoodState();
}

class _UerRestFoodState extends State<UerRestFood> {
  final MainStateController mainStateController = Get.find(); 
  ShopRestModel restModel;
  List<Widget> listWidgets;
  int indexPage = 0;

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    listWidgets = [
      AboutShop(restModel: restModel),
      AdviceFoodScreen(restModel: restModel),
      CategoryScreen(restModel: restModel)
    ];
  }

  BottomNavigationBarItem aboutShopNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.location_pin),
      label: ('ที่อยู่ร้านค้า'),
    );
  }

  BottomNavigationBarItem adviceMenuNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.thumb_up),
      label: ('เมนูแนะนำ'),
    );
  }

  BottomNavigationBarItem showMenuFoodNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu),
      label: ('เมนูอาหาร'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithCartButton(
        title: 'ร้าน ${mainStateController.selectedRestaurant.value.thainame}',
        subtitle: '',
      ),
      body: listWidgets[indexPage],
      bottomNavigationBar: showBottonNavBar(),
    );
  }

  BottomNavigationBar showBottonNavBar() => BottomNavigationBar(
          backgroundColor: Colors.amber[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(.60),
          selectedFontSize: 18,
          unselectedFontSize: 15,
          currentIndex: indexPage,
          onTap: (value) {
            setState(() {
              indexPage = value;
            });
          },
          items: <BottomNavigationBarItem>[
            aboutShopNav(),
            adviceMenuNav(),
            showMenuFoodNav(),
          ]);
}
