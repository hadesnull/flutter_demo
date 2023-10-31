import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';
import 'dart:ui' as ui;
import 'image_util.dart';


class FaceRectanglePainter extends CustomPainter {

   ui.Image? images;

  FaceRectanglePainter(
    this.faces,
      this.imageSize,
      this.images
  );



  final Size imageSize;
  final List<Face> faces;

   final Paint paint1 = Paint()
     ..style = PaintingStyle.stroke
     ..strokeWidth = 1.0
     ..color = Colors.red;

   final Paint paint2 = Paint()
     ..style = PaintingStyle.fill
     ..strokeWidth = 1.0
     ..color = Colors.green;

   final textStyle = ui.TextStyle(
     color: Colors.black,
     fontSize: 10,
   );

   final paragraphStyle = ui.ParagraphStyle(
     textDirection: TextDirection.ltr,
   );

  @override
  void paint(Canvas canvas, Size size) async {


    for (final Face face in faces) {

      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        InputImageRotation.rotation0deg,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        InputImageRotation.rotation0deg,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        InputImageRotation.rotation0deg,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        InputImageRotation.rotation0deg,
      );

      // canvas.drawRect(
      //   Rect.fromLTRB(left, top, right, bottom),
      //   paint1,
      // );


      var ret = Rect.fromLTRB(left, top, right, bottom);
      final circleSize = max(images!.width.toDouble(), images!.height.toDouble());
      var srcRect = Rect.fromLTRB(0, 0, circleSize, circleSize);


      canvas.drawImageRect(images!, scaleRect(srcRect, 1), scaleRect(ret, 1.3), paint1);


      ///绘制文字

      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText('Hello, Flutter!');

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: size.width));

      final offset = Offset(ret.right - 20, ret.bottom - 20); // Text position
      canvas.drawParagraph(paragraph, offset);
    }
  }


   /**
    * 矩形等比例缩放
    */
   Rect scaleRect(Rect originalRect, double scaleFactor) {
     double newWidth = originalRect.width * scaleFactor;
     double newHeight = originalRect.height * scaleFactor;

     double widthDiff = (newWidth - originalRect.width) / 2;
     double heightDiff = (newHeight - originalRect.height) / 2;

     double newLeft = originalRect.left - widthDiff;
     double newTop = originalRect.top - heightDiff;

     return Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
   }

  @override
  bool shouldRepaint(FaceRectanglePainter oldDelegate) {
    return true;
  }

}
