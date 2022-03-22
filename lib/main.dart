import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yakgin/router.dart';
//import 'package:get_storage/get_storage.dart';
//vtr after upgrade  import 'package:flutter_riverpod/all.dart';


String initialRoute = '/home';
Future<Null> main() async {
  //***** แก้ปัญหา Certificate Verify Failed on Flutter Connected ms SQL
  //CERTIFICATE_VERIFY_FAILED: unable to get local issuer
  //certificate(handshake.cc:354)

  WidgetsFlutterBinding.ensureInitialized();
  try {
    HttpOverrides.global = MyHttpOverrides();
    /*--  err-firebase await GetStorage.init(); */
    await Firebase.initializeApp();
  } catch (ex) {
    debugPrint('**** main Error : Firebase.initializeApp() ' + ex.toString());
  }
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //theme: ThemeData(primarySwatch: Colors.lightBlue),
      routes: routes,
      initialRoute: initialRoute,
    );
  }
}

//***** แก้ปัญหา Certificate Verify Failed on Flutter Connected ms SQL
//CERTIFICATE_VERIFY_FAILED: unable to get local issuer
//certificate(handshake.cc:354)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
