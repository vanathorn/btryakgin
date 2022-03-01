//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
//import 'package:btryakgin/screen/menu_screen.dart';
import 'package:btryakgin/state/food_state.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/view/shopmenu_view.dart';
import 'package:btryakgin/view/shopmenu_view_imp.dart';
import 'package:get/get.dart';

class ShopHomeDetail extends StatefulWidget {
  final FoodStateController foodStateController = Get.find();
  final ShopMenuView viewModel = ShopMenuViewImp();
  final ZoomDrawerController zoomDrawerController;
  ShopHomeDetail(this.zoomDrawerController);

  @override
  _ShopHomeDetailState createState() => _ShopHomeDetailState();
}

class _ShopHomeDetailState extends State<ShopHomeDetail> {
  ZoomDrawerController get drawerZoomController => null;
  String shopName = 'Shop Name';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: MyStyle().primarycolor,
            title: MyStyle().txtTH(
                shopName == null ? '' : 'รายละเอียดร้าน $shopName',
                Colors.white),
            elevation: 10,
            iconTheme: IconThemeData(color: Colors.black),
            leading: InkWell(
                child: Icon(Icons.view_headline_outlined),
                onTap: () {
                  //print('shop_home_detail *** Click ***');
                  ZoomDrawerController().toggle();
                })),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                // child: MostPopularWidget(
                //   viewModel: viewNodel,
                //   foodStateController:FoodStateController
                // )
                child: myWidget1(),
              ),
              Expanded(
                flex: 2,
                // child: BestDealsWidget(
                //   viewModel: viewNodel,
                //   foodStateController:FoodStateController
                // )
                child: myWidget2(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget myWidget1() {
    return Container(
        child: MyStyle().titleCenterTH(context, 'myWidget1', 22, Colors.red));
  }

  Widget myWidget2() {
    return Container(
        child: MyStyle().titleCenterTH(context, 'myWidget2', 22, Colors.red));
  }
}
