//vtr after upgrade import 'package:flutter/cupertino.dart';
//vtr after upgrade import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/screen/resturant.dart';
import 'package:btryakgin/utility/mystyle.dart';

class ResturantMenu extends StatelessWidget {
  final String menuName;
  final VoidCallback callback;
  final IconData icon;

  const ResturantMenu({Key key, this.icon, this.menuName, this.callback})
      : super(key: key);

  // ResturantMenu(
  //    {menuName, void Function() callback, IconData icon}
  // );

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => ResturantScreen())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32.0,
              ),
              SizedBox(
                width: 10,
              ),
              MyStyle().txtstyle(menuName, Colors.black, 20)
            ],
          ),
        ));
  }
}
