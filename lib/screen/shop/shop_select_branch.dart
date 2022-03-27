import 'dart:convert';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/branch_model.dart';
import 'package:yakgin/screen/shop/shop_adjust_bal.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopSelectBranch extends StatefulWidget {
  @override
  _ShopSelectBranchState createState() => _ShopSelectBranchState();
}

class _ShopSelectBranchState extends State<ShopSelectBranch> {
  double screen;
  String ccode, loginName, strDistance;
  Location location = Location();
  bool loadding = true;
  bool havemenu = true;

  List<BranchModel> branchList = List<BranchModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    findShop();
  }

  Future<Null> findShop() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      ccode = prefer.getString('pccode');
      getBranch();
    });    
  }

  Future<Null> getBranch() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'shop/getBranch.aspx?ccode=$ccode&strCondtion=&strOrd=';

    branchList.clear();
    await Dio().get(url).then((value) {
      if (value.toString() != 'null' &&
          value.toString().indexOf('ข้อมูลไม่ถูกต้อง') == -1) {
        var result = json.decode(value.data);
        for (var map in result) {
          BranchModel fModels = BranchModel.fromJson(map);
          branchList.add(fModels);
        }
        setState(() {
          //categoryStateContoller = Get.put(CategoryStateContoller());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        body: (branchList != null && branchList.length > 0)
            ? showBranch()
            : MyStyle().showProgress());
  }

  Widget showBranch() {
    return Column(
      children: [
        Expanded(
          flex: 0,
          child: MyStyle().txtTHRed('เลือกสาขา')
        ),
        Expanded(
          child: LiveGrid(
          showItemDuration: Duration(microseconds: 300),
          showItemInterval: Duration(microseconds: 300),
          reAnimateOnVisibility: true,
          scrollDirection: Axis.vertical,
          itemCount: branchList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1),
          itemBuilder: animationItemBuilder((index) => InkWell(
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => ShopAdjustBal(
                            branchModel: branchList[index],
                          ));
                  Navigator.push(context, route);

                  //.then((value) => getCategory());<- มี error (index)
                  //: invalid range is emptu:0 - branchList.length,
                },
                child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://www.${MyConstant().domain}/${MyConstant().shopimagepath}/${branchList[index].shoppict}',                               
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: MyStyle().coloroverlay,
                      ),
                      Center(
                          child: MyStyle().txtstyle(
                              '${branchList[index].branchname}',
                              Colors.white,
                              16.0)),
                    ])),
              )),
        ))
      ],
    );
  }
}
