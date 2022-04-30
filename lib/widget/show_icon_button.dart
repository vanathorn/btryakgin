import 'package:flutter/material.dart';

class ShowIconButton extends StatelessWidget {
  final IconData iconData;
  final Function() pressFunc;

  ShowIconButton({
    Key key,
    @required this.iconData,
    @required this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: pressFunc,
      icon: Icon(iconData),
    );
  }
}
