import 'package:flutter/material.dart';
import 'package:sql_conn/sql_conn.dart';

class SQLService {
  String ip = "103.129.15.68";
  String port = "1433";
  String dbName = "dbyakgin";
  String username = "yakgin";
  String password = "Y@212224";

  Future<void> connect() async {
    try {
      await SqlConn.connect(
          ip: ip,
          port: port,
          databaseName: dbName,
          username: username,
          password: password);
      debugPrint("read : Connected!");
    } catch (e) {
      debugPrint('Error ' + e.toString());
    }
  }

  Future<Null> clearConn() async {
    SqlConn.disconnect();
  }

  Future<void> execute(String query) async {
    var res = await SqlConn.writeData(query);
    debugPrint(res.toString());
  }

  List myList(String myvalue) {
    return myvalue
        .replaceAll("[{", "")
        .replaceAll("}]", "")
        .replaceAll('"', "")
        .split('},')
        .toList();
  }
}
