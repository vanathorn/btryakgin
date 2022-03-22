import 'package:get/get.dart';
import 'package:yakgin/model/ddl_model.dart';

class ProvDetailStateController extends GetxController {
  int provno = 0;
  int ampherno = 0;
  int tambonno = 0;
  String provname = '';
  String amphername = '';
  String tambonname = '';
  var selectProv = DDLModel(id: 0, txtvalue:'').obs;
  var selectAmpher = DDLModel(id: 0, txtvalue:'').obs;
  var selectTambon = DDLModel(id: 0, txtvalue:'').obs;
}
