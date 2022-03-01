import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class MyCalculate{
  
  double foodDetailImageAreaSize(BuildContext context){
    return MediaQuery.of(context).size.height/3.0;
  }
  double calculateDistance(double lat1, double lng1, double latShop, double lngShop) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((latShop - lat1) * p) / 2 +
        c(lat1 * p) * c(latShop * p) * (1 - c((lngShop - lng1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));

    return distance;
  }

  int calculateLogistic(double distance, int startLogist){
    int logistcost;
    if (distance < 1.0){
      logistcost = startLogist;
    }else{
      logistcost =  startLogist+((distance-1).ceil()*10); //ceil=ปัดขึ้น  floor=ปัดทิ้งลง  round=ปัด 0.5
    }
    return logistcost;
  }

  String calculateTime(double distance){
    String strTime;
    if (distance < 11.0){
      strTime = '30 นาที';
    }else if (distance < 21.0){
      strTime = '45 นาที';
    }else if (distance < 51.0){
      strTime = '1 ชม.';
    }else if (distance < 101.0){
      strTime = '2 ชม.';
    }else{
      strTime = '3 ชม.';
    }
    return strTime;
  }

  String checkTime(DateTime curDt, String hrmm, double distance){
    String error='';
    double curhr= double.parse(curDt.hour.toString());
    double curmi= double.parse(curDt.minute.toString());
    double sendhr = double.parse(hrmm.split(':')[0]);
    double sendmi = double.parse(hrmm.split(':')[1]);
    double ttlMin = (sendhr-curhr)*60 + (sendmi-curmi);
    //print('****************** current hr  mi = $curhr   $curmi');
    //print('****************** sending hr  mi = $sendhr  $sendmi');
    //print('============= ttlMin = $ttlMin');
    if (distance < 11.0){
      if (ttlMin < 30.0){
         error='เวลาต้องไม่ต่ำกว่า 30 นาที';
      }      
    }else if (distance < 21.0){
      if (ttlMin < 45.0){
         error='เวลาต้องไม่ต่ำกว่า 45 นาที';
      }      
    }else if (distance < 51){
      if (ttlMin < 60.0){
         error='เวลาต้องไม่ต่ำกว่า 1 ชม.';
      }    
      // if ((sendhr-curhr>2) || ((sendhr-curhr==2) && ((sendmi-curmi)+1>0))){
      //   //ok
      // }else{
      //    error='เวลาต้องไม่ต่ำกว่า 1 ชม.';
      // }
    }else if (distance < 101){
      if (ttlMin < 120.0){
         error='เวลาต้องไม่ต่ำกว่า 2 ชม.';
      }  
      //if ((sendhr-curhr>1) || ((sendhr-curhr==1) && ((sendmi-curmi)+1>0)) ){  
    }else{
      if (ttlMin < 180.0){
         error='เวลาต้องไม่ต่ำกว่า 3 ชม.';
      }  
      // if ((sendhr-curhr>3) || ((sendhr-curhr==3) && ((sendmi-curmi)+1>0))){ 
    }
    return error;
  }
  
  Future<LocationData> findLocationData() async {
    Location location = Location();
    try{
      return await location.getLocation();
    }catch (ex){
      return null;
    }
  }

  String fmtNumber(double decData){
    String result;
    var myFmt = NumberFormat('###,##0.##','en_US');
    result = myFmt.format(decData);
    return result;
  }

  String fmtNumberBath(double decData){
    String result;
    var myFmt = NumberFormat('###,##0.##','en_US');
    result = myFmt.format(decData) + ' ฿';
    return result;
  }

  final currencyFormat =  NumberFormat.simpleCurrency();
}