import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:btryakgin/model/menu_model.dart';
import 'package:btryakgin/model/shop_model.dart';
import 'package:btryakgin/screen/menu/main_user.dart';
import 'package:btryakgin/utility/my_constant.dart';
import 'package:btryakgin/utility/mystyle.dart';
import 'package:btryakgin/utility/signOut.dart';
import 'package:btryakgin/view/menu_vm/menu_viewmodel_imp.dart';
import 'package:btryakgin/widget/home_menuclass.dart';

class MenuScreen extends StatelessWidget {
  final ShopModel shopModel;
  final List<MenuModel> listChooseType;
  final ZoomDrawerController zoomDrawerController;
  final viewModel = MenuViewModelImp();

  MenuScreen(this.zoomDrawerController, this.shopModel, this.listChooseType);

  @override
  Widget build(BuildContext context) {
    double screen = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            backgroundColor: MyStyle().primarycolor,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyStyle().titleDark('เลือกเมนูการทำงาน'),
                ])),
        body: Container(
            child: Column(children: [
          Container(
            height: 100.0,
            child: DrawerHeader(
                child: Container(
              //color: Colors.grey[200],
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius: (52),
                        backgroundColor: Colors.transparent,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: Image.asset("images/userlogo.png")),
                      )
                      /*
                          CircleAvatar(
                              maxRadius:64, minRadius: 64,
                              backgroundImage: NetworkImage(
                                '${MyConstant().domain}/${MyConstant().shopimagepath}/${shopModel.shoppict}',
                              ),
                              backgroundColor: Colors.transparent,                                                            
                              // child:Icon(
                              //   Icons.shop, color:MyStyle().icondrawercolor, size: 30,
                              // )
                          )*/
                    ]),
                    Row(
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: MyStyle().txtTH20Dark(
                                ('${shopModel.thainame}' != null)
                                    ? '${shopModel.thainame}'
                                    : '')),
                      ],
                    )
                  ]),
            )),
          ),
          HomeMenuClass(
              zoomDrawerController), //call from class หรือจะเรียกจาก Widget ภายในโปรแกรมนี่ testhomeMenuWidget
          //SizedBox(height:10.0),
          Expanded(
              flex: 7,
              child: ListView.builder(
                  itemCount: listChooseType.toList().length,
                  itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => MainUser()
                          MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) =>
                                  listChooseType.toList()[index].menuWidget);
                          Navigator.pushAndRemoveUntil(
                              context, route, (route) => false);
                        },
                        child: Card(
                          elevation: 8.0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 5),
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(5),
                                  width: screen * 0.2,
                                  child: CircleAvatar(
                                    maxRadius: 32, minRadius: 32,
                                    backgroundImage: NetworkImage(
                                        '${MyConstant().domain}/${MyConstant().apipath}/' +
                                            'Image/${listChooseType.toList()[index].menuImage}'),
                                    // child:Icon(
                                    //   Icons.shop, color:MyStyle().icondrawercolor, size: 30,
                                    // )
                                  ),
                                ),
                                Container(
                                  color: MyStyle().coloroverlay,
                                ),
                                Container(
                                    width: screen * 0.6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyStyle().txtstyle(
                                            '${listChooseType.toList()[index].menuName}',
                                            Colors.black,
                                            14.0),
                                      ],
                                    ))
                              ]),
                        ),
                      ))),

          Spacer(),
          Divider(thickness: 1, color: Colors.black12),
          signOutMenu(context),
        ])));
  }

  Widget seconedMenuWidget() {
    return InkWell(
        onTap: () {
          zoomDrawerController.toggle();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.list,
                color: Colors.white,
                size: 32.0,
              ),
              SizedBox(
                width: 10,
              ),
              Text('หน้าสอง',
                  style: TextStyle(
                    fontFamily: 'thaisanslite',
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ))
            ],
          ),
        ));
  }

  Widget signOutMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.red[600]),
      child: ListTile(
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          title: MyStyle().titleLight('ออกจากระบบ'),
          subtitle: MyStyle().subtitleLight('Back to home page.'),
          onTap: () => signOut(context)),
    );
  }

  ListTile memenuTypeUser(BuildContext context) => ListTile(
        leading: Icon(Icons.fastfood),
        title: MyStyle().txtTH20Dark('ร้านค้า'),
        subtitle: MyStyle().subtitleDark('ร้านค้าที่อยู่ในโครงการ'),
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => MainUser(),
          );
          Navigator.push(context, route);
        },
      );

  Card cardUser() {
    return Card(
      elevation: 10.0,
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                child: CircleAvatar(
                  maxRadius: 38,
                  minRadius: 38,
                  backgroundImage: NetworkImage(
                      '${MyConstant().domain}/${MyConstant().apipath}/Image/user.jpg'),
                ),
              )
            ],
          ),
          Row()
        ],
      ),
    );
  }

  Future<Null> routeToService(Widget myWidget, BuildContext context) async {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }
}
