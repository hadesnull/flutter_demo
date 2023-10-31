import 'dart:math';

import 'package:flutter/material.dart';

class Custom3DSphereView extends StatefulWidget {
  @override
  _Custom3DSphereViewState createState() => _Custom3DSphereViewState();
}

class _Custom3DSphereViewState extends State<Custom3DSphereView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  late double _previousX;
  late double _previousY;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotateY += (details.globalPosition.dx - _previousX) / 100;
          _rotateX += (details.globalPosition.dy - _previousY) / 100;
        });
        _previousX = details.globalPosition.dx;
        _previousY = details.globalPosition.dy;
      },
      onPanStart: (details) {
        _previousX = details.globalPosition.dx;
        _previousY = details.globalPosition.dy;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.01)
              ..rotateX(_rotateX)
              ..rotateY(_rotateY)
              ..rotateZ(2 * pi * _animationController.value),
            alignment: FractionalOffset.center,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
