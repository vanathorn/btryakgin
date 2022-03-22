//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/utility/mystyle.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  String name, email;
  Widget currentwidget; // = ShowGartoonList();

  @override
  void initState() {
    super.initState();
    findNameandEmail();
  }

  Future<Null> findNameandEmail() async {
    // await Firebase.initializeApp().then((value) async {
    //   FirebaseAuth.instance.authStateChanges().listen((event) async {
    //  setState(() {
    //  print('event.displayName = $event.displayName');
    name = 'Login Name'; //event.displayName;
    email = 'email'; //event.email;
    //  });
    //  });
    //  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().primarycolor,
      ),
      drawer: buildDrawer(),
      body: currentwidget,
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Stack(
        children: [
          Column(
            children: [
              builderUserAccountsDrawerHeader(),
              //buildShowGartoonList(),
              //buildShowInformation()
            ],
          ),
          //buildSignout(),
        ],
      ),
    );
  }

  UserAccountsDrawerHeader builderUserAccountsDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/wall.jpg'), fit: BoxFit.cover)),
      accountName: MyStyle().titleDrawer(email == null ? 'email' : email),
      accountEmail: MyStyle().subtitleDrawer(name == null ? 'Name' : name),
      //***** name คือ email  Email คือ  user  *****
      currentAccountPicture: Image.asset('images/motorcycle.jpg'),
    );
  }
}
