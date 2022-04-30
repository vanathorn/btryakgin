import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/itype_loc_model.dart';
import 'package:yakgin/model/sum_detail_model.dart';
import 'package:yakgin/model/sum_reciveall_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/appbar_withorder.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';

class ReciveSumAppbar extends StatefulWidget {
  @override
  _ReciveSumAppbarState createState() => _ReciveSumAppbarState();
}

class _ReciveSumAppbarState extends State<ReciveSumAppbar> {
  bool loading = true, isExpanCrit = false;
  String loginName, brname, brcode, mbid;
  double screen;
  List<SumReciveAllModel> listOrders = List<SumReciveAllModel>.empty(growable: true);
  List<ITypeLocModel> listItypes = List<ITypeLocModel>.empty(growable: true);
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
        '/head/repRecive.aspx?mbid=$mbid&startdate=$sDate&enddate=$eDate';

    listOrders.clear();
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null &&
          result.toString() != '[]' &&
          result.toString() != '') {
        String oldloc = '';
        for (var map in result) {
          setState(() {
            SumReciveAllModel mModel = SumReciveAllModel.fromJson(map);
            if (mModel.locid != oldloc) {
              SumReciveAllModel xM = new SumReciveAllModel();
              xM.restaurantId = mModel.restaurantId;
              xM.ccode = mModel.ccode;
              xM.locid = mModel.locid;
              xM.loccode = mModel.loccode;
              xM.locname = mModel.locname;
              xM.ttldate = mModel.ttldate;
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
            SumReciveAllModel mModel = SumReciveAllModel.fromJson(map);
            if (mModel.locid == locid) {
              ITypeLocModel tM = new ITypeLocModel();
              tM.seq = (s + 1).toString();
              tM.loccode = mModel.loccode;
              tM.itid = '';
              tM.itname = mModel.strDate;
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
            criteriaDate(),
            (loading) ? MyStyle().showProgress() : dataSummary(context)
          ],
        )));
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
                    MyStyle().txtshadowsIntoLight('ReciveSumm.(All Branch)'),
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
                            margin: const EdgeInsets.only(right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().txtblack12TH(
                                    'จำนวน ${listOrders[index].ttldate}'),
                                SizedBox(width: 5),
                                MyStyle().txtblack12TH('วัน'),
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
                            Expanded(flex: 5, child: rowHead('จำแนกตามวันที่')),
                            Expanded(flex: 2, child: rowHead(''))
                          ])
                        ],
                      ),
                      children: [
                        Column(                          
                          children: listOrders[index]
                            .itypedtl
                            .map((e) => Padding(
                              padding: const EdgeInsets.only(left: 3, right: 3, bottom: 5.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: 
                                          MyStyle().txtstyle('${e.itname}',
                                          MyStyle().primarycolor, 13)),
                                      Expanded(
                                        flex: 3,
                                        child: rowAlignRightColor(e.ttlitem,
                                                    MyStyle().primarycolor)),
                                      Expanded(
                                        flex: 1, child: Text('')),
                                      Expanded(
                                        flex: 2,
                                        child: MyStyle().txtstyle('  รายการ',
                                            MyStyle().primarycolor, 11))
                                    ]),
                                    displayItem(e),
                                ],
                              ),
                            )).toList() 
                            
                        )
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
    if (picked != null) {// && picked != startDate
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
        lastDate: maxDate);
    if (picked != null) { // && picked != startDate
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
