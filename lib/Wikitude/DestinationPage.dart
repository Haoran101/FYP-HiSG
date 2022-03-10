import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Wikitude/arview.dart';
import 'package:wikitude_flutter_app/Wikitude/sample.dart';

class DestinationPage extends StatefulWidget {
  Sample sample;
  DestinationPage({required this.sample});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {

  switchToARView() {
    //TODO: push view to request for destination
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ArViewWidget(sample: this.widget.sample)));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}