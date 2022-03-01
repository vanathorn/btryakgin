import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:btryakgin/model/cart_model.dart';
//import 'package:btryakgin/state/cart_state.dart';
import 'package:btryakgin/utility/my_constant.dart';

class CartImageWidget extends StatelessWidget {
  const CartImageWidget({Key key, @required this.cartModel}) : super(key: key);

  final CartModel cartModel;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl:
          '${MyConstant().domain}/${MyConstant().fixwebpath}/${MyConstant().imagepath}/${cartModel.ccode}/${cartModel.image}',
      fit: BoxFit.cover,
      errorWidget: (context, url, err) => Center(
        child: Icon(Icons.image),
      ),
      progressIndicatorBuilder: (context, url, dowloadProgress) =>
          Center(child: CircularProgressIndicator()),
    );
  }
}
