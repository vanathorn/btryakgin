import 'package:auto_animated/auto_animated.dart';
//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:yakgin/screen/menu/main_user.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/widget/commonwidget.dart';

class UserMenuClass extends StatelessWidget {
  final ZoomDrawerController zoomDrawerController;
  final List<String> listChooseType;
  UserMenuClass(this.zoomDrawerController, this.listChooseType);

  @override
  Widget build(BuildContext context) {
    double screen = MediaQuery.of(context).size.width;
    return Container(
        width: screen,
        child: LiveList(
          showItemInterval: Duration(milliseconds: 150),
          showItemDuration: Duration(milliseconds: 350),
          reAnimateOnVisibility: true,
          scrollDirection: Axis.vertical,
          itemCount: listChooseType.toList().length,
          itemBuilder: animationItemBuilder((index) => InkWell(
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => MainUser(),
                  );
                  Navigator.push(context, route);
                },
                child: Row(
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, bottom: 12, left: 3),
                      width: 150, height: 150,
                      child: MyStyle().txtbody('strtxt'),
                      // child: Stack(
                      //   fit: StackFit.expand,
                      //   children: [
                      //     Image.network('${MyConstant().apipath}.${MyConstant().domain}/Image/user.jpg')
                      //   ],
                      // ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
