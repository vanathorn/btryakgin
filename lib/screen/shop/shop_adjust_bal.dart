import 'dart:convert';
//vtr after upgrade  import 'dart:ui';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakgin/model/branch_model.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/model/food_model.dart';
import 'package:yakgin/state/category_state.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:yakgin/widget/commonwidget.dart';
import 'package:get/get.dart';
import 'package:yakgin/widget/infosnackbar.dart';
import 'package:yakgin/widget/mysnackbar.dart';

class ShopAdjustBal extends StatefulWidget {
  final BranchModel branchModel;
  ShopAdjustBal({Key key, this.branchModel}) : super(key: key);
  @override
  _ShopAdjustBal createState() => _ShopAdjustBal();
}

class _ShopAdjustBal extends State<ShopAdjustBal> {
  String loginName, ccode, brcode, mobile;
  double screen;
  bool loadding = true, loaditem = true;
  String selectType = '', txtQty = '', sign = '+';
  int reciveQty = 0;
  final int maxnum = 8;
  final double hi = 10;
  CategoryStateContoller categoryStateContoller;
  List<CategoryModel> foodtypeList = List<CategoryModel>.empty(growable: true);
  List<FoodModel> foodList = List<FoodModel>.empty(growable: true);
  BranchModel branchModel;
  @override
  void initState() {
    super.initState();
    branchModel = widget.branchModel;
    brcode = branchModel.branchcode;
    findShop();
  }

  Future<Null> findShop() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      ccode = prefer.getString('pccode');
      mobile = prefer.getString('pmobile');
      getItemType();
    });
  }

  Future<Null> getItemType() async {
    foodtypeList.clear();
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodType.aspx?ccode=$ccode&strCondtion=&strOrder=';

    await dio.Dio().get(url).then((value) {
      setState(() {
        loadding = false;
      });
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          CategoryModel fModels = CategoryModel.fromJson(map);
          if (fModels.ttlitem != '0') {
            foodtypeList.add(fModels);
          }
        }
        setState(() {
          categoryStateContoller = Get.put(CategoryStateContoller());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBarWithOrderButton(
          title: (loginName != null) ? loginName : '',
          subtitle: (branchModel.branchname != null)
              ? branchModel.branchname
              : '', //+ (brcode !='' ? ' ('+brcode+')' :'') : ''),
          ttlordno: '0', brcode: brcode),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 0,
                child: MyStyle().txtH16('เลือกประเภทสินค้า  $selectType')),
            Expanded(flex: 1, child: (loadding) ? Container() : showItemType()),
            Expanded(
                flex: 5,
                child: (foodList.length > 0)
                    ? showItemByType()
                    : Text(
                        '') /*!loaditem
                        ? Text('')
                        : MyStyle().txtTHRed('ไม่มีรายการสินค้า')*/
                )
          ],
        ),
      ),
    );
  }

  Widget showItemType() {
    return Container(
        child: (foodtypeList.length != 0)
            ? showItemTypeList()
            : MyStyle().titleCenterTH(
                context, 'ไม่มีรายการประเภทสินค้า', 20, Colors.red));
  }

  Widget showItemTypeList() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: LiveList(
                  showItemInterval: Duration(milliseconds: 150),
                  showItemDuration: Duration(milliseconds: 350),
                  reAnimateOnVisibility: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: foodtypeList.length,
                  itemBuilder: animationItemBuilder(
                    (index) => Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 5, right: 5.0),
                      child: Column(
                        children: [
                          Align(
                              child: SizedBox(
                            child: GestureDetector(
                              onTap: () {
                                selectType = '${foodtypeList[index].name}';
                                setState(() {
                                  getItemByType('${foodtypeList[index].key}');
                                });
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 34.0,
                                    backgroundImage: NetworkImage(
                                        'https://www.${MyConstant().domain}/' +
                                            '${MyConstant().imagepath}/$ccode/foodtype/${foodtypeList[index].image}'),
                                    child: Stack(
                                      children: [
                                        Container(
                                            child: CircleAvatar(
                                          backgroundColor:
                                              MyStyle().coloroverlay,
                                          radius: 34.0,
                                        )),
                                        Container(
                                          alignment: Alignment.center,
                                          child: MyStyle().txtstyle(
                                              '${foodtypeList[index].name}',
                                              Colors.white,
                                              12.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }

  Widget showItemByType() {
    return Container(
      width: screen,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 1, child: Text('')),
                Expanded(
                    flex: 4,
                    child: MyStyle()
                        .txtTH('รายการสินค้า', MyStyle().primarycolor)),
                Expanded(
                    flex: 2,
                    child:
                        MyStyle().txtTH('ยอดปัจจุบัน', MyStyle().primarycolor)),
              ],
            ),
            LiveList(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                showItemInterval: Duration(milliseconds: 150),
                showItemDuration: Duration(milliseconds: 350),
                reAnimateOnVisibility: true,
                scrollDirection: Axis.vertical,
                itemCount: foodList.length,
                itemBuilder: animationItemBuilder((index) => GestureDetector(
                      onTap: () {
                        categoryStateContoller = Get.find();
                        //categoryStateContoller.selectCategory.value = foodtypeList[index].key;
                        //String itid = '${categoryStateContoller.selectCategory.value.key}';
                        dialigReciveQty(foodList[index]);
                      },
                      child: Card(
                          elevation: 8,
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CachedNetworkImage(
                                        width: 70,
                                        height: 70,
                                        imageUrl:
                                            'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${foodList[index].image}',
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder: (context, url,
                                                dowloadProgress) =>
                                            Center(
                                                child:
                                                    CircularProgressIndicator()),
                                      ),
                                      MyStyle().txtTH18Dark(
                                          '${foodList[index].name}'),
                                      SizedBox(width: 5),
                                      Container(
                                          child: Row(
                                        children: [
                                          MyStyle().txtTHRed(
                                              '${MyCalculate().fmtNumber(foodList[index].currqty)}'),
                                          SizedBox(width: 5),
                                          MyStyle().txtTHRed(
                                              '${foodList[index].uname}'),
                                          SizedBox(width: 3),
                                        ],
                                      )),
                                    ]),
                              ),
                            ],
                          )),
                    ))),
          ],
        ),
      ),
    );
  }

  Future<Null> getItemByType(String itid) async {
    //String itid = '${categoryStateContoller.selectCategory.value.key}';
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'foodRemain_ByType_Loc.aspx?ccode=$ccode&brcode=$brcode&itid=$itid&strOrder=iName';
    setState(() {
      loaditem = true;
    });
    foodList.clear();
    await dio.Dio().get(url).then((value) {
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        for (var map in result) {
          FoodModel fModels = FoodModel.fromJson(map);
          fModels.ccode = ccode; //for check what shop
          setState(() {
            loaditem = false;
            foodList.add(fModels);
          });
        }
      }
      //setState(() {
      //foodListCtl = Get.put(FoodListStateController());
      //});
      setState(() {
        loaditem = false;
      });
    });
  }

  Future<Null> dialigReciveQty(FoodModel foodList) async {
    //reciveQty = int.parse('${foodList.currqty}');
    var myFmt = NumberFormat('##0.##', 'en_US');
    double x = foodList.currqty.abs();
    txtQty = myFmt.format(x);
    sign = foodList.currqty < 0 ? '-' : '';
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // title: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //       Text('${foodList.name}', style: MyStyle().myLabelStyle())
                //     ]),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${foodList.image}'),
                                    fit: BoxFit.cover))),
                        Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Row(
                              children: [
                                SingleChildScrollView(
                                    child:
                                        MyStyle().txtTHRed('${foodList.name}'))
                              ],
                            )),
                      ],
                    ),
                    /*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: screen * 0.25,
                            child: MyStyle().txtTH('คงเหลือ=', Colors.black87)
                        ),                    
                      ],
                    ),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /*
                        IconButton(
                          iconSize: 54,
                          icon: Icon(
                            (sign == '')
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: (sign == '') ? Colors.green : Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              sign = (sign == '') ? '-' : '';
                            });
                          },
                        ),
                        */
                        MyStyle().txtTH('คงเหลือ=', Colors.black87),
                        Text('$sign',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: '$sign' == '' ? Colors.green : Colors.red,
                            )),
                        Text(txtQty,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.red,
                              //background: Paint(Colors: Colors.amber),
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              decorationStyle: TextDecorationStyle.solid,
                              letterSpacing: -1.0,
                              wordSpacing: 5.0,
                              fontFamily: 'Arial',
                            )),
                        SizedBox(width: 5),
                        MyStyle().txtTH(foodList.uname, Colors.black87),
                        //clearButton(setState),
                      ],
                    ),
                    SizedBox(height: 3),
                    keyPad(setState),
                    Divider(thickness: 1),
                    confirmQty(context, setState, foodList),
                  ],
                ),
              ),
            ));
  }

  Row keyPad(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: screen * 0.63,
          margin: const EdgeInsets.only(bottom: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(setState, '1'),
                  buildButton(setState, '2'),
                  buildButton(setState, '3'),
                ],
              ),
              SizedBox(height: hi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(setState, '4'),
                  buildButton(setState, '5'),
                  buildButton(setState, '6'),
                ],
              ),
              SizedBox(height: hi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(setState, '7'),
                  buildButton(setState, '8'),
                  buildButton(setState, '9'),
                ],
              ),
              SizedBox(height: hi),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  toggleButton(setState),
                  buildButton(setState, '0'),
                  delButton(setState),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row confirmQty(
      BuildContext context, StateSetter setState, FoodModel foodList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
                width: screen * 0.25,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: MyStyle()
                    .titleCenter(context, 'ยกเลิก', 14.0, Colors.black))),
        TextButton(
            onPressed: () async {
              Navigator.pop(context);
              double adjqty = double.parse(txtQty);
              await updateBal(foodList.id, adjqty);
            },
            child: Container(
                width: screen * 0.25,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.redAccent[700],
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: MyStyle()
                    .titleCenter(context, 'ยืนยัน', 14.0, Colors.white))),
      ],
    );
  }

  GestureDetector buildButton(StateSetter setState, String txtValue) {
    return GestureDetector(
      child: InkWell(
        onTap: () {
          String tmp = txtQty;
          if (tmp.length < maxnum) {
            setState(() {
              if (tmp == '0') {
                txtQty = txtValue;
              } else {
                txtQty += txtValue;
              }
            });
          }
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.black,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[350],
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(70))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(txtValue,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.normal,
                      color: Colors.redAccent[700])),
            ],
          ),
        ),
      ),
    );
  }

  Container delButton(StateSetter setState) {
    return Container(
      //margin: const EdgeInsets.only(right: 0),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          String tmp = txtQty.toString();
          if (tmp.length > 0) {
            setState(() {
              txtQty = tmp.substring(0, tmp.length - 1);
              if (txtQty == '') {
                txtQty = '0';
                sign = '';
              }
            });
          }
        },
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(
          Icons.backspace,
          color: Colors.white,
          size: 32,
        ),
        splashColor: Colors.blue,
      ),
    );
  }

  Container clearButton(StateSetter setState) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black54,
        onPressed: () {
          setState(() {
            txtQty = '0';
          });
        },
        label: Text('',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            )),
        icon: Icon(
          Icons.clear_all,
          color: Colors.white,
          size: 38,
        ),
        splashColor: Colors.redAccent[400],
      ),
    );
  }

  Container toggleButton(StateSetter setState) {
    return Container(
      //margin: const EdgeInsets.only(left: 0, right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: (sign == '') ? Colors.green : Colors.red,
        onPressed: () {
          setState(() {
            if (sign == '-') {
              sign = int.parse(txtQty) != 0 ? '+' : '';
            } else {
              sign = int.parse(txtQty) != 0 ? '-' : '';
            }
          });
        },
        label: Text('-/+',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 30,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        // icon: Icon(
        //   Icons.remove_circle_outline,
        //   color: Colors.white,
        //   size: 38,
        // ),
        splashColor: Colors.redAccent[400],
      ),
    );
  }

  Container plusButton(StateSetter setState) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () {
          setState(() {
            sign = (sign == '') ? '-' : '';
          });
        },
        label: Text('+',
            style: TextStyle(
              fontFamily: 'Arila',
              fontSize: 24,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            )),
        // icon: Icon(
        //   Icons.add_circle_outline_outlined,
        //   color: Colors.black,
        //   size: 38,
        // ),
        splashColor: Colors.green,
      ),
    );
  }

  Future<Null> updateBal(String iid, double adjqty) async {
    bool ok = true;
    String mess = '';
    String msign = ('$sign' == '-') ? '-' : '+';
    try {
      String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
          'shop/updateBal.aspx?ccode=$ccode&brcode=$brcode&iid=$iid&sign=$msign&qty=' +
          adjqty.toString();
      dio.Response response = await dio.Dio().get(url);
      if (response.toString() != '') {
        mess = response.toString();
        ok = false;
      }
    } catch (ex) {
      mess = ex.toString();
      ok = false;
    }
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          InfoSnackBar.infoSnackBar('บันทึกข้อมูลเรียบร้อย',
              Icons.sentiment_satisfied_alt), //tackface
        );
      setState(() {
        loaditem = true;
        String itid = '${categoryStateContoller.selectCategory.value.key}';
        getItemByType(itid);
      });
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar(mess, Icons.sick),
        );
    }
  }
}
