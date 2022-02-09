import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class PositionIndicator {
  int horizontalPosition;
  int verticalPosition;
  PositionIndicator(
      {required this.horizontalPosition, required this.verticalPosition});
  Offset toOffset(Size size) {
    var horizon;
    switch (horizontalPosition) {
      case -1:
        horizon = 0;
        break;
      case 0:
        horizon = size.width / 2;
        break;
      case 1:
        horizon = size.width;
        break;
    }
    var vertical;
    switch (verticalPosition) {
      case -1:
        vertical = size.height;
        break;
      case 0:
        vertical = size.height / 2;
        break;
      case 1:
        vertical = 0;
        break;
    }
    return Offset(horizon.toDouble(), vertical.toDouble());
  }
}

class LinePainter extends CustomPainter {
  PositionIndicator? pos1;
  PositionIndicator? pos2;
  LinePainter(
      {required PositionIndicator this.pos1,
      required PositionIndicator this.pos2});
  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;
    final points = [this.pos1!.toOffset(size), this.pos2!.toOffset(size)];
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

class MRTGraphicsGenerator extends StatelessWidget {
  final double rowHeight = 45;
  final double codeBlockWidth = 70;
  final double graphFirstBlockWidth = 45;
  final double graphNextBlockWidth = 40;
  final double stationNameBlockWidth = 100;
  List<Map<String, dynamic>>? data;

  MRTGraphicsGenerator({required List<Map<String, dynamic>> this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
            child: Column(children: List.generate(data!.length, (index) {
              return _renderRow(data![index]);
            }),),
          ),
        ),
      ),
    );
  }

  Color _colorMap(String color) {
    switch (color) {
      case "red":
        return Color.fromRGBO(225,37,27, 1);
      case "green":
        return Color.fromRGBO(0, 149, 59, 1);
      case "blue":
        return Color.fromRGBO(0,93,166, 1);//rgb(0,93,166)
      case "brown":
        return Color.fromRGBO(157,89,24, 1);//rgb(157,89,24)
      case "yellow":
        return Color.fromRGBO(255,158,24, 1);//rgb(255,158,24)
      case "grey":
        return Color.fromRGBO(113,132,114, 1);//rgb(113,132,114)
      case "purple":
        return Color.fromRGBO(158,40,181,1);//rgb(158,40,181)
      default:
        return Colors.black;
    }
  }

  Widget _renderRow(rowJSON){
    return Container(
      height: rowHeight,
      child: Row(children: [
        _stationCodeBlock(rowJSON),
        _graphicsBlock(rowJSON["Nodes"][0], graphFirstBlockWidth),
        rowJSON["Nodes"].length > 1?
        _graphicsBlock(rowJSON["Nodes"][1], graphNextBlockWidth): 
        _graphicsBlock(null, graphNextBlockWidth),
        rowJSON["Nodes"].length > 2?
        _graphicsBlock(rowJSON["Nodes"][2], graphNextBlockWidth): 
        _graphicsBlock(null, graphNextBlockWidth),
        _nameBlock(rowJSON)
      ],),
    );
  }
  
  Widget _stationCodeBlock(rowJSON) {
    return Container(
      height: rowHeight,
      width: codeBlockWidth,
      child: Center(child: Text(rowJSON["Code"])),
    );
  }

  Widget _graphicsBlock(nodeJSON, width) {
    if (nodeJSON == null){
      return Container(
        height: rowHeight, width: width
      );
    }
    List<Widget> _childrenList =
        List.generate(nodeJSON["lines"].length, (index) {
      return _renderLine(nodeJSON["lines"][index]["pos1"],
          nodeJSON["lines"][index]["pos2"], Size(rowHeight, width));
    });

    _childrenList.add(Center(
        child: Icon(
      Icons.circle,
      color:  _colorMap(nodeJSON["color"]),
    )));

    _childrenList.add(Center(
        child: Icon(
      Icons.circle,
      color: Colors.white,
      size: 20
    )));

    return Container(
        height: rowHeight, width: width, child: Stack(children: _childrenList));
  }

  Widget _nameBlock(rowJSON){
    return Container(
      height: rowHeight,
      width: stationNameBlockWidth,
      child: Row(children: [Text(rowJSON["Station Name"]),
      Spacer(),
      Icon(Icons.keyboard_arrow_right_outlined)]),
    );
  }

  Widget _renderLine(List<dynamic> pos1Tuple, List<dynamic> pos2Tuple, Size size) {
    PositionIndicator pos1 = PositionIndicator(
        horizontalPosition: int.parse(pos1Tuple[0].toString()), verticalPosition: int.parse(pos1Tuple[1].toString()));
    PositionIndicator pos2 = PositionIndicator(
        horizontalPosition: int.parse(pos2Tuple[0].toString()), verticalPosition: int.parse(pos2Tuple[1].toString()));
    return Center(
      child: CustomPaint(
        //                       <-- CustomPaint widget
        size: size,
        painter: LinePainter(pos1: pos1, pos2: pos2),
      ),
    );
  }
}
