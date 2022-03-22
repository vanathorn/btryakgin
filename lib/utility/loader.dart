import 'dart:math';
//https://www.youtube.com/watch?v=KdQhPoquekc

import 'package:flutter/material.dart';

class Loader extends StatefulWidget {
  final bool isMount;
  Loader({Key key, this.isMount: true}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  // ignore: non_constant_identifier_names
  Animation<double> animation_rotation;
  // ignore: non_constant_identifier_names
  Animation<double> animation_radius_in;
  // ignore: non_constant_identifier_names
  Animation<double> animation_radius_out;

  final double initialRadius = 20.0;
  double radius = 0.0;
  bool isMount;

  @override
  void initState() {
    super.initState();
    isMount = widget.isMount;
    try {
      controller =
          AnimationController(vsync: this, duration: Duration(seconds: 5));
      animation_rotation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
          parent: controller, curve: Interval(0.0, 1.0, curve: Curves.linear)));
      //fastLinearToSlowEaseIn
      animation_radius_in = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
              parent: controller,
              curve: Interval(0.75, 1.0, curve: Curves.elasticIn)));

      animation_radius_out = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: controller,
              curve: Interval(0.0, 0.25, curve: Curves.elasticOut)));

      controller.addListener(() {       
        if (controller.value >= 0.75 && controller.value <= 1.0) {
            radius = animation_radius_in.value * initialRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
            radius = animation_radius_out.value * initialRadius;
        }       
        if (isMount) {
          setState(() {
            //
          });
        }
      });
      controller.repeat();
    } catch (ex) {
      //
    }
  }

  @override
  void dispose() {
    try {
      isMount = false;
      controller.dispose();
      super.dispose();
    } catch (ex) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 100,
        child: Center(
          child: RotationTransition(
            turns: animation_rotation,
            child: Stack(
              children: <Widget>[
                Dot(radius: 28.0, color: Colors.transparent),
                Transform.translate(
                    offset: Offset(radius * cos(pi / 5), radius * sin(pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 245, 3, 3))),
                Transform.translate(
                    offset: Offset(
                        radius * cos(2 * pi / 5), radius * sin(2 * pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 4, 247, 4))),
                Transform.translate(
                    offset: Offset(
                        radius * cos(3 * pi / 5), radius * sin(3 * pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 2, 53, 141))),
                Transform.translate(
                    offset: Offset(
                        radius * cos(4 * pi / 5), radius * sin(4 * pi / 5)),
                    child: Dot(radius: 5.0, color: Colors.amber)),
                Transform.translate(
                    offset: Offset(
                        radius * cos(5 * pi / 5), radius * sin(5 * pi / 5)),
                    child: Dot(radius: 5.0, color: Colors.pink)),
                Transform.translate(
                    offset: Offset(
                        radius * cos(6 * pi / 5), radius * sin(6 * pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 255, 102, 0))),
                Transform.translate(
                    offset: Offset(
                        radius * cos(7 * pi / 5), radius * sin(7 * pi / 5)),
                    child: Dot(radius: 5.0, color: Colors.lightGreenAccent)),
                Transform.translate(
                    offset: Offset(
                        radius * cos(8 * pi / 5), radius * sin(8 * pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 164, 17, 250))),
                Transform.translate(
                    offset: Offset(
                        radius * cos(9 * pi / 5), radius * sin(9 * pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 250, 227, 17))),
                Transform.translate(
                    offset: Offset(
                        radius * cos(10 * pi / 5), radius * sin(10 * pi / 5)),
                    child: Dot(
                        radius: 5.0, color: Color.fromARGB(255, 250, 17, 172))),
              ],
            ),
          ),
        ));
  }
}

class Dot extends StatelessWidget {
  final double radius;
  final Color color;
  Dot({this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(
          color: this.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
