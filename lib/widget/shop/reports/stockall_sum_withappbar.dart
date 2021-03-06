import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/itype_loc_model.dart';
import 'package:yakgin/model/sum_detail_model.dart';
import 'package:yakgin/model/sum_stockall_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';

class StockAllSumAppbar extends StatefulWidget {
  @override
  _StockAllSumAppbarState createState() => _StockAllSumAppbarState();
}

class _StockAllSumAppbarState extends State<StockAllSumAppbar> {
  bool loading = true, isExpanCrit = false;
  String loginName, brname, brcode, mbid, txtQty;
  String mode = 'MORE';
  int moreQty = -1, equalQty = -1;
  final int maxnum = 8;
  final double hi = 10;

  double screen;
  List<SumStockAllModel> listOrders =
      List<SumStockAllModel>.empty(growable: true);
  List<ITypeLocModel> listItypes = List<ITypeLocModel>.empty(growable: true);
  List<SumDetailModel> listDetails = List<SumDetailModel>.empty(growable: true);
  final MainStateController mainStateController = dget.Get.find();

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  _onExpanCritChanged(bool val) {
    setState(() {
      isExpanCrit = val;
    });
  }

  Future<Null> getPreferences() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      brcode = prefer.getString(MyConstant().keybrcode);
      brname = prefer.getString('pbrname');
      findStock();
    });
  }

  Future<Null> findStock() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/head/repStockSum.aspx?mbid=$mbid&mode=$mode';
    url += (mode == 'MORE') ? '&qtymore=$moreQty' : '&qtyequal=$equalQty';

    listOrders.clear();
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null &&
          result.toString() != '[]' &&
          result.toString() != '') {
        String oldloc = '';
        for (var map in result) {
          setState(() {
            SumStockAllModel mModel = SumStockAllModel.fromJson(map);
            if (mModel.locid != oldloc) {
              SumStockAllModel xM = new SumStockAllModel();
              xM.restaurantId = mModel.restaurantId;
              xM.ccode = mModel.ccode;
              xM.locid = mModel.locid;
              xM.loccode = mModel.loccode;
              xM.locname = mModel.locname;
              xM.ttltype = mModel.ttltype;
              listOrders.add(xM);
              oldloc = mModel.locid;
            }
          });
        }
        for (int j = 0; j < listOrders.length; j++) {
          String locid = listOrders[j].locid;
          listItypes.clear();
          int s = 0;
          for (var map in result) {
            SumStockAllModel mModel = SumStockAllModel.fromJson(map);
            if (mModel.locid == locid) {
              ITypeLocModel tM = new ITypeLocModel();
              tM.seq = (s + 1).toString();
              tM.loccode = mModel.loccode;
              tM.itid = mModel.itid;
              tM.itname = mModel.itname;
              tM.ttlitem = mModel.ttlitem;

              listDetails.clear();
              var itemlist = mModel.detailList.split('*').toList();
              for (int i = 0; i < itemlist.length; i++) {
                var tmp = itemlist[i].split("|");
                listDetails.add(SumDetailModel(
                  mModel.restaurantId,
                  (i + 1).toString(),
                  iname: tmp[1],
                  qty: tmp[2],
                  uname: tmp[3],
                ));
              }
              tM.stockdtl = listDetails.toList();
              listItypes.add(tM);
              s++;
            } else {
              if (listItypes.length > 0) break;
            }
          }
          setState(() {
            listOrders[j].itypedtl = listItypes.toList();
            loading = false;
          });
        }
      } else {
        setState(() {
          loading = false;
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
          subtitle: (brname != null) ? brname : '',
          ttlordno: '0',
          brcode: brcode,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            criteriaQty(),
            (loading) ? MyStyle().showProgress() : dataSummary(context)
          ],
        )));
  }

  Widget criteriaQty() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExpansionTile(
              onExpansionChanged: _onExpanCritChanged,
              trailing: Switch(
                value: isExpanCrit,
                onChanged: (_) {},
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    MyStyle().txtshadowsIntoLight('Stock Summary(All branch)'),
                  ])
                ],
              ),
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      qtyEqualButton(setState),
                      MyStyle().txtstyle(
                          mode == 'EQUAL' ? '$equalQty' : '', Colors.black, 14),
                      qtyMoreButton(setState),
                      MyStyle().txtstyle(
                          mode == 'MORE' ? '$moreQty' : '', Colors.black, 14),
                    ])
              ])
        ],
      );

  Row qtyMoreButton(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 3, bottom: 15.0),
                child: FloatingActionButton.extended(
                    backgroundColor: MyStyle().menubgcolor,
                    //icon: Icon(Icons.near_me_disabled_outlined),
                    label: MyStyle().txtstyle('?????????????????????', Colors.black, 9),
                    onPressed: () {
                      setState(() {
                        mode = 'MORE';
                      });
                      dialogQty(setState);
                    })),
          ],
        ),
      ],
    );
  }

  Row qtyEqualButton(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 3, bottom: 15.0),
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.greenAccent[700],
                    label: MyStyle().txtstyle('????????????????????????????????????', Colors.black, 9),
                    onPressed: () {
                      setState(() {
                        mode = 'EQUAL';
                      });
                      dialogQty(setState);
                    })),
          ],
        ),
      ],
    );
  }

  Widget dataSummary(BuildContext context) => Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: listOrders.length,
              itemBuilder: (context, index) => Card(
                  elevation: 5.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  child: Column(children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: screen * 0.65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MyStyle().txtstyle(listOrders[index].loccode,
                                    Colors.black, 13),
                                SizedBox(width: 5),
                                MyStyle().txtstyle(listOrders[index].locname,
                                    Colors.redAccent[700], 13),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().txtblack12TH(
                                    '${listOrders[index].ttltype.toString()} ????????????????????????????????????'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    ExpansionTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            Expanded(
                                flex: 5, child: rowHead('??????????????????????????????????????????????????????')),
                            Expanded(flex: 1, child: rowHead(''))
                          ])
                        ],
                      ),
                      children: [
                        Column(
                          children: listOrders[index]
                              .itypedtl
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 3, bottom: 5.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: MyStyle().txtstyle(
                                                    '${e.itname}',
                                                    MyStyle().primarycolor,
                                                    13)),
                                            Expanded(
                                                flex: 3,
                                                child: rowAlignRightColor(
                                                    '${e.ttlitem}',
                                                    MyStyle().primarycolor)),
                                            Expanded(flex: 1, child: Text('')),
                                            Expanded(
                                                flex: 2,
                                                child: MyStyle().txtstyle(
                                                    '  ??????????????????',
                                                    MyStyle().primarycolor,
                                                    11))
                                          ],
                                        ),
                                        displayItem(e),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    )
                  ]))),
        ],
      );

  Row displayItem(ITypeLocModel itypeLocModel) {
    return Row(
      children: [
        Expanded(
            child: Column(
                children: itypeLocModel.stockdtl
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 5.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: MyStyle().subtitleDark(e.seq)),
                              Expanded(
                                  flex: 5,
                                  child: MyStyle().txtblack16TH(e.iname)),
                              Expanded(flex: 2, child: rowAlignRight(e.qty)),
                              Expanded(flex: 1, child: Text('')),
                              Expanded(
                                  flex: 1,
                                  child: MyStyle().txtblack16TH(e.uname))
                            ],
                          ),
                        ))
                    .toList()))
      ],
    );
  }

   Widget rowHead(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(txt,
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
            ))
        ],
      );
      
  Widget rowAlignRightColor(String txt, Color txtcolor) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(txt,
              style: TextStyle(
                  fontFamily: 'thaisanslite',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: txtcolor))
        ],
      );

  Widget rowAlignRight(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack16TH(txt)],
      );

  /*
  Widget findButton() => Container(
      margin: const EdgeInsets.only(bottom: 3),
      width: screen * 0.97,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          findStock();
        },
        icon: Icon(
          Icons.search,
          color: Colors.black,
          size: 32.0,
        ),
        label: MyStyle().txtstyle('???????????????', Colors.black, 14.0),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return Colors
                  .lightGreenAccent[700]; // Use the component's default.
            },
          ),
        ),
      ));
  */

  Future<Null> dialogQty(StateSetter setState) async {
    txtQty = '-1';
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: screen * 0.2,
                            child: MyStyle().txtTH(
                                mode == 'EQUAL' ? '?????????????????????' : '?????????????????????',
                                Colors.black87)),
                        Text(txtQty,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.red,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              decorationStyle: TextDecorationStyle.solid,
                              letterSpacing: -1.0,
                              wordSpacing: 5.0,
                              fontFamily: 'Arial',
                            )),
                      ],
                    ),
                    SizedBox(height: 3),
                    keyPad(setState),
                    Divider(thickness: 1),
                    confirmQty(context, setState),
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
                  clearButton(setState),
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

  Row confirmQty(BuildContext context, StateSetter setState) {
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
                    .titleCenter(context, '??????????????????', 14.0, Colors.black))),
        TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                loading = true;
                if (mode == 'MORE') {
                  moreQty = int.parse(txtQty);
                } else {
                  equalQty = int.parse(txtQty);
                }   
                findStock();            
              });
            },
            child: Container(
                width: screen * 0.25,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.redAccent[700],
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: MyStyle()
                    .titleCenter(context, '??????????????????', 14.0, Colors.white))),
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
      margin: const EdgeInsets.only(right: 5),
      width: 54,
      height: 54,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          String tmp = txtQty.toString();
          if (tmp.length > 0) {
            setState(() {
              txtQty = tmp.substring(0, tmp.length - 1);
              if (txtQty == '') txtQty = '0';
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
}
