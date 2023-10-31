import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class SphereAnimationView extends StatefulWidget {
  const SphereAnimationView({Key? key}) : super(key: key);

  @override
  _SphereAnimationViewState createState() => _SphereAnimationViewState();
}

class _SphereAnimationViewState extends State<SphereAnimationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _lastOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  double _radius = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final Matrix4 transform = Matrix4.identity()
            ..rotateY(vector.radians(_currentOffset.dx))
            ..rotateX(vector.radians(_currentOffset.dy))
            ..translate(
              _currentOffset.dx / 10.0,
              _currentOffset.dy / 10.0,
              -_radius,
            );
          return Transform(
            transform: transform,
            child: Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue, Colors.black],
                  center: Alignment(-0.5, -0.6),
                  radius: 0.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _lastOffset = details.globalPosition;
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _currentOffset += details.globalPosition - _lastOffset;
    _lastOffset = details.globalPosition;
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    _lastOffset = Offset.zero;
    _currentOffset = Offset.zero;
    _controller.reset();
    _controller.forward();
  }
}
