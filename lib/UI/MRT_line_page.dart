// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';

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

class MRTGraphicsGenerator extends StatefulWidget {
  String? lineAbbv;
  MRTGraphicsGenerator({required String this.lineAbbv});

  @override
  State<MRTGraphicsGenerator> createState() => _MRTGraphicsGeneratorState();

  static Color mrtColorMap(String color) {
    switch (color) {
      case "red":
        return Color.fromRGBO(225, 37, 27, 1);
      case "green":
        return Color.fromRGBO(0, 149, 59, 1);
      case "blue":
        return Color.fromRGBO(0, 93, 166, 1); //rgb(0,93,166)
      case "brown":
        return Color.fromRGBO(157, 89, 24, 1); //rgb(157,89,24)
      case "yellow":
        return Color.fromRGBO(255, 158, 24, 1); //rgb(255,158,24)
      case "grey":
        return Color.fromRGBO(113, 132, 114, 1); //rgb(113,132,114)
      case "purple":
        return Color.fromRGBO(158, 40, 181, 1); //rgb(158,40,181)
      default:
        return Colors.black;
    }
  }
}

class _MRTGraphicsGeneratorState extends State<MRTGraphicsGenerator> {
  final double rowHeight = 45;

  final double codeBlockWidth = 70;

  final double graphFirstBlockWidth = 45;

  final double graphNextBlockWidth = 40;

  final double stationNameBlockWidth = 150;

  List<Map<String, dynamic>>? data;

  fetchMRTData() async {
    this.data = await MRTProvider().queryMRTLine(this.widget.lineAbbv!);
  }

  @override
  Widget build(BuildContext context) {
    String title = MRTProvider().getLineNameFromAbbv(this.widget.lineAbbv!);
    print(this.widget.lineAbbv);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: FutureBuilder(
            future: fetchMRTData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                print(snapshot.stackTrace);
                return UI.errorMessage();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                //Show circular progress indicator if loading
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                child: SingleChildScrollView(
                  child: Column(children: [
                    //Title
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Center(
                          child: Text(
                        title + " (" + this.widget.lineAbbv! + ")",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: MRTProvider()
                                .getColorFromLineAbbv(this.widget.lineAbbv!)),
                      )),
                    ),
                    //Main Block
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(this.data!.length, (index) {
                          return _renderRow(this.data![index]);
                        }),
                      ),
                    ),
                  ]),
                ),
              );
            }));
  }

  Widget _renderRow(rowJSON) {
    return Container(
      height: rowHeight,
      child: Row(
        children: [
          Spacer(),
          _stationCodeBlock(rowJSON),
          _graphicsBlock(rowJSON["Nodes"][0], graphFirstBlockWidth),
          rowJSON["Nodes"].length > 1
              ? _graphicsBlock(rowJSON["Nodes"][1], graphNextBlockWidth)
              : _graphicsBlock(null, graphNextBlockWidth),
          rowJSON["Nodes"].length > 2
              ? _graphicsBlock(rowJSON["Nodes"][2], graphNextBlockWidth)
              : _graphicsBlock(null, graphNextBlockWidth),
          _nameBlock(rowJSON),
          Spacer(),
        ],
      ),
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
    if (nodeJSON == null) {
      return Container(height: rowHeight, width: width);
    }
    List<Widget> _childrenList =
        List.generate(nodeJSON["lines"].length, (index) {
      return _renderLine(nodeJSON["lines"][index]["pos1"],
          nodeJSON["lines"][index]["pos2"], Size(rowHeight, width));
    });

    _childrenList.add(Center(
        child: Icon(
      Icons.circle,
      color: MRTGraphicsGenerator.mrtColorMap(nodeJSON["color"]),
    )));

    _childrenList
        .add(Center(child: Icon(Icons.circle, color: Colors.white, size: 20)));

    return Container(
        height: rowHeight, width: width, child: Stack(children: _childrenList));
  }

  Widget _nameBlock(rowJSON,) {
    return InkWell(
      onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => 
                  DetailPageContainer(searchResult: SearchResult.fromMRTLines(rowJSON))
                  )),
      child: Container(
        height: rowHeight,
        width: stationNameBlockWidth,
        child: Row(children: [
          Text(rowJSON["Station Name"]),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.arrow_forward_ios, size: 12),
          ),
        ]),
      ),
    );
  }

  Widget _renderLine(
      List<dynamic> pos1Tuple, List<dynamic> pos2Tuple, Size size) {
    PositionIndicator pos1 = PositionIndicator(
        horizontalPosition: int.parse(pos1Tuple[0].toString()),
        verticalPosition: int.parse(pos1Tuple[1].toString()));
    PositionIndicator pos2 = PositionIndicator(
        horizontalPosition: int.parse(pos2Tuple[0].toString()),
        verticalPosition: int.parse(pos2Tuple[1].toString()));
    return Center(
      child: CustomPaint(
        //                       <-- CustomPaint widget
        size: size,
        painter: LinePainter(pos1: pos1, pos2: pos2),
      ),
    );
  }
}
