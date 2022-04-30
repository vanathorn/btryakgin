import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/sum_recive_model.dart';
import 'package:yakgin/model/sum_detail_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';

class ReciveBrSumAppbar extends StatefulWidget {
  @override
  _ReciveBrSumAppbarState createState() => _ReciveBrSumAppbarState();
}

class _ReciveBrSumAppbarState extends State<ReciveBrSumAppbar> {
  bool havedata = true, isExpanCrit = false;
  String loginName, brname, brcode, mbid, txtReason;
  double screen;
  List<SumReciveModel> listOrders = List<SumReciveModel>.empty(growable: true);
  List<SumDetailModel> listDetails = List<SumDetailModel>.empty(growable: true);
  final MainStateController mainStateController = dget.Get.find();

  final minDate = DateTime(
      DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  final maxDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

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
      findRecive();
    });
  }

  Future<Null> findRecive() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences
        .getString(MyConstant().keymbid); //เอา mbid ไปหา cid(cid=resturantId)
    String sDate = mydate112(startDate);
    String eDate = mydate112(endDate);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/branch/repReciveSumBr.aspx?mbid=$mbid&startdate=$sDate&enddate=$eDate';

    listOrders.clear();
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null) {
        for (var map in result) {
          setState(() {
            SumReciveModel mModel = SumReciveModel.fromJson(map);
            listDetails.clear();

            var detailList = mModel.detailList.split('*').toList();
            for (int i = 0; i < detailList.length; i++) {
              var tmp = detailList[i].split("|");
              listDetails.add(SumDetailModel(
                mModel.restaurantId,
                (i + 1).toString(),
                iname: tmp[1],
                qty: tmp[2],
                uname: tmp[3],
              ));
            }
            mModel.recivedtl = listDetails.toList();
            listOrders.add(mModel);
            havedata = true;
          });
        }
      } else {
        setState(() {
          havedata = false;
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
            criteriaDate(),
            listOrders == null
                ? MyStyle().showProgress()
                : (listOrders.length != 0)
                    ? dataSummary(context)
                    : Center(
                        child: MyStyle().titleCenterTH(
                            context,
                            (havedata) ? '' : 'ไม่มีการรับสินค้าตามเงื่อนไข}',
                            16,
                            Colors.red),
                      )
          ],
        ),
      ),
    );
  }

  Widget criteriaDate() => Column(
        children: [
          ExpansionTile(
            onExpansionChanged: _onExpanCritChanged,
            trailing: Switch(
              value: isExpanCrit,
              onChanged: (_) {},
            ),
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyStyle().txtshadowsIntoLight('Recive Sum.(Branch: $brcode)'),
                  SizedBox(width: 5),
                  MyStyle().txtblack16TH('วันที่'),
                ],
              ),
            ),
            children: [
              Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyStyle().txtblack16TH('เริ่มวันที่'),
                      ElevatedButton(
                          onPressed: () {
                            _openStartDatePicker(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyStyle().txtstyle(
                                  mydateFormat(
                                      '${startDate.toLocal()}'.split(' ')[0]),
                                  Colors.black,
                                  14),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                      MyStyle().txtblack16TH('ถึง'),
                      ElevatedButton(
                          onPressed: () {
                            _openEndDatePicker(context);
                          },
                          child: MyStyle().txtstyle(
                              mydateFormat(
                                  '${endDate.toLocal()}'.split(' ')[0]),
                              Colors.black,
                              14),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                    ],
                  ),
                ),
              Container(
                  child: findButton(),
              )
            ]),
        ],
      );

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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: screen * 0.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MyStyle().txtstyle(
                                    listOrders[index].strorderDate,
                                    Colors.redAccent[700], 11.0),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().txtblack12TH(listOrders[index].ttlitem.toString()),
                                SizedBox(width:10),
                                MyStyle().txtblack12TH('รายการ'),
                              ],
                            ),
                          ),
                          Container(
                            width: screen * 0.2,
                            child: Text(''),
                          ),                         
                        ],
                      ),
                    ),
                    ExpansionTile(
                        title: Column(
                          children: [
                            Row(children: [
                              Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [rowHead('สินค้า')],
                                  )),
                              Expanded(flex: 3, child: rowHead('จำนวน')),
                              Expanded(flex: 2, child: rowHead('หน่วย'))
                            ])
                          ],
                        ),
                        children: [
                          Column(
                            children: listOrders[index]
                                .recivedtl
                                .map((e) => Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3, right: 3, bottom: 5.0),
                                      child: Column(
                                        children: [
                                          itemDetail(e),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ])
                  ]))),
        ],
      );

  Row itemDetail(SumDetailModel e) {
    return Row(children: [
      Expanded(flex: 1, child: MyStyle().subtitleDark(e.seq)),
      Expanded(
          flex: 5,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [MyStyle().txtblack16TH(e.iname)])),
      Expanded(flex: 2, child: rowAlignRight(e.qty)),
      Expanded(flex: 1, child: Text('')),
      Expanded(flex: 1, child: MyStyle().txtblack16TH(e.uname))
    ]);
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

  Widget rowAlignRight(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack16TH(txt)],
      );

  String mydateFormat(String strdate) {
    String retDate = strdate.split('-')[2] +
        '/' +
        strdate.split('-')[1] +
        '/' +
        strdate.split('-')[0];
    return retDate;
  }

  String mydate112(DateTime dt) {
    String dd = (dt.day < 10) ? '0' + dt.day.toString() : dt.day.toString();
    String mm =
        (dt.month < 10) ? '0' + dt.month.toString() : dt.month.toString();
    String yyyy =
        (dt.year > 2500) ? (dt.year - 543).toString() : dt.year.toString();
    return yyyy + mm + dd;
  }

  _openStartDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year, DateTime.now().month-3, 1),
        lastDate: maxDate);
    if (picked != null) {//&& picked != startDate
      setState(() {
        startDate = picked;
      });
    }
  }

  _openEndDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year, DateTime.now().month-3, 1),
        lastDate: maxDate
    );
    if (picked != null) {//&& picked != startDate
      setState(() {
        endDate = picked;
        findRecive();
      });
    }
  }

  Widget findButton() => Container(
      margin: const EdgeInsets.only(bottom: 3),
      width: screen * 0.97,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          findRecive();
        },
        icon: Icon(
          Icons.search,
          color: Colors.black,
          size: 32.0,
        ),
        label: MyStyle().txtstyle('ค้นหา', Colors.black, 14.0),
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
}
