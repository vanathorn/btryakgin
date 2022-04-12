import 'dart:convert';
import 'package:auto_animated/auto_animated.dart';
import 'package:dio/dio.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/screen/custom/food_bytype.dart';
import 'package:yakgin/state/food_state.dart';
import 'package:yakgin/widget/shop/edit_foodtype.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakgin/model/foodtype_model.dart';
import 'package:yakgin/model/shop_model.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/view/food_view_imp.dart';
import 'package:yakgin/widget/commonwidget.dart';

class ShopFoodMenu extends StatefulWidget {
  @override
  _ShopFoodMenuState createState() => _ShopFoodMenuState();
}

class _ShopFoodMenuState extends State<ShopFoodMenu> {
  String strConn, webPath;
  String loginName, loginMobile, loginccode;
  double screen;
  ShopModel shopModel;
  String nameofShop;
  bool loadding = true;
  bool havemenu = true;
  List<FoodTypeModel> foodTypeModels =
      List<FoodTypeModel>.empty(growable: true);
  final viewModels = FoodViewImp();
  final foodStateController = Get.put(FoodStateController());

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      //loginMobile = prefer.getString('pmobile');
      loginccode = prefer.getString('pccode');
      strConn = prefer.getString('pstrconn');
      webPath = prefer.getString('pwebpath');
      if (strConn != null) {
        readShopName();
        readFoodTypeMenu();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        loadding ? MyStyle().showProgress() : showContent(),
      ],
    );
  }

  Future<Null> readShopName() async {
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/shopMenu.aspx?ccode=' +
            loginccode;
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          shopModel = ShopModel.fromJson(map);
          nameofShop = shopModel.thainame;
        });
      }
    });
  }

  Future<Null> readFoodTypeMenu() async {
    if (foodTypeModels.length != 0) {
      foodTypeModels.clear();
    }
    String url =
        '${MyConstant().apipath}.${MyConstant().domain}/foodType.aspx?ccode=' +
            loginccode +
            '&strCondtion=&strOrder=';
    await Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          FoodTypeModel fModels = FoodTypeModel.fromJson(map);
          setState(() {
            foodTypeModels.add(fModels);
          });
        }
      } else {
        setState(() {
          havemenu = false;
        });
      }
    });
  }

  Widget showContent() {
    return havemenu
        ? showListFoodType()
        : MyStyle()
            .titleCenterTH(context, 'ไม่มีรายการประเภทสินค้า', 22, Colors.red);
  }

  Widget xxxshowListFood() => ListView.builder(
      itemCount: foodTypeModels.length,
      itemBuilder: (context, index) => Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                width: screen * 0.6,
                height: screen * 0.6,
                child: Image.network(
                    '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/foodtype/${foodTypeModels[index].ftypepict}'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                width: screen * 0.3,
                height: screen * 0.6,
                child: MyStyle().titleCenterTH(context,
                    '${foodTypeModels[index].itname}', 18, Colors.black),
              ),
            ],
          ));

  Widget showListFoodType() {
    return Container(
        width: screen,
        child: LiveList(
          showItemInterval: Duration(milliseconds: 150),
          showItemDuration: Duration(milliseconds: 350),
          reAnimateOnVisibility: true,
          scrollDirection: Axis.vertical,
          itemCount: foodTypeModels.length,
          itemBuilder: animationItemBuilder((index) => InkWell(
                onTap: () {
                  foodStateController.selectedFoodType.value =
                      foodTypeModels[index];
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => FoodByType(),
                  );
                  Navigator.push(context, route);
                  //Get.to(()=> FoodByType());
                },
                child: Row(
                  children: [
                    //mainAxisAlignment: MainAxisAlignment.center,
                    Container(
                      //margin: EdgeInsets.all(10.0),
                      margin: const EdgeInsets.only(top: 8, left: 3),
                      width: 170, //double.infinity,
                      height: 170,
                      //height: MediaQuery.of(context).size.height / 2.5 * 1,R
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(
                              '${MyConstant().domain}/$webPath/${MyConstant().imagepath}/$loginccode/foodtype/${foodTypeModels[index].ftypepict}'),
                          //MyStyle().titleCenterTH(context,'${foodTypeModels[index].itname}', 28, Colors.black)
                        ],
                      ),
                    ),
                    Container(
                      decoration: new BoxDecoration(color: Colors.grey[100]),
                      width: (screen - 175.0),
                      height: 170,
                      child: SingleChildScrollView(
                        //จะได้สามารถ scroll ได้
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyStyle().txtstyle(
                                '${foodTypeModels[index].itname}',
                                Colors.black,
                                16),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: MyStyle().txtstyle(
                                  '${foodTypeModels[index].itdescription}',
                                  Colors.black54,
                                  12.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  onPressed: () =>
                                      deleteFood(foodTypeModels[index]),
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.green, size: 48),
                                    onPressed: () {
                                      MaterialPageRoute route =
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditFoodType(
                                                    foodTypeModel:
                                                        foodTypeModels[index],
                                                  ));
                                      Navigator.push(context, route)
                                          .then((value) => readFoodTypeMenu());
                                    })
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ));
  }

  Future<Null> deleteFood(FoodTypeModel foodTypeModel) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle().txtstyle(
            'คุณต้องการลบ ${foodTypeModel.itname} ?', Colors.red, 16.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                      width: screen * 0.2,
                      height: 48,
                      // decoration: BoxDecoration(
                      //   color: Colors.redAccent[700],
                      //   border: Border.all(color: Colors.black, width: 1,)
                      // ),
                      child: MyStyle()
                          .titleCenter(context, 'ยกเลิก', 16.0, Colors.black))),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    String url = '';
                    await Dio().get(url).then((value) => readFoodTypeMenu());
                  },
                  child: Container(
                      width: screen * 0.25,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.redAccent[700],
                        //border: Border.all(color: Colors.white, width: 1,)
                      ),
                      child: MyStyle()
                          .titleCenter(context, 'ยืนยัน', 16.0, Colors.white))),
            ],
          )
        ],
      ),
    );
  }

  Widget photoWidget(String imageUrl) {
    return SizedBox(
        height: 250,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ));
  }
}
