import 'dart:math';

import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _PageState();
}

class _PageState extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("新页面"),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Column(
      children: const [
        MyCircleView(),
        // _child1(),
      ],
    );
  }
}

class MyCircleView extends StatefulWidget {
  const MyCircleView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyCircleViewState();
  }
}

class MyCircleViewState extends State<MyCircleView>
    with SingleTickerProviderStateMixin {
  double radius = 100.0 - 30.0;
  var list = <MyPoint>[];
  late Animation<double> animation;
  late AnimationController animatedController;
  var prevAngle = 0.0, angleDelta = 0.0;

  MyPoint rotateAxis = MyPoint(x: 0, y: 1, z: 0, color: Colors.white54); //初始为Y轴
  @override
  void initState() {
    super.initState();
    _initPoints();
    animatedController =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);
    animation =
        Tween<double>(begin: 0.0, end: pi * 2).animate(animatedController)
          ..addListener(() {
            setState(() {
              var angle = animation.value;
              angleDelta = angle - prevAngle; //这段时间内旋转过的角度
              prevAngle = angle;
              setState(() {
                _rotatePoints(list, rotateAxis, angleDelta);
              });
              // radius = animation.value * radius;
            });
          });
    animatedController.repeat();
  }

  @override
  void dispose() {
    animatedController.dispose();
    super.dispose();
  }

  void _initPoints() {
    for (var i = 0; i < 20; i++) {
      final x = Random().nextDouble() * 1 * (Random().nextBool() ? 1 : -1);
      double remains = sqrt(1 - x * x);

      final y = remains *
          Random().nextDouble() *
          (Random().nextBool() == true ? 1 : -1);

      double z =
          sqrt(1 - x * x - y * y) * (Random().nextBool() == true ? 1 : -1);

      var colorA = z > 0 ? 255 : (50 + ((255 - 50) * (z.abs()))).toInt();
      list.add(MyPoint(
          x: x,
          y: y,
          z: z,
          color: Color.fromARGB(colorA, Random().nextInt(255),
              Random().nextInt(255), Random().nextInt(255))));
    }
  }

  _rotatePoints(List<MyPoint> points, MyPoint axis, double angle) {
    //罗德里格旋转矢量公式
    //计算点 x,y,z 绕轴axis转动angle角度后的新坐标

    //预先缓存不变值，如sin，cos等，避免重复计算
    var a = axis.x,
        b = axis.y,
        c = axis.z,
        a2 = a * a,
        b2 = b * b,
        c2 = c * c,
        ab = a * b,
        ac = a * c,
        bc = b * c,
        sinA = sin(angle),
        cosA = cos(angle);
    for (var point in points) {
      var x = point.x, y = point.y, z = point.z;
      point.x = (a2 + (1 - a2) * cosA) * x +
          (ab * (1 - cosA) - c * sinA) * y +
          (ac * (1 - cosA) + b * sinA) * z;
      point.y = (ab * (1 - cosA) + c * sinA) * x +
          (b2 + (1 - b2) * cosA) * y +
          (bc * (1 - cosA) - a * sinA) * z;
      point.z = (ac * (1 - cosA) - b * sinA) * x +
          (bc * (1 - cosA) + a * sinA) * y +
          (c2 + (1 - c2) * cosA) * z;

      var colorA =
          z > 0 ? 255 : (20 + ((255 - 20) * (1 - point.z.abs()))).toInt();

      point.color.withAlpha(colorA);
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f5f5),
      child: GestureDetector(
        onPanUpdate: (dragUpdateDetails) {
          var dx = dragUpdateDetails.delta.dx, dy = dragUpdateDetails.delta.dy;
          //正则化，使轴向量长度为1
          var sqrtxy = sqrt(dx * dx + dy * dy);
          //避免除0
          if (sqrtxy > 4) {
            rotateAxis = MyPoint(
                x: -dy / sqrtxy, y: dx / sqrtxy, z: 0, color: Colors.white54);
          }
        },
        child: CustomPaint(
          size: const Size(200, 200),
          painter: MyCustomPaint(radius: radius, list: list),
        ),
      ),
    );
  }
}

class MyCustomPaint extends CustomPainter {
  final paint1 = Paint()..color = Colors.red;

  var radius = 100.0 - 20.0;

  var list = [];

  MyCustomPaint({required this.radius, required this.list});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < list.length; i++) {
      MyPoint point = list[i];

      paint1.color = point.color;

      double scale = _getScale(point.z);
      canvas.drawCircle(
          Offset(point.x * radius, point.y * radius), scale * 10, paint1);
    }
  }

  double _getScale(double z) {
    //使用z坐标设置标签大小，制造距离感
    //从[-1,1]区间转移到[1/4,1]区间
    //背面最小时为正面1/16大小
    return z * 3 / 8 + 5 / 8;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyPoint {
  double x, y, z;
  Color color;
  MyPoint(
      {required this.x, required this.y, required this.z, required this.color});
}
