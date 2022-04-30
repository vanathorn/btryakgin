import 'dart:convert';
import 'dart:io' as io;
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:yakgin/model/category_model.dart';
import 'package:yakgin/model/mess_model.dart';
import 'package:yakgin/model/phyimg_model.dart';
import 'package:yakgin/utility/my_calculate.dart';
import 'package:get/get.dart' as dget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/widget/infosnackbar.dart';
import 'package:yakgin/widget/mysnackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yakgin/model/food_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/state/food_detail_state.dart';
import 'package:yakgin/state/food_list_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/state/upimage/image_state.dart' as imgstate;
import 'package:yakgin/state/upimage/imageapi_call.dart';
//import 'package:yakgin/state/upimage/result_state.dart';
import 'package:yakgin/state/upimage/upload_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

//vtr after upgrade import 'package:flutter/services.dart';
//vtr after upgrate import 'package:flutter_riverpod/all.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';

class ShopFoodDetailScreen extends StatefulWidget {
  final CategoryModel categoryModel;
  final ShopRestModel restModel;
  final FoodModel fModel;
  final itemSame;
  ShopFoodDetailScreen(
      {Key key, this.categoryModel, this.restModel, this.fModel, this.itemSame})
      : super(key: key);
  @override
  _ShopFoodDetailScreenState createState() => _ShopFoodDetailScreenState();
}

class _ShopFoodDetailScreenState extends State<ShopFoodDetailScreen> {
  CategoryModel categoryModel;
  ShopRestModel restModel;
  FoodModel fModel;
  FoodModel foodModel = new FoodModel();
  String strConn, ccode;
  double screen, screenH, manFavor;
  String txtName, txtDescription, txtPrice, txtPriceSp;
  String _txtName, _txtDescription, _txtPrice, _txtPriceSp;
  String flagAuto = '';
  String physicalpath =
      'D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\product\\';

  PickedFile _imageFile;
  String gllery = 'N';
  io.File imgFile;
  final imgPicker = ImagePicker();

  FoodListStateController foodListStateController;
  FoodDetailStateController foodController =
      Get.put(FoodDetailStateController());
  final MainStateController mainStateController = dget.Get.find();

  @override
  void initState() {
    super.initState();
    categoryModel = widget.categoryModel;
    restModel = widget.restModel;
    fModel = widget.fModel;
    ccode = restModel.ccode;

    foodListStateController = Get.find();
    foodListStateController.selectedFood.value = fModel;

    readExistItem(fModel.id);
  }

  Future<Null> readExistItem(String iid) async {
    _imageFile = null;
    imgFile = null;
    String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
        'shop/getItem.aspx?ccode=$ccode&iid=$iid';

    await dio.Dio().get(url).then((value) {
      if (value.toString() != 'null' &&
          value.toString().indexOf('ไม่ถูกต้อง') == -1) {
        var result = json.decode(value.data);
        for (var map in result) {
          foodModel = FoodModel.fromJson(map);
          setState(() {
            ccode = fModel.ccode;
            _txtName = foodModel.name;
            _txtDescription = foodModel.description;
            _txtPrice = MyCalculate().fmtNumber(foodModel.price);
            _txtPriceSp = MyCalculate().fmtNumber(foodModel.priceSp);
            txtName = _txtName;
            txtDescription = _txtDescription;
            txtPrice = _txtPrice;
            txtPriceSp = _txtPriceSp;
            //String _itemImage = foodModel.image;
            flagAuto = foodModel.auto;
            manFavor = foodModel.manfavor;
            //--------------------------------------------------
            fModel.name = txtName;
            fModel.description = txtDescription;
            fModel.price = foodModel.price;
            fModel.priceSp = foodModel.priceSp;
            fModel.auto = foodModel.auto;
            if (foodModel.auto == 'N') {
              fModel.favorite = foodModel.manfavor;
            } else {
              fModel.favorite = foodModel.favorite;
            }
            fModel.manfavor = foodModel.manfavor;
            fModel.image = foodModel.image;
            foodListStateController.selectedFood.value = fModel;
            getPhycicalImagefolder();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: MyStyle().txtTH(
              'แก้ไขข้อมูลสินค้า ' +
                  '${foodListStateController.selectedFood.value.name}',
              Colors.white),
        ),
        body: (foodModel.id == null)
            ? MyStyle().showProgress()
            : Container(
                margin: const EdgeInsets.only(top: 5),
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 0),
                              width: (!kIsWeb) ? (210) : (screen * 0.25),
                              child: (_imageFile == null)
                                  ? Image.network(
                                      'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${foodModel.image}',
                                      fit: BoxFit.cover,
                                    )
                                  : displayImage(), //watchState(),
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (!kIsWeb) ? galleryPickup() : Text(''),
                          MyStyle().txtstyle(
                              '${foodModel.name}', Colors.black, 16.0),
                          (!kIsWeb) ? photoGraphy() : Text(''),
                        ],
                      ),
                      inputName(),
                      iputDescription(),
                      groupinputPrice(),
                      showRating(foodModel),
                      autonotautofavor(),
                      (flagAuto == 'N') ? inputRating() : Row(),
                      saveButton()
                    ],
                  ),
                )));
  }

  Row groupinputPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        inputPrice(),
        (foodModel.flagSp == 'Y') ? inputPriceSp() : Row(),
      ],
    );
  }

  Row autonotautofavor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Transform.scale(
          scale: 1.8,
          child: Radio(
            value: 'Y',
            groupValue: flagAuto,
            onChanged: (value) {
              setState(() {
                flagAuto = value;
              });
            },
          ),
        ),
        MyStyle().txtbody('อัตโนมัติ'),
        SizedBox(width: 30),
        Transform.scale(
            scale: 1.8,
            child: Radio(
              value: 'N',
              groupValue: flagAuto,
              onChanged: (value) {
                setState(() {
                  flagAuto = value;
                });
              },
            )),
        MyStyle().txtbody('กำหนดเอง'),
      ],
    );
  }

  Widget displayImage() {
    if (_imageFile == null) {
      return Text("กรุณาเลือกรูปภาพ");
    } else {
      return Image.file(imgFile, width: 200, height: 200);
    }
  }

  Widget xxxgalleryPickup() => Container(
      margin: const EdgeInsets.only(top: 3, left: 3),
      width: 105,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () async {
          gllery = 'Y';
          var pickedFile = await imgPicker.getImage(
              source: ImageSource.gallery, maxWidth: 200, maxHeight: 200);
          if (pickedFile != null) {
            setState(() {
              _imageFile = pickedFile;
              imgFile = io.File(pickedFile.path);
            });
          }
        },
        label: Text('คลังภาพ',
            style: TextStyle(
              fontFamily: 'thaisanslite',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
        icon: Icon(
          Icons.photo,
          color: Color.fromARGB(255, 60, 212, 250),
          size: 32,
        ),
        splashColor: Colors.blue,
      ));

  Widget xxxphotoGraphy() => Container(
        margin: const EdgeInsets.only(top: 25, left: 3),
        width: 105,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          onPressed: () async {
            gllery = 'N';
            takePhoto(ImageSource.camera, 200.0, 200.0); //480.0, 640.0
          },
          label: Text('กล้อง',
              style: TextStyle(
                fontFamily: 'thaisanslite',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              )),
          icon: Icon(
            Icons.camera,
            color: Colors.lightGreenAccent[400],
            size: 32,
          ),
          splashColor: Colors.blue,
        ),
      );

  Widget galleryPickup() => Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: IconButton(
          tooltip: 'Pick Image from Gallery',
          icon: Icon(Icons.photo,
              size: 48), // color: Color.fromARGB(255, 60, 212, 250),),
          onPressed: () async {
            gllery = 'Y';
            var pickedFile = await imgPicker.getImage(
                source: ImageSource.gallery, maxWidth: 200, maxHeight: 200);
            if (pickedFile != null) {
              imgFile = io.File(pickedFile.path);

              var resultCrop = await ImageCropper().cropImage(
              sourcePath: imgFile.path,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
              androidUiSettings: const AndroidUiSettings(
                  toolbarTitle: 'Cropper',
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false),
              iosUiSettings: const IOSUiSettings(
                minimumAspectRatio: 1.0,
              ));
            
              setState(() {
                _imageFile = pickedFile;
                imgFile = io.File(resultCrop.path);
              });
            }
          },
        ),
      );

  Widget photoGraphy() => Container(
        margin: const EdgeInsets.only(right: 15.0, bottom: 5.0),
        child: IconButton(
          tooltip: 'Pick Image from Gallery',
          icon: Icon(Icons.camera, size: 48),
          onPressed: () async {
            gllery = 'N';
            takePhoto(ImageSource.camera, 200.0, 200.0); //480.0, 640.0
          },
        ),
      );

  Widget foodDetailImageWidget() {
    //final CartStateController cartStateController = Get.find();
    //final FoodDetailStateController foodDetailStateController = Get.find();

    screenH = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          width: double.infinity, //= max width
          height: (screenH / 3.2),
          margin: EdgeInsets.only(left: 8.0, right: 8.0),
          child: new Hero(
              tag: 'img-${foodModel.name}',
              child: CachedNetworkImage(
                imageUrl:
                    'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${foodModel.image}',
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  //height: 200, width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
        ),
        Align(
          alignment: const Alignment(
              0.8, 0.0), //ปุ่ม faverit / cart ห่างจาก  x ?, ขอบล่าง
          heightFactor: 0.5,
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              //ปุ่ม faverit / cart ห่างจาก ขอบซ้ายขวา
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: 'hero_glleryTag',
                    onPressed: () async {
                      gllery = 'Y';
                      var pickedFile = await imgPicker.getImage(
                          source: ImageSource.gallery,
                          maxWidth: 300,
                          maxHeight: 400);
                      if (pickedFile != null) {
                        setState(() {
                          _imageFile = pickedFile;
                          imgFile = io.File(pickedFile.path);
                          //* context.read(imgstate.imageProvider).state = pickedFile.path;
                          //* context.read(uploadState).state = STATE.PICKED;
                        });
                      }
                    },
                    child: Icon(
                      Icons.photo,
                      size: 48,
                      color: Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 5,
                  ),
                  MyStyle().txtstyle('${foodModel.name}', Colors.black, 16.0),
                  FloatingActionButton(
                    heroTag: 'hero_photo',
                    onPressed: () async {
                      gllery = 'N';
                      takePhoto(
                          ImageSource.camera, 300.0, 400.0); //480.0, 640.0
                    },
                    child: Icon(
                      Icons.camera,
                      color: Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 5,
                  )
                ],
              )),
        )
      ],
    );
  }

  Row showRating(FoodModel fmodel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyStyle().txtstyle('ความนิยม', Colors.black, 12.0),
        RatingBarIndicator(
            rating: fmodel.favorite,
            itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber[400],
                ),
            itemCount: 5,
            itemSize: 38.0,
            direction: Axis.horizontal),
      ],
    );
  }

  Row inputRating() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      RatingBar.builder(
        initialRating: (flagAuto == 'N') ? manFavor : foodModel.favorite,
        minRating: 1,
        maxRating: 5,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemBuilder: (context, _) {
          return Icon(
            Icons.favorite,
            color: Colors.pink[400],
          );
        },
        itemSize: 36.0,
        onRatingUpdate: (value) {
          setState(() {
            manFavor = value;
          });
        },
        itemCount: 5,
      ),
      // ratingWidget: RatingWidget(
      //   full: _image('assets/heart.png'),
      //   half: _image('assets/heart_half.png'),
      //   empty: _image('assets/heart_border.png'),
      // ),
    ]);
  }

  Expanded watchState() {
    return Expanded(
      child: Consumer(
        builder: (context, watch, _) {
          final _imageUri = watch(imgstate.imageProvider).state;
          final _uploadState = watch(uploadState).state;
          //final _message = watch(resultProvider).state;
          return _imageUri == null
              ? Center(child: MyStyle().txtbodyTH('ไม่พบรูปภาพ'))
              : _uploadState == STATE.NORMAL
                  ? Center(child: MyStyle().txtbodyTH('กรุณาเลือกรูปภาพ'))
                  : _uploadState == STATE.PICKED
                      ? Image.file(io.File(_imageUri))
                      : _uploadState == STATE.ERROR
                          ? Center(
                              child: MyStyle()
                                  .txtbodyTH('มีปัญหาขณะอัพโหลดรูปภาพ'))
                          : _uploadState == STATE.SUCCESS
                              ? Center(child: Text('อัพโหลดรูปภาพเรียบร้อย'))
                              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget inputName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: screen * 0.95,
            child: TextFormField(
              initialValue: _txtName,
              onChanged: (value) => txtName = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ชื่อสินค้า',
                prefixIcon: Icon(Icons.qr_code, color: MyStyle().darkcolor),
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

  Widget iputDescription() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5),
            width: screen * 0.95,
            child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                initialValue: _txtDescription,
                onChanged: (value) => txtDescription = value.trim(),
                decoration: InputDecoration(
                  labelStyle: MyStyle().myLabelStyle(),
                  labelText: 'รายละเอียด',
                  prefixIcon:
                      Icon(Icons.short_text, color: MyStyle().darkcolor),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().darkcolor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  height: 1.5,
                )),
          )
        ],
      );

  Widget inputPrice() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            //alignment: Alignment.center,
            margin: EdgeInsets.only(top: 5, left: 8),
            width: screen * 0.45,
            child: TextFormField(
              //textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              initialValue: _txtPrice,
              onChanged: (value) => txtPrice = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ราคา',
                prefixIcon:
                    Icon(Icons.attach_money, color: MyStyle().darkcolor),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().lightcolor),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyStyle().darkcolor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      );

  Widget inputPriceSp() => Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, right: 8),
            width: screen * 0.45,
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: _txtPriceSp,
              onChanged: (value) => txtPriceSp = value.trim(),
              decoration: InputDecoration(
                labelStyle: MyStyle().myLabelStyle(),
                labelText: 'ราคาพิเศษ',
                prefixIcon:
                    Icon(Icons.attach_money, color: Colors.redAccent[700]),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().lightcolor),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent[700]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          )
        ],
      );

  Widget saveButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            margin: const EdgeInsets.all(5),
            width: screen * 0.5,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (txtName != '') {
                  String valid = await checkDupItem();
                  if (valid == '') {
                    await saveImage();
                    await saveData();
                    readExistItem(fModel.id);
                    //setState(() {
                    // double price = (txtPrice?.isEmpty ?? true) ? 0
                    //         : double.parse(txtPrice);
                    // double priceSp =(txtPriceSp?.isEmpty ?? true) ? 0
                    //         : double.parse(txtPriceSp);
                    // double manfav = (manFavor != null) ? manFavor : 0;

                    // fModel.name = txtName;
                    // fModel.description = txtDescription;
                    // fModel.price = price;
                    // fModel.priceSp = priceSp;
                    // fModel.auto = autofavor;
                    // if (autofavor == 'N') {
                    //   fModel.favorite = manFavor;
                    // } else {
                    //   fModel.favorite = double.parse(firstfavor);
                    // }
                    // fModel.manfavor = manfav;
                    // //fModel.id =
                    // //fModel.image =
                    // foodListStateController.selectedFood.value = fModel;
                    //});

                    //MaterialPageRoute route = MaterialPageRoute(
                    //builder: (context) => ShopFoodCategoryScreen());
                    //Navigator.push(context, route);
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        MySnackBar.showSnackBar(valid, Icons.sick,
                            strDimiss: 'ลองใหม่'),
                      );
                  }
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      MySnackBar.showSnackBar(
                          "กรุณาระบุข้อมูล\r\nชื่อสินค้า", Icons.contact_phone,
                          strDimiss: 'ลองใหม่'),
                    );
                }
              },
              icon: Icon(Icons.cloud_done, color: Colors.white),
              label: MyStyle().txtTH('บันทึกข้อมูล', Colors.white),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(2)),
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Color.fromARGB(255, 46, 180, 241);
                    return MyStyle().savecolor; // Use the component's default.
                  },
                ),
              ),
            ))
      ]);

  Future<Null> saveData() async {
    bool ok = true;
    String price = (txtPrice?.isEmpty ?? true) ? '0' : txtPrice;
    String priceSp = (txtPriceSp?.isEmpty ?? true) ? '0' : txtPriceSp;
    String manfav = (manFavor != null) ? manFavor.toString() : '0';

    try {
      String url = '${MyConstant().apipath}.${MyConstant().domain}/' +
          'shop/updateItem.aspx?ccode=$ccode&iid=${foodModel.id}&iname=$txtName' +
          '&idescription=$txtDescription&price=$price&priceSp=$priceSp' +
          '&auto=$flagAuto&manfavor=$manfav';

      dio.Response response = await dio.Dio().get(url);
      if (response.toString() != '') {
        ok = false;
      }
    } catch (ex) {
      ok = false;
    }
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          InfoSnackBar.infoSnackBar('บันทึกข้อมูลเรียบร้อย',
              Icons.sentiment_satisfied_alt), //tackface
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar('!บันทึกข้อมูลไม่สำเร็จ', Icons.sick),
        );
    }
  }

  Future<Null> saveImage() async {
    bool saveImage = true;
    if (_imageFile != null) {
      try {
        // context.read(uploadState).state = STATE.UPLOAD;
        // String filePath =
        //     gllery == 'Y' ? context.read(imgstate.imageProvider).state : _imageFile.path;

        String filePath = imgFile.path;
        String fname = foodModel.image.split('.')[0];

        var imageUri =
            await uploadImageItem(physicalpath, ccode, filePath, 'Y', fname);
        if (imageUri != null) {
          //context.read(uploadState).state = STATE.SUCCESS;
          //context.read(resultProvider).state = imageUri;
          imageCache.clear();
        } else {
          //context.read(uploadState).state = STATE.ERROR;
          saveImage = false;
        }
      } catch (e) {
        saveImage = false;
      }
    }
    if (!saveImage) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          MySnackBar.showSnackBar('!บันทึกข้อมูล/รูปภาพไม่สำเร็จ', Icons.sick),
        );
    }
  }

  Future<Null> takePhoto(
      ImageSource source, double maxWidth, double maxHeight) async {
    try {
      var pickedFile = await imgPicker.getImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        imgFile = io.File(pickedFile.path);
        //*** _image = io.File(_imageFile.path);
        //* context.read(imgstate.imageProvider).state = pickedFile.path;
        //* context.read(uploadState).state = STATE.PICKED;

        var resultCrop = await ImageCropper().cropImage(
            sourcePath: imgFile.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
            androidUiSettings: const AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: const IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));

        setState(() {
          _imageFile = pickedFile;
          imgFile = io.File(resultCrop.path);
        });
      }
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  Future<String> checkDupItem() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/shop/checkDupItem.aspx?ccode=$ccode&iid=${foodModel.id}&iname=$txtName';

    String mess = 'ข้อมูลไม่ถูกต้อง';
    try {
      await dio.Dio().get(url).then((value) {
        if (value != null && value.toString() == '') {
          mess = '';
        } else {
          var result = json.decode(value.data);
          for (var map in result) {
            MessModel mModel = MessModel.fromJson(map);
            mess = mModel.mess;
          }
        }
      });
    } catch (e) {
      mess = '!ติดต่อServer ไม่ได้';
    }
    return mess;
  }

  Future<Null> getPhycicalImagefolder() async {
    String url = '${MyConstant().apipath}.${MyConstant().domain}' +
        '/getfolderimage.aspx';

    physicalpath =
        'D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\product\\';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      if (result != null && result != '') {
        for (var map in result) {
          setState(() {
            PhyImgModel pModel = PhyImgModel.fromJson(map);
            physicalpath = pModel.imageItem;
          });
        }
      } else {
        setState(() {
          //
        });
      }
    });
  }
}
