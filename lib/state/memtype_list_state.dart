import 'package:yakgin/model/login_model.dart';
import 'package:get/get.dart';

class MemtypeListStateController extends GetxController {
  var selectedMember = LoginModel(
    mbtid: 0,
    mbtcode: 'code',
    mbtname: 'name',
    addonM: [],
  ).obs;
}
