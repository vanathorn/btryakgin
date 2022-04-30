import 'package:yakgin/utility/my_constant.dart';
import 'package:http/http.dart' as http;

//*** physicalpath = D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\member\\
Future<String> uploadImageMember(
    String physicalpath, String mbid, String filePath, String chkfile) async {
  http.MultipartRequest request = new http.MultipartRequest(
      "POST",
      Uri.parse('${MyConstant().imageapi}/' +
          'api/upload?dirpath=$physicalpath&fname=$mbid&chkfile=$chkfile'));

  http.MultipartFile multipartFile =
      await http.MultipartFile.fromPath('file', filePath);

  request.files.add(multipartFile);
  var headers = {"content-type": "multipart/form-data"};
  request.headers.addAll(headers);

  var response = await request.send();
  if (response.statusCode == 200) {
    final responseString = await response.stream.bytesToString();
    return responseString;
  } else {
    return null;
  }
}

//*** physicalpath = D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\shop\\
Future<String> uploadImageShop(String physicalpath, String ccodebr, 
    String filePath, String chkfile) async {
  http.MultipartRequest request = new http.MultipartRequest(
      "POST",
      Uri.parse('${MyConstant().imageapi}/' +
          'api/upload?dirpath=$physicalpath&fname=$ccodebr&chkfile=$chkfile'));

  // http.MultipartRequest request = new http.MultipartRequest(
  //     "POST", Uri.parse('http://10.0.2.2:5000/api/upload'));

  http.MultipartFile multipartFile =
      await http.MultipartFile.fromPath('file', filePath);

  request.files.add(multipartFile);
  var headers = {"content-type": "multipart/form-data"};
  request.headers.addAll(headers);

  var response = await request.send();
  if (response.statusCode == 200) {
    final responseString = await response.stream.bytesToString();
    return responseString;
  } else {
    return null;
  }
}

//*** physicalpath = D:\\Inetpub\\vhosts\\yakgin.com\\httpdocs\\Images\\product\\
Future<String> uploadImageItem(String physicalpath, String ccode,
    String filePath, String chkfile, String fname) async {
  http.MultipartRequest request = new http.MultipartRequest(
      "POST",
      Uri.parse('${MyConstant().imageapi}/' +
          'api/upload?dirpath=$physicalpath' +
          '$ccode\\' +
          '&fname=$fname&chkfile=$chkfile'));

  http.MultipartFile multipartFile =
      await http.MultipartFile.fromPath('file', filePath);

  request.files.add(multipartFile);
  var headers = {"content-type": "multipart/form-data"};
  request.headers.addAll(headers);

  var response = await request.send();
  if (response.statusCode == 200) {
    final responseString = await response.stream.bytesToString();
    return responseString;
  } else {
    return null;
  }
}
