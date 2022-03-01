import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/foodtype_model.dart';
import 'package:btryakgin/utility/dialig.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFoodType extends StatefulWidget {
  final FoodTypeModel foodTypeModel;
  EditFoodType({Key key, this.foodTypeModel}) : super(key: key);

  @override
  _EditFoodTypeState createState() => _EditFoodTypeState();
}

class _EditFoodTypeState extends State<EditFoodType> {
  FoodTypeModel foodTypeModel;
  double screen;
  String txtName = '', txtDetail = '';
  String strConn, webPath;
  String loginName, loginccode;

  PickedFile _imageFile;
  //File _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    foodTypeModel = widget.foodTypeModel;
    txtName = foodTypeModel.itname;
    txtDetail = foodTypeModel.itdescription;
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefer.getString('pname');
      loginccode = prefer.getString('pccode');
      strConn = prefer.getString('pstrconn');
      webPath = prefer.getString('pwebpath');
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: MyStyle().txtTH(
            'แก้ไขข้อมูลประเภทอาหาร ${foodTypeModel.itname}', Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            inputName(),
            inputDetail(),
            groupImage(),
          ],
        ),
      ),
      //*** floatingActionButton จะ floating ตาม ไม่โดน keyboard บัง
      floatingActionButton: uploadData(),
    );
  }

  FloatingActionButton uploadData() {
    return FloatingActionButton(
      onPressed: () {
        if (txtName?.isEmpty ?? true) {
          alertDialog(context, 'ชื่อประเภท ห้ามเป็นช่องว่าง');
        } else {
          confirmUpdate();
        }
      },
      child: Icon(Icons.cloud_upload),
    );
  }

  Future<Null> confirmUpdate() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle().txtstyle(
            'คุณต้องการบันทึกข้อมูล ${foodTypeModel.itname} ?',
            Colors.black,
            20.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton.icon(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.orangeAccent[700],
                  ),
                  label: MyStyle()
                      .titleCenter(context, 'ยกเลิก', 18.0, Colors.black),
                  onPressed: () => Navigator.pop(context)),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                label: MyStyle()
                    .titleCenter(context, 'ยืนยัน', 18.0, Colors.black),
                onPressed: () async {
                  Navigator.pop(context);
                  updateOnServer();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent[400], // background
                  onPrimary: Colors.black, // foreground
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> updateOnServer() async {
    String url = '';
    await Dio().get(url).then((value) {
      if (value.toString() != '') {
        Navigator.pop(context);
      } else {
        alertDialog(context, '!มีข้อผิดพลาด บันทึกไม่สำเร็จ');
      }
    });
  }

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextFormField(
              initialValue: foodTypeModel.itname,
              onChanged: (value) => txtName = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ชื่อประเภท',
                prefixIcon: Icon(Icons.category, color: MyStyle().darkcolor),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().lightcolor),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyStyle().darkcolor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          )
        ],
      );

  Widget inputDetail() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.85,
            child: TextFormField(
              initialValue: foodTypeModel.itdescription,
              onChanged: (value) => txtDetail = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'รายละเอียด',
                prefixIcon: Icon(Icons.details, color: MyStyle().darkcolor),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().lightcolor),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyStyle().darkcolor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
            ),
          )
        ],
      );

  Widget groupImage() => Container(
        margin: EdgeInsets.only(top: 5, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //Image from camera
            IconButton(
                tooltip: 'Pick Image from caremra',
                icon: Icon(
                  Icons.linked_camera, //add_a_photo,
                  size: 48,
                ),
                onPressed: () => chooseImage(ImageSource.camera, 600.0, 600.0)),

            //image picture
            Container(
                margin: EdgeInsets.only(top: 5, left: 10),
                width: screen * 0.5,
                height: screen * 0.5,
                child: (_imageFile == null)
                    ? Image.network(
                        '${MyConstant().domain}/$webPath/' +
                            '${MyConstant().imagepath}/$loginccode/' +
                            'foodtype/${foodTypeModel.ftypepict}',
                        fit: BoxFit.cover,
                      )
                    : Image.file(File(_imageFile.path))),

            //image from gallery
            Container(
                margin: EdgeInsets.only(right: 15),
                child: IconButton(
                    tooltip: 'Pick Image from gallery',
                    icon: Icon(
                      Icons.photo,
                      size: 48,
                    ),
                    onPressed: () =>
                        chooseImage(ImageSource.gallery, 600.0, 600.0)))
          ],
        ),
      );

  Future<Null> chooseImage(
      ImageSource source, double maxWidth, double maxHeight) async {
    try {
      final pickedFile = await _picker.getImage(source: source
          //maxWidth: maxWidth,
          //maxHeight: maxHeight,
          //imageQuality: quality,
          );
      setState(() {
        _imageFile = pickedFile;
        //*** File _image = File(_imageFile.path);
      });
    } catch (e) {
      //
    }
  }

  Widget saveButton() => Container(
      width: screen * 0.75,
      height: 48.0,
      margin: EdgeInsets.only(top: 5.0),
      child: ElevatedButton.icon(
        onPressed: () {
          confirmDialog();
        },
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: MyStyle().txtTH('บันทึกข้อมูล', Colors.white),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Color(0xffBFB372);
              return Colors.green; // Use the component's default.
            },
          ),
        ),
      ));

  Future<Null> confirmDialog() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
                title: MyStyle().txtstyle(
                    'ยืนยันการปรับปรุงข้อมูล ${foodTypeModel.itname} ?',
                    Colors.red,
                    20.0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              width: screen * 0.15,
                              height: 48,
                              child: MyStyle().titleCenter(
                                  context, 'ยกเลิก', 18.0, Colors.black))),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            editThread();
                          },
                          child: Container(
                              width: screen * 0.22,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.redAccent[700],
                              ),
                              child: MyStyle().titleCenter(
                                  context, 'ยืนยัน', 18.0, Colors.white))),
                    ],
                  ),
                ]));
  }

  Future<Null> editThread() async {
    //print('_image *******  $_image.path');
  }
}
