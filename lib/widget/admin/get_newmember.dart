import 'dart:convert';

import 'package:dio/dio.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/mbt_model.dart';
import 'package:yakgin/model/mtype_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/utility/myutil.dart';
import 'package:yakgin/widget/infosnackbar.dart';
import 'package:yakgin/widget/mysnackbar.dart';
import 'package:get/get.dart' as dget;
import 'package:shared_preferences/shared_preferences.dart';

class GetNewMember extends StatefulWidget {
  @override
  _GetNewMemberState createState() => _GetNewMemberState();
}

class _GetNewMemberState extends State<GetNewMember> {
  bool havedata = true;
  String mbid;
  double screen, ttl;
  final MainStateController mainStateController = dget.Get.find();

  List<MTypeModel> listMembers = List<MTypeModel>.empty(growable: true);
  List<MbtModel> listDetails = List<MbtModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    findNewMember();
  }

  Future<Null> findNewMember() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mbid = preferences.getString(MyConstant().keymbid);
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/admin/getNewMember.aspx';
    listMembers.clear();
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null) {
        ttl = 0;
        for (var map in result) {
          setState(() {
            MTypeModel mModel = MTypeModel.fromJson(map);
            listDetails.clear();
            var detailList = mModel.ctypeDetail.split('*').toList();
            int mbtid = 0;
            String mbtcode = '', mbtname = '';
            for (int i = 0; i < detailList.length; i++) {
              var tmp = detailList[i].split('|');
              mbtid = int.parse(tmp[0]);
              mbtcode = tmp[1];
              mbtname = tmp[2];
              listDetails.add(MbtModel(mbtid, mbtcode, mbtname));
            }
            mModel.ctypeDtl = listDetails.toList();
            listMembers.add(mModel);
            ttl += 1;

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
    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 5),
          child: MyStyle().txtTitle('New Member'),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: listMembers == null
              ? MyStyle().showProgress()
              : (listMembers.length == 0)
                  ? Center(
                      child: MyStyle().titleCenterTH(context,
                          (havedata) ? '' : 'ไม่มีสมาชิกใหม่', 16, Colors.red),
                    )
                  : showData(context),
        )
      ],
    );
  }

  Container showData(BuildContext context) => Container(
          child: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: listMembers.length,
                  itemBuilder: (context, index) => Card(
                      elevation: 5.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: screen * 0.6,
                                    margin: const EdgeInsets.only(left: 3),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          MyStyle().txtstyle(
                                              listMembers[index].mbname,
                                              Colors.blueAccent[700],
                                              15),
                                          SizedBox(width: 8),
                                          MyStyle().txtbody(
                                              listMembers[index].mobile),
                                          SizedBox(width: 8),
                                          MyStyle().txtbody(
                                              listMembers[index].decryptpsw),
                                        ])),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 5, bottom: 3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      MyStyle()
                                          .txtbody(listMembers[index].mbtlist),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            headTable(),
                            detailTable(index),
                          ])))),
        ],
      ));

  Container headTable() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: MyStyle().primarycolor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: rowAlignCenter('รหัส')),
          Expanded(flex: 3, child: rowAlignCenter('ประเภท')),
          Expanded(flex: 2, child: rowAlignCenter('Activate')),
        ],
      ),
    );
  }

  Container detailTable(int index) {
    return Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: listMembers[index].ctypeDtl.toList().length,
            itemBuilder: (context, index2) => Column(children: <Widget>[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(
                      children: [
                        Container(
                          //margin: const EdgeInsets.only(top: 0, bottom: 0, left: 0),
                          width: screen * 0.92,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 3, bottom: 3),
                                child: detailRow1(index2, index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ])
                ])));
  }

  Row detailRow1(int index2, int index) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: MyStyle().txtblack14TH(
              '${index2 + 1}  ${listMembers[index].ctypeDtl[index2].mbtcode}'),
        ),
        Expanded(
          flex: 4,
          child: MyStyle()
              .txtblack14TH('${listMembers[index].ctypeDtl[index2].mbtname}'),
        ),
        Expanded(
            flex: 3,
            child: '${listMembers[index].ctypeDtl[index2].mbtcode}' == 'S'
                ? FloatingActionButton.extended(
                    label: MyStyle().txtstyle('อนุมัติ', Colors.white, 11),
                    icon: Icon(Icons.brightness_auto),
                    onPressed: () async {
                      actMember(listMembers[index]);
                    })
                : Text('')),
        /*
        Container(
          width:screen*0.59,
          child: 
             Row(
               children: [
                MyStyle().txtblack14TH(
                  '${index2 + 1}  ${listMembers[index].ctypeDtl[index2].mbtcode}'),
                   SizedBox(width:8),
                MyStyle().txtblack14TH(
                  '${listMembers[index].ctypeDtl[index2].mbtname}'),  
               ],
             ),
        ),
        Container(
          width:screen*0.34,
          child: 
             Row(
              children: [
                FloatingActionButton.extended(
                  label: MyStyle().txtstyle('อนุมัติ', Colors.white, 11),
                  icon: Icon(Icons.brightness_auto),
                  onPressed: () async {actMember(listMembers[index]);
                }),
              ]
             )
        )
        */
      ],
    );
  }
  // Container(
  //   width: screen*0.3,
  //   child:
  //   Row(
  //     children: [
  //       FloatingActionButton.extended(
  //         label: MyStyle().txtstyle('อนุมัติ', Colors.white, 11),
  //         icon: Icon(Icons.brightness_auto),
  //         onPressed: () async {actMember(listMembers[index]);
  //       }),
  //     ],
  //   )
  // )

  Future<Null> actMember(MTypeModel listmember) async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/admin/activateMember.aspx?mbid=${listmember.mbid}';

    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        if (result != null && result.toString() != '') {
          for (var map in result) {
            MTypeModel mModel = MTypeModel.fromJson(map);
            if (mModel.mbid == listmember.mbid &&
                mModel.mobile == listmember.mobile) {
              MyUtil().sendNoticToShop(
                  mModel.resturantid,
                  'อนุมัติสมาชิก: ${listmember.mbname}',
                  'สามารถใช้งาน\r\nร้านค้า ${mModel.shopname} ได้แล้วค่ะ');
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  InfoSnackBar.infoSnackBar(
                      'Activate.${mModel.mobile} ร้านค้า:' +
                          '${mModel.shopname}' +
                          ' สำเร็จ',
                      Icons.add_business),
                );
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(MySnackBar.showSnackBar(
                    'Activate !ไม่สำเร็จ:' + 'mbid/mobile ไม่ถูกต้อง',
                    Icons.closed_caption_disabled_sharp));
            }
            setState(() {
              findNewMember();
            });
          }
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              MySnackBar.showSnackBar(
                  'Activate สมาชิก:' + '${listmember.mbname}' + '!ไม่สำเร็จ',
                  Icons.sick),
            );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar(
              '! ไม่พบฐานข้อมูล(check Table:dbo.mstCom)', Icons.cloud_off),
        );
    }
  }

  Widget rowAlignRight(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [MyStyle().txtblack14TH(txt)],
      );

  Widget rowAlignCenter(String txt) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [MyStyle().txtblack14TH(txt)],
      );
}
