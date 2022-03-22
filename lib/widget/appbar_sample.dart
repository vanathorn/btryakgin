import 'package:flutter/material.dart';
import 'package:yakgin/screen/menu/multi_home.dart';
import 'package:yakgin/utility/mystyle.dart';

class AppBarSampleButton extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  AppBarSampleButton({this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              MaterialPageRoute route =
                  MaterialPageRoute(builder: (value) => MultiHome());
              Navigator.push(context, route);
            },
            child: MyStyle().titleLight('เมนู'),
          ),
          Container(
              child: MyStyle()
                  .txtTH18Color(title, Color.fromARGB(255, 154, 248, 3)))
        ],
      ),
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      /*
      actions: [
          Badge(
              position: BadgePosition(top:8, end:20),
              animationDuration: Duration(milliseconds: 200),
              animationType: BadgeAnimationType.scale,
              badgeColor: Colors.limeAccent,
              badgeContent: Text(
                '',
                style:GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(right:50.0),
                child: IconButton(                
                  icon: Icon(Icons.person_pin, color: Colors.black,),   //icoms.couter_top
                  onPressed: () {
                    
                  }
                ),             
              ),
          ),
      ],
      */
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(46.0);
}
