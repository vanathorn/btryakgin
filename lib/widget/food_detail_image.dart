import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yakgin/model/food_model.dart';
import 'package:yakgin/model/shoprest_model.dart';
import 'package:yakgin/utility/my_constant.dart';

class FoodDetailImage extends StatefulWidget {
  final ShopRestModel restModel;
  final FoodModel foodModel;
  FoodDetailImage({Key key, this.restModel, this.foodModel}) : super(key: key);
  @override
  _FoodDetailImageState createState() => _FoodDetailImageState();
}

class _FoodDetailImageState extends State<FoodDetailImage> {
  ShopRestModel restModel;
  FoodModel foodModel;
  String ccode, strConn, webPath;
  double screenH;

  @override
  void initState() {
    super.initState();
    restModel = widget.restModel;
    foodModel = widget.foodModel;
    ccode = restModel.ccode;
    strConn = restModel.strconn;
    webPath = restModel.webpath;
  }

  @override
  Widget build(BuildContext context) {
    screenH = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
            //padding: EdgeInsets.all(2.0),
            width: double.infinity, //max width
            height: (screenH / 3.0) * 1.6,
            child: Hero(
              tag: foodModel.name,
              child: CachedNetworkImage(
                imageUrl:
                    'https://www.${MyConstant().domain}/${MyConstant().imagepath}/$ccode/${foodModel.image}',
                fit: BoxFit.cover,
              ),
            )),
        Align(
          //alignment: const Alignment(0.8, 1.0),
          //heightFactor: 0.5,
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(
                      Icons.favorite,
                      color: Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 10,
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 10,
                  )
                ],
              )),
        )
      ],
    );
  }
}
