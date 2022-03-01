//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:btryakgin/utility/mystyle.dart';

class HomeMenuClass extends StatelessWidget {
  final ZoomDrawerController zoomDrawerController;
  HomeMenuClass(this.zoomDrawerController);

  @override
  Widget build(BuildContext context) {
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
                Icons.home,
                color: Colors.black,
                size: 32.0,
              ),
              SizedBox(
                width: 10,
              ),
              MyStyle().txtTH18Dark('โฮม (รายละเอียด)')
            ],
          ),
        ));
  }
}
