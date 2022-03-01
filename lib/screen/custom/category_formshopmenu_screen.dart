import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/category_model.dart';
import 'package:btryakgin/model/shoprest_model.dart';
import 'package:btryakgin/screen/custom/advice_food_screen.dart';
import 'package:btryakgin/screen/custom/user_rest_food.dart';
import 'package:btryakgin/utility/my_calculate.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/view/category_view_imp.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class CategoryFormshopMenuScreen extends StatefulWidget {
  final ShopRestModel restModel;
  CategoryFormshopMenuScreen({Key key, this.restModel}) : super(key: key);
  @override
  _CategoryFormshopMenuScreenState createState() =>
      _CategoryFormshopMenuScreenState();
}

class _CategoryFormshopMenuScreenState
    extends State<CategoryFormshopMenuScreen> {
  ShopRestModel restModel;
  String strConn, ccode, webPath;
  double screen, lat1, lng1, latShop, lngShop, distance;
  String strDistance;
  Location location = Location();
  final int startLogist = 30;
  int logistCost;
  final viewModel = CategoryViewImp(); // CategoryViewImp();
  List<CategoryModel> categoryModels =
      List<CategoryModel>.empty(growable: true);
  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    ccode = restModel.ccode;
    strConn = restModel
        .strconn; //'Data Source=10.1.1.100, 49728\\SQLEXPRESS; connection timeout = 150; Initial Catalog=dbFood4U; User ID=usrf4u; Password=F4uweb2612'; //restModel.strconn;
    webPath = restModel.webpath; //'Food4U'; //restModel.webpath;
    findLat1Lng1();
  }

  Future<Null> findLat1Lng1() async {
    LocationData locationData = await MyCalculate().findLocationData();
    setState(() {
      lat1 = locationData.latitude;
      lng1 = locationData.longitude;
      latShop = double.parse(restModel.lat);
      lngShop = double.parse(restModel.lng);
      distance = MyCalculate().calculateDistance(lat1, lng1, latShop, lngShop);
      var myFmt = NumberFormat('##0.0#', 'en_US');
      strDistance = myFmt.format(distance);
      logistCost = MyCalculate().calculateLogistic(distance, startLogist);
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } catch (ex) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            child: Column(children: <Widget>[
      Row(
        children: [
          Container(
            width: screen * 0.34,
            child: ListTile(
                leading:
                    Icon(Icons.directions_bike, color: MyStyle().primarycolor),
                title: MyStyle()
                    .txtbodyTH(distance == null ? '' : '$strDistance กม.')),
          ),
          Container(
              width: screen * 0.34,
              child: ListTile(
                  leading: Icon(Icons.transfer_within_a_station,
                      color: MyStyle().primarycolor),
                  title: MyStyle()
                      .txtbodyTH(logistCost == null ? '' : '$logistCost บาท'))),
          shopLocation(restModel),
          Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 5.0),
            child: adviceFood(restModel),
          ),
        ],
      ),
      Expanded(child: MyStyle().showProgress()),
    ])));
  }

  FloatingActionButton shopLocation(ShopRestModel restModel) {
    return FloatingActionButton(
      //backgroundColor: Colors.greenAccent[700],
      onPressed: () {
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => UerRestFood(
                  restModel: restModel,
                ));
        Navigator.push(context, route);
      },
      child: Icon(Icons.location_pin),
    );
  }

  FloatingActionButton adviceFood(ShopRestModel restModel) {
    return FloatingActionButton(
      backgroundColor: Colors.orangeAccent[700],
      onPressed: () {
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => AdviceFoodScreen(restModel: restModel));
        Navigator.push(context, route);
      },
      child: Icon(Icons.thumb_up),
    );
  }

  Widget showCategory() {
    return Container(
        child: FutureBuilder(
            future: viewModel.displayCategoryByRestaurantById(ccode),
            builder: (context, snapshot) {
              return CarouselSlider(
                  items: categoryModels
                      .map((e) => Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(e.name) //cardPhoto(e),
                                  );
                            },
                          ))
                      .toList(),
                  options: CarouselOptions(
                      autoPlay: true,
                      autoPlayAnimationDuration: Duration(seconds: 3),
                      autoPlayCurve: Curves.easeIn,
                      height: double.infinity));
            }));
  }
}
