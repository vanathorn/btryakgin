import 'package:flutter/material.dart';
import 'package:yakgin/model/report_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/state/main_state.dart';
import 'package:yakgin/utility/my_constant.dart';
import 'package:yakgin/utility/mystyle.dart';
import 'package:yakgin/view/category_view_imp.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:yakgin/widget/shop/reports/order_sum_withappbar.dart';
import 'package:yakgin/widget/shop/reports/recivebr_sum_withappbar.dart';
import 'package:yakgin/widget/shop/reports/stockbr_sum_withappbar.dart';

class BranchReportScreen extends StatefulWidget {
  BranchReportScreen({Key key}) : super(key: key);
  @override
  _BranchReportScreenState createState() => _BranchReportScreenState();
}

class _BranchReportScreenState extends State<BranchReportScreen> {
  final MainStateController mainStateController = Get.find();
  ShopRestModel restModel;
  String ccode, brcode, strDistance;
  double screen;

  Location location = Location();
  final viewModel = CategoryViewImp();
  List<ReportModel> listReports = List<ReportModel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  Future<Null> getCategory() async {
    listReports.clear();
    setState(() {
      ReportModel fModels = new ReportModel();
      fModels.seq = '1';
      fModels.image = 'report1.jpg';
      fModels.name = 'รับสินค้ารายวัน';
      fModels.widget = ReciveBrSumAppbar();
      listReports.add(fModels);
      //categoryStateContoller = Get.put(CategoryStateContoller());
    });
    setState(() {
      ReportModel fModels = new ReportModel();
      fModels.seq = '2';
      fModels.image = 'report2.jpg';
      fModels.name = 'การซื้อรายวัน';
      fModels.widget = OrderSumAppbar();
      listReports.add(fModels);
    });
    setState(() {
      ReportModel fModels = new ReportModel();
      fModels.seq = '3';
      fModels.image = 'report3.jpg';
      fModels.name = 'สต๊อกสินค้า';
      fModels.widget = StockBrSumAppbar();
      listReports.add(fModels);
    });
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    getCategory();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SingleChildScrollView(
              child: (listReports != null && listReports.length > 0)
                  ? reportItems()
                  : MyStyle().showProgress())
        ],
      ),
    );
  }

  Expanded reportItems() {
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: listReports.toList().length,
            itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    // MaterialPageRoute route = MaterialPageRoute(
                    //     builder: (context) =>
                    //         listReports.toList()[index].widget);
                    // Navigator.pushAndRemoveUntil(
                    //     context, route, (route) => false);
                    Widget repwidget = listReports.toList()[index].widget;
                    MaterialPageRoute route =
                        MaterialPageRoute(builder: (value) => repwidget);
                    Navigator.push(context, route);
                  },
                  child: Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5),
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              margin: const EdgeInsets.all(3),
                              width: screen * 0.2,
                              child: CircleAvatar(
                                maxRadius: 28,
                                minRadius: 28,
                                backgroundImage: NetworkImage(
                                    'https://www.${MyConstant().domain}/${MyConstant().imagereportpath}/${listReports[index].image}'),
                              )),
                          Container(
                            color: MyStyle().coloroverlay,
                          ),
                          Container(
                              width: screen * 0.65,
                              margin: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyStyle().txtstyle(
                                      '${listReports.toList()[index].name}',
                                      Colors.black,
                                      14.0),
                                ],
                              ))
                        ]),
                  ),
                )));
  }
}
