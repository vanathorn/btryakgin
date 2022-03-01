import 'package:flutter/material.dart';

class MySnackBar {
  static SnackBar showSnackBar(String message, IconData myicon,
      {String strDimiss:'รับทราบ'}) {
    return SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(myicon, color: Colors.white),
          SizedBox(width: 3),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                    fontFamily: 'thaisanslite',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  )))
        ],
      ),
      duration: const Duration(seconds: 7),
      backgroundColor: (Colors.redAccent[700]),
      action: SnackBarAction(
        label: strDimiss,
        textColor: Colors.lightGreenAccent[400],
        onPressed: () {},
      ),
    );
  }
}
