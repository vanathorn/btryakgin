//vtr after upgrade import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:btryakgin/strings/my_string.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeShopWidget extends StatelessWidget {
  const HomeShopWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ZoomDrawerController().toggle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.list, color: Colors.white),
            SizedBox(width: 30),
            Text(
              categoryText,
              style: GoogleFonts.josefinSans(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
    );
  }
}
