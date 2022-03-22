import 'package:flutter/material.dart';

class InfoSnackBar {
  static SnackBar infoSnackBar(String message, IconData myicon) {
    return SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(myicon, color: Colors.white),
          SizedBox(width:3),
          Expanded(child: Text(message, style: TextStyle(
            fontFamily: 'thaisanslite',
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          )))
        ],      
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: (Colors.amber),
      action: SnackBarAction(
        label: 'รับทราบ', 
        textColor: Colors.black,        
        onPressed: () {
        },
      ),
    );
  }
}
