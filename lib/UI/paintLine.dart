import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class PositionIndicator{
  int horizontalPosition;
  int verticalPosition;
  PositionIndicator({required this.horizontalPosition, required this.verticalPosition});
  Offset toOffset(Size size) {
    var horizon;
    switch (horizontalPosition){
      case -1:
        horizon = 0;
        break;
      case 0:
        horizon = size.width/2;
        break;
      case 1: 
        horizon = size.width;
        break;
    }
    var vertical;
    switch (verticalPosition){
      case -1:
        vertical = 0;
        break;
      case 0:
        vertical = size.height/2;
        break;
      case 1: 
        vertical = size.height;
        break;
    }
  return Offset(horizon.toDouble(), vertical.toDouble());
  }
}

class LinePainter extends CustomPainter {
  PositionIndicator? pos1;
  PositionIndicator? pos2;
  LinePainter({required PositionIndicator this.pos1, required PositionIndicator this.pos2});
  @override
  void paint(Canvas canvas, Size size) {
  final pointMode = ui.PointMode.polygon;
  final points = [
    this.pos1!.toOffset(size),
    this.pos2!.toOffset(size)
  ];
  final paint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  canvas.drawPoints(pointMode, points, paint);
}
  
   @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

Widget renderLine(List<int> pos1Tuple, List<int> pos2Tuple, Size size){
  PositionIndicator pos1 = PositionIndicator(horizontalPosition: pos1Tuple[0], verticalPosition: pos1Tuple[1]);
  PositionIndicator pos2 = PositionIndicator(horizontalPosition: pos2Tuple[0], verticalPosition: pos2Tuple[1]);
  return Center(
      child: CustomPaint( //                       <-- CustomPaint widget
        size: size,
        painter: LinePainter(pos1: pos1, pos2: pos2),
      ),
    );
}
