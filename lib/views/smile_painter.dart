import 'dart:io';
import 'dart:ui' as ui show Image;
import 'dart:math' as Math;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class FacePaint extends CustomPaint {
  final CustomPainter painter;

  FacePaint({this.painter}) : super(painter: painter);
}

class SmilePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;


  SmilePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image, Offset.zero, Paint());
    }



    //Draw Body
    final paint = Paint()..color = Colors.white;

    for (var i = 0; i < faces.length; i++) {
      final radius =
          Math.min(faces[i].boundingBox.width, faces[i].boundingBox.height) / 2;
      final center = faces[i].boundingBox.center;
      final smilePaint = Paint();

      canvas.drawCircle(center, radius, paint);

    }
  }

  @override
  bool shouldRepaint(SmilePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}

class SmilePainterLiveCamera extends CustomPainter {
  final Size imageSize;
  final List<Face> faces;

  SmilePainterLiveCamera(this.imageSize, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
//    final paintRectStyle = Paint()
//      ..color = Colors.red
//      ..strokeWidth = 10.0
//      ..style = PaintingStyle.stroke;

    final paint = Paint()..color = Colors.yellow;

    for (var i = 0; i < faces.length; i++) {
      //Scale rect to image size
      final rect = _scaleRect(
        rect: faces[i].boundingBox,
        imageSize: imageSize,
        widgetSize: size,
      );

      //Radius for smile circle
      final radius = Math.min(rect.width, rect.height) / 2;

      //Center of face rect
      final Offset center = rect.center;

      final smilePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth =  8;

      //Draw rect border
      //canvas.drawRect(rect, paintRectStyle);

      //Draw body
      canvas.drawCircle(center, radius, paint);

      //Draw mouth



    }
  }

  @override
  bool shouldRepaint(SmilePainterLiveCamera oldDelegate) {
    return imageSize != oldDelegate.imageSize || faces != oldDelegate.faces;
  }
}

Rect _scaleRect({
  @required Rect rect,
  @required Size imageSize,
  @required Size widgetSize,
}) {
  final double scaleX = widgetSize.width / imageSize.width;
  final double scaleY = widgetSize.height / imageSize.height;

  return Rect.fromLTRB(
    rect.left.toDouble() * scaleX,
    rect.top.toDouble() * scaleY,
    rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
  );
}